#include "infrastructure/transport/tcp_transport.h"

#include <QCoreApplication>
#include <QHostAddress>
#include <QObject>
#include <QSignalSpy>
#include <QTcpServer>
#include <QtTest>

#include <chrono>

using infrastructure::transport::ConnectionOptions;
using infrastructure::transport::ConnectionState;
using infrastructure::transport::TcpTransport;
using infrastructure::transport::TransportError;
using infrastructure::transport::TransportFailure;

class QtBootstrapTest final : public QObject {
    Q_OBJECT

private slots:
    void providesCoreApplication();
    void connectsAndClosesCleanly();
    void buffersIncomingData();
    void rejectsInputBeyondConfiguredLimit();
    void rejectsOutputBeyondConfiguredLimit();
    void rejectsInvalidConfiguration();
    void reportsInactivityTimeout();
    void reportsRemoteClosure();
    void closesIdempotently();
};

namespace {

ConnectionOptions optionsFor(const QTcpServer& server)
{
    ConnectionOptions options;
    options.host = QStringLiteral("127.0.0.1");
    options.port = server.serverPort();
    options.connectionTimeout = std::chrono::milliseconds{1000};
    options.inactivityTimeout = std::chrono::milliseconds{1000};
    return options;
}

TransportFailure failureFrom(const QSignalSpy& spy)
{
    return qvariant_cast<TransportFailure>(spy.first().first());
}

}

void QtBootstrapTest::providesCoreApplication()
{
    QVERIFY(QCoreApplication::instance() != nullptr);
}

void QtBootstrapTest::connectsAndClosesCleanly()
{
    QTcpServer server;
    QVERIFY(server.listen(QHostAddress::LocalHost));

    TcpTransport transport;
    QSignalSpy connectedSpy(&transport, &TcpTransport::connected);
    QSignalSpy disconnectedSpy(&transport, &TcpTransport::disconnected);
    QSignalSpy failureSpy(&transport, &TcpTransport::failureOccurred);

    transport.connectToHost(optionsFor(server));
    QTRY_COMPARE(connectedSpy.count(), 1);
    QCOMPARE(transport.state(), ConnectionState::Connected);
    QCOMPARE(failureSpy.count(), 0);

    transport.close();
    QTRY_COMPARE(disconnectedSpy.count(), 1);
    QCOMPARE(transport.state(), ConnectionState::Closed);
}

void QtBootstrapTest::buffersIncomingData()
{
    QTcpServer server;
    QVERIFY(server.listen(QHostAddress::LocalHost));

    TcpTransport transport;
    QSignalSpy connectedSpy(&transport, &TcpTransport::connected);
    QSignalSpy dataSpy(&transport, &TcpTransport::dataAvailable);
    transport.connectToHost(optionsFor(server));

    QTRY_COMPARE(connectedSpy.count(), 1);
    QTRY_VERIFY(server.hasPendingConnections());
    auto* peer = server.nextPendingConnection();
    const QByteArray payload{"synthetic-data"};
    QCOMPARE(peer->write(payload), static_cast<qint64>(payload.size()));
    QVERIFY(peer->waitForBytesWritten());

    QTRY_COMPARE(dataSpy.count(), 1);
    QCOMPARE(transport.takeBufferedInput(), payload);
    QCOMPARE(transport.bufferedInputSize(), 0);
}

void QtBootstrapTest::rejectsInputBeyondConfiguredLimit()
{
    QTcpServer server;
    QVERIFY(server.listen(QHostAddress::LocalHost));

    auto options = optionsFor(server);
    options.maximumBufferedInputBytes = 4;
    TcpTransport transport;
    QSignalSpy connectedSpy(&transport, &TcpTransport::connected);
    QSignalSpy failureSpy(&transport, &TcpTransport::failureOccurred);
    transport.connectToHost(options);

    QTRY_COMPARE(connectedSpy.count(), 1);
    QTRY_VERIFY(server.hasPendingConnections());
    auto* peer = server.nextPendingConnection();
    const QByteArray payload{"oversized"};
    QCOMPARE(peer->write(payload), static_cast<qint64>(payload.size()));
    QVERIFY(peer->waitForBytesWritten());

    QTRY_COMPARE(failureSpy.count(), 1);
    QCOMPARE(failureFrom(failureSpy).error, TransportError::InputLimitExceeded);
    QCOMPARE(transport.state(), ConnectionState::Closed);
}

