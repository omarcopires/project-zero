#include "infrastructure/http/http_transport.h"

#include <QHostAddress>
#include <QElapsedTimer>
#include <QSignalSpy>
#include <QTcpServer>
#include <QTcpSocket>
#include <QtTest>

#include <chrono>

using infrastructure::http::HttpError;
using infrastructure::http::HttpFailure;
using infrastructure::http::HttpRequestOptions;
using infrastructure::http::HttpResponse;
using infrastructure::http::HttpTransport;

class HttpTransportTest final : public QObject {
	Q_OBJECT

private slots:
	void completesBoundedRequest();
	void rejectsOversizedResponse();
	void reportsTimeout();
	void reportsCancellation();
	void rejectsRedirect();
	void rejectsInvalidConfiguration();
	void rejectsNonLoopbackPlainHttp();
	void rejectsConcurrentOperation();
};

namespace {

	HttpRequestOptions optionsFor(const QTcpServer &server) {
		HttpRequestOptions options;
		options.endpoint = QUrl(QStringLiteral("http://127.0.0.1:%1/api").arg(server.serverPort()));
		options.deadline = std::chrono::milliseconds { 1000 };
		return options;
	}

	QTcpSocket* takePeer(QTcpServer &server) {
		QElapsedTimer timer;
		timer.start();
		while (!server.hasPendingConnections() && timer.elapsed() < 1000) {
			QCoreApplication::processEvents();
			QTest::qWait(1);
		}
		return server.nextPendingConnection();
	}

	void writeResponse(QTcpSocket* peer, const QByteArray &response) {
		QCOMPARE(peer->write(response), static_cast<qint64>(response.size()));
		QVERIFY(peer->waitForBytesWritten());
	}

	HttpFailure failureFrom(const QSignalSpy &spy, const int index = 0) {
		return qvariant_cast<HttpFailure>(spy.at(index).first());
	}

}

void HttpTransportTest::completesBoundedRequest() {
	QTcpServer server;
	QVERIFY(server.listen(QHostAddress::LocalHost));
	HttpTransport transport;
	QSignalSpy completedSpy(&transport, &HttpTransport::completed);

	transport.postJson(optionsFor(server), QByteArrayLiteral("{}"));
	auto* peer = takePeer(server);
	QVERIFY(peer != nullptr);
	writeResponse(peer, QByteArrayLiteral("HTTP/1.1 200 OK\r\nContent-Length: 2\r\nConnection: close\r\n\r\n{}"));

	QTRY_COMPARE(completedSpy.count(), 1);
	const auto response = qvariant_cast<HttpResponse>(completedSpy.first().first());
	QCOMPARE(response.statusCode, 200);
	QCOMPARE(response.body, QByteArrayLiteral("{}"));
	QVERIFY(!transport.isActive());
}

void HttpTransportTest::rejectsOversizedResponse() {
	QTcpServer server;
	QVERIFY(server.listen(QHostAddress::LocalHost));
	auto options = optionsFor(server);
	options.maximumResponseBytes = 4;
	HttpTransport transport;
	QSignalSpy failureSpy(&transport, &HttpTransport::failureOccurred);

	transport.postJson(options, QByteArrayLiteral("{}"));
	auto* peer = takePeer(server);
	QVERIFY(peer != nullptr);
	writeResponse(peer, QByteArrayLiteral("HTTP/1.1 200 OK\r\nContent-Length: 5\r\nConnection: close\r\n\r\n12345"));

	QTRY_COMPARE(failureSpy.count(), 1);
	QCOMPARE(failureFrom(failureSpy).error, HttpError::ResponseTooLarge);
}

void HttpTransportTest::reportsTimeout() {
	QTcpServer server;
	QVERIFY(server.listen(QHostAddress::LocalHost));
	auto options = optionsFor(server);
	options.deadline = std::chrono::milliseconds { 20 };
	HttpTransport transport;
	QSignalSpy failureSpy(&transport, &HttpTransport::failureOccurred);

	transport.postJson(options, QByteArrayLiteral("{}"));

	QTRY_COMPARE(failureSpy.count(), 1);
	QCOMPARE(failureFrom(failureSpy).error, HttpError::Timeout);
}

void HttpTransportTest::reportsCancellation() {
	QTcpServer server;
	QVERIFY(server.listen(QHostAddress::LocalHost));
	HttpTransport transport;
	QSignalSpy failureSpy(&transport, &HttpTransport::failureOccurred);

	transport.postJson(optionsFor(server), QByteArrayLiteral("{}"));
	transport.cancel();

	QCOMPARE(failureSpy.count(), 1);
	QCOMPARE(failureFrom(failureSpy).error, HttpError::Cancelled);
	QVERIFY(!transport.isActive());
}

void HttpTransportTest::rejectsRedirect() {
	QTcpServer server;
	QVERIFY(server.listen(QHostAddress::LocalHost));
	HttpTransport transport;
	QSignalSpy failureSpy(&transport, &HttpTransport::failureOccurred);

	transport.postJson(optionsFor(server), QByteArrayLiteral("{}"));
	auto* peer = takePeer(server);
	QVERIFY(peer != nullptr);
	writeResponse(peer, QByteArrayLiteral("HTTP/1.1 302 Found\r\nLocation: http://127.0.0.1/other\r\nContent-Length: 0\r\nConnection: close\r\n\r\n"));

	QTRY_COMPARE(failureSpy.count(), 1);
	QCOMPARE(failureFrom(failureSpy).error, HttpError::RedirectRejected);
}

void HttpTransportTest::rejectsInvalidConfiguration() {
	HttpTransport transport;
	QSignalSpy failureSpy(&transport, &HttpTransport::failureOccurred);

	transport.postJson({}, QByteArrayLiteral("{}"));

	QCOMPARE(failureSpy.count(), 1);
	QCOMPARE(failureFrom(failureSpy).error, HttpError::InvalidConfiguration);
}

void HttpTransportTest::rejectsNonLoopbackPlainHttp() {
	HttpTransport transport;
	QSignalSpy failureSpy(&transport, &HttpTransport::failureOccurred);
	HttpRequestOptions options;
	options.endpoint = QUrl(QStringLiteral("http://example.invalid/api"));

	transport.postJson(options, QByteArrayLiteral("{}"));

	QCOMPARE(failureSpy.count(), 1);
	QCOMPARE(failureFrom(failureSpy).error, HttpError::InvalidConfiguration);
}

void HttpTransportTest::rejectsConcurrentOperation() {
	QTcpServer server;
	QVERIFY(server.listen(QHostAddress::LocalHost));
	HttpTransport transport;
	QSignalSpy failureSpy(&transport, &HttpTransport::failureOccurred);
	const auto options = optionsFor(server);

	transport.postJson(options, QByteArrayLiteral("{}"));
	transport.postJson(options, QByteArrayLiteral("{}"));

	QCOMPARE(failureSpy.count(), 1);
	QCOMPARE(failureFrom(failureSpy).error, HttpError::OperationInProgress);
	QVERIFY(transport.isActive());
	transport.cancel();
	QCOMPARE(failureSpy.count(), 2);
	QCOMPARE(failureFrom(failureSpy, 1).error, HttpError::Cancelled);
}

QTEST_GUILESS_MAIN(HttpTransportTest)

#include "http_transport_test.moc"
