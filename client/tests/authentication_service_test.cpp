#include "application/authentication/authentication_service.h"

#include <QElapsedTimer>
#include <QHostAddress>
#include <QSignalSpy>
#include <QTcpServer>
#include <QTcpSocket>
#include <QtTest>

#include <chrono>

using application::authentication::AuthenticationService;
using infrastructure::http::HttpRequestOptions;
using session::authentication::AuthenticationState;
using session::authentication::LoginRequest;

class AuthenticationServiceTest final : public QObject {
	Q_OBJECT

private slots:
	void authenticatesSyntheticSession();
	void classifiesRejectedCredentials();
	void stopsAtUnsupportedChallenge();
	void rejectsIncompatibleResponse();
	void reportsTimeout();
	void cancelsActiveRequest();
	void rejectsConcurrentAttempt();
};

namespace {

	const QByteArray successfulBody = R"({"session":{"sessionkey":"synthetic-session","status":"active"},"playdata":{"worlds":[{"id":0,"name":"Local","externaladdressunprotected":"127.0.0.1","externalportunprotected":7172}],"characters":[{"name":"Synthetic Character","worldid":0}]}})";

	HttpRequestOptions optionsFor(const QTcpServer &server) {
		HttpRequestOptions options;
		options.endpoint = QUrl(QStringLiteral("http://127.0.0.1:%1/api/v1/webservice").arg(server.serverPort()));
		options.deadline = std::chrono::milliseconds { 1000 };
		return options;
	}

	LoginRequest syntheticRequest() {
		return { .email = "test@example.invalid", .password = "synthetic-password" };
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

	void respond(QTcpSocket* peer, const QByteArray &body, const QByteArray &status = QByteArrayLiteral("200 OK")) {
		const auto response = QByteArrayLiteral("HTTP/1.1 ") + status
			+ QByteArrayLiteral("\r\nContent-Type: application/json\r\nContent-Length: ")
			+ QByteArray::number(body.size()) + QByteArrayLiteral("\r\nConnection: close\r\n\r\n") + body;
		QCOMPARE(peer->write(response), static_cast<qint64>(response.size()));
		QVERIFY(peer->waitForBytesWritten());
	}

}

void AuthenticationServiceTest::authenticatesSyntheticSession() {
	QTcpServer server;
	QVERIFY(server.listen(QHostAddress::LocalHost));
	AuthenticationService service;
	QSignalSpy stateSpy(&service, &AuthenticationService::stateChanged);

	QVERIFY(service.authenticate(optionsFor(server), syntheticRequest()));
	auto* peer = takePeer(server);
	QVERIFY(peer != nullptr);
	respond(peer, successfulBody);

	QTRY_COMPARE(service.state(), AuthenticationState::Authenticated);
	QVERIFY(service.authenticatedSession() != nullptr);
	QVERIFY(service.authenticatedSession()->sessionKey == "synthetic-session");
	QCOMPARE(stateSpy.count(), 2);
}

void AuthenticationServiceTest::classifiesRejectedCredentials() {
	QTcpServer server;
	QVERIFY(server.listen(QHostAddress::LocalHost));
	AuthenticationService service;

	QVERIFY(service.authenticate(optionsFor(server), syntheticRequest()));
	auto* peer = takePeer(server);
	QVERIFY(peer != nullptr);
	respond(peer, QByteArrayLiteral(R"({"errorMessage":"controlled remote rejection"})"), QByteArrayLiteral("401 Unauthorized"));

	QTRY_COMPARE(service.state(), AuthenticationState::Rejected);
}

void AuthenticationServiceTest::stopsAtUnsupportedChallenge() {
	QTcpServer server;
	QVERIFY(server.listen(QHostAddress::LocalHost));
	AuthenticationService service;

	QVERIFY(service.authenticate(optionsFor(server), syntheticRequest()));
	auto* peer = takePeer(server);
	QVERIFY(peer != nullptr);
	respond(peer, QByteArrayLiteral(R"({"errorCode":6,"errorMessage":"code required"})"));

	QTRY_COMPARE(service.state(), AuthenticationState::UnsupportedChallenge);
	QCOMPARE(service.authenticatedSession(), nullptr);
}

void AuthenticationServiceTest::rejectsIncompatibleResponse() {
	QTcpServer server;
	QVERIFY(server.listen(QHostAddress::LocalHost));
	AuthenticationService service;

	QVERIFY(service.authenticate(optionsFor(server), syntheticRequest()));
	auto* peer = takePeer(server);
	QVERIFY(peer != nullptr);
	respond(peer, QByteArrayLiteral("{}"));

	QTRY_COMPARE(service.state(), AuthenticationState::Failed);
}

void AuthenticationServiceTest::reportsTimeout() {
	QTcpServer server;
	QVERIFY(server.listen(QHostAddress::LocalHost));
	auto options = optionsFor(server);
	options.deadline = std::chrono::milliseconds { 20 };
	AuthenticationService service;

	QVERIFY(service.authenticate(options, syntheticRequest()));

	QTRY_COMPARE(service.state(), AuthenticationState::Failed);
}

void AuthenticationServiceTest::cancelsActiveRequest() {
	QTcpServer server;
	QVERIFY(server.listen(QHostAddress::LocalHost));
	AuthenticationService service;

	QVERIFY(service.authenticate(optionsFor(server), syntheticRequest()));
	service.cancel();

	QCOMPARE(service.state(), AuthenticationState::Cancelled);
	QCOMPARE(service.authenticatedSession(), nullptr);
}

void AuthenticationServiceTest::rejectsConcurrentAttempt() {
	QTcpServer server;
	QVERIFY(server.listen(QHostAddress::LocalHost));
	AuthenticationService service;
	const auto options = optionsFor(server);

	QVERIFY(service.authenticate(options, syntheticRequest()));
	QVERIFY(!service.authenticate(options, syntheticRequest()));
	QCOMPARE(service.state(), AuthenticationState::Authenticating);
	service.cancel();
}

QTEST_GUILESS_MAIN(AuthenticationServiceTest)

#include "authentication_service_test.moc"