void QtBootstrapTest::rejectsOutputBeyondConfiguredLimit()
{
    QTcpServer server;
    QVERIFY(server.listen(QHostAddress::LocalHost));

    auto options = optionsFor(server);
    options.maximumPendingOutputBytes = 4;
    TcpTransport transport;
    QSignalSpy connectedSpy(&transport, &TcpTransport::connected);
    QSignalSpy failureSpy(&transport, &TcpTransport::failureOccurred);
    transport.connectToHost(options);

    QTRY_COMPARE(connectedSpy.count(), 1);
    QVERIFY(!transport.send(QByteArray{"oversized"}));
    QCOMPARE(failureSpy.count(), 1);
    QCOMPARE(failureFrom(failureSpy).error, TransportError::OutputLimitExceeded);
    QCOMPARE(transport.state(), ConnectionState::Closed);
}

void QtBootstrapTest::rejectsInvalidConfiguration()
{
    TcpTransport transport;
    QSignalSpy disconnectedSpy(&transport, &TcpTransport::disconnected);
    QSignalSpy failureSpy(&transport, &TcpTransport::failureOccurred);

    transport.connectToHost({});

    QCOMPARE(failureSpy.count(), 1);
    QCOMPARE(disconnectedSpy.count(), 1);
    QCOMPARE(failureFrom(failureSpy).error, TransportError::InvalidConfiguration);
    QCOMPARE(transport.state(), ConnectionState::Closed);
}

void QtBootstrapTest::reportsInactivityTimeout()
{
    QTcpServer server;
    QVERIFY(server.listen(QHostAddress::LocalHost));

    auto options = optionsFor(server);
    options.inactivityTimeout = std::chrono::milliseconds{20};
    TcpTransport transport;
    QSignalSpy connectedSpy(&transport, &TcpTransport::connected);
    QSignalSpy failureSpy(&transport, &TcpTransport::failureOccurred);
    transport.connectToHost(options);

    QTRY_COMPARE(connectedSpy.count(), 1);
    QTRY_COMPARE(failureSpy.count(), 1);
    QCOMPARE(failureFrom(failureSpy).error, TransportError::InactivityTimeout);
    QCOMPARE(transport.state(), ConnectionState::Closed);
}

void QtBootstrapTest::reportsRemoteClosure()
{
    QTcpServer server;
    QVERIFY(server.listen(QHostAddress::LocalHost));

    TcpTransport transport;
    QSignalSpy connectedSpy(&transport, &TcpTransport::connected);
    QSignalSpy failureSpy(&transport, &TcpTransport::failureOccurred);
    transport.connectToHost(optionsFor(server));

    QTRY_COMPARE(connectedSpy.count(), 1);
    QTRY_VERIFY(server.hasPendingConnections());
    auto* peer = server.nextPendingConnection();
    peer->disconnectFromHost();

    QTRY_COMPARE(failureSpy.count(), 1);
    QCOMPARE(failureFrom(failureSpy).error, TransportError::RemoteClosed);
    QCOMPARE(transport.state(), ConnectionState::Closed);
}

void QtBootstrapTest::closesIdempotently()
{
    TcpTransport transport;
    QSignalSpy disconnectedSpy(&transport, &TcpTransport::disconnected);

    transport.close();
    transport.close();

    QCOMPARE(disconnectedSpy.count(), 0);
    QCOMPARE(transport.state(), ConnectionState::Closed);
}

QTEST_GUILESS_MAIN(QtBootstrapTest)

#include "qt_bootstrap_test.moc"
