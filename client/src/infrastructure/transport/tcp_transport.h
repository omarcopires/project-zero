#pragma once

#include "infrastructure/transport/connection_options.h"
#include "infrastructure/transport/connection_state.h"
#include "infrastructure/transport/transport_failure.h"

#include <QByteArray>
#include <QObject>
#include <QTcpSocket>
#include <QTimer>

namespace infrastructure::transport {

class TcpTransport final : public QObject {
    Q_OBJECT

public:
    explicit TcpTransport(QObject* parent = nullptr);

    ConnectionState state() const;
    qsizetype bufferedInputSize() const;

    void connectToHost(const ConnectionOptions& options);
    void close();
    bool send(const QByteArray& data);
    QByteArray takeBufferedInput();

signals:
    void stateChanged(infrastructure::transport::ConnectionState state);
    void connected();
    void disconnected();
    void dataAvailable(qsizetype bufferedBytes);
    void failureOccurred(infrastructure::transport::TransportFailure failure);

private:
    void handleConnected();
    void handleDisconnected();
    void handleReadyRead();
    void handleSocketError(QAbstractSocket::SocketError socketError);
    void handleConnectionTimeout();
    void handleInactivityTimeout();
    void restartInactivityTimer();
    void connectAttemptSignals(quint64 attemptId);
    void setState(ConnectionState state);
    void fail(TransportError error, QString description);
    void finishClosed();
    bool optionsAreValid(const ConnectionOptions& options) const;
    bool isOnOwningThread() const;

    QTcpSocket* m_socket;
    QTimer* m_connectionTimer;
    QTimer* m_inactivityTimer;
    ConnectionState m_state = ConnectionState::Idle;
    QByteArray m_inputBuffer;
    std::size_t m_maximumBufferedInputBytes = 0;
    std::size_t m_maximumPendingOutputBytes = 0;
    int m_inactivityTimeoutMilliseconds = 0;
    quint64 m_attemptId = 0;
    bool m_terminalEventEmitted = true;
};

}
