#include "infrastructure/transport/tcp_transport.h"

#include <QMetaObject>
#include <QThread>

#include <limits>
#include <utility>

namespace infrastructure::transport {

TcpTransport::TcpTransport(QObject* parent)
    : QObject(parent)
    , m_socket(new QTcpSocket(this))
    , m_connectionTimer(new QTimer(this))
    , m_inactivityTimer(new QTimer(this))
{
    qRegisterMetaType<ConnectionState>();
    qRegisterMetaType<TransportError>();
    qRegisterMetaType<TransportFailure>();

    m_connectionTimer->setSingleShot(true);
    m_inactivityTimer->setSingleShot(true);

}

ConnectionState TcpTransport::state() const
{
    return m_state;
}

qsizetype TcpTransport::bufferedInputSize() const
{
    return m_inputBuffer.size();
}

void TcpTransport::connectToHost(const ConnectionOptions& options)
{
    if (!isOnOwningThread()) {
        QMetaObject::invokeMethod(this, [this, options]() { connectToHost(options); }, Qt::QueuedConnection);
        return;
    }

    if (m_state != ConnectionState::Idle && m_state != ConnectionState::Closed) {
        fail(TransportError::InvalidState, "Connection attempt started from an invalid state");
        return;
    }

    m_terminalEventEmitted = false;
    m_inputBuffer.clear();
    disconnect(m_socket, nullptr, this, nullptr);
    m_socket->abort();
    m_socket->deleteLater();
    m_socket = new QTcpSocket(this);
    ++m_attemptId;
    connectAttemptSignals(m_attemptId);

    if (!optionsAreValid(options)) {
        fail(TransportError::InvalidConfiguration, "Connection options are invalid");
        return;
    }

    m_maximumBufferedInputBytes = options.maximumBufferedInputBytes;
    m_maximumPendingOutputBytes = options.maximumPendingOutputBytes;
    m_inactivityTimeoutMilliseconds = static_cast<int>(options.inactivityTimeout.count());

    setState(ConnectionState::Connecting);
    m_connectionTimer->start(static_cast<int>(options.connectionTimeout.count()));
    m_socket->connectToHost(options.host, options.port);
}

void TcpTransport::close()
{
    if (!isOnOwningThread()) {
        QMetaObject::invokeMethod(this, [this]() { close(); }, Qt::QueuedConnection);
        return;
    }

    if (m_state == ConnectionState::Closed || m_state == ConnectionState::Closing) {
        return;
    }

    m_connectionTimer->stop();
    m_inactivityTimer->stop();

    if (m_state == ConnectionState::Idle) {
        finishClosed();
        return;
    }

    setState(ConnectionState::Closing);

    if (m_socket->state() == QAbstractSocket::UnconnectedState) {
        finishClosed();
        return;
    }

    m_socket->abort();
    finishClosed();
}

bool TcpTransport::send(const QByteArray& data)
{
    if (!isOnOwningThread() || m_state != ConnectionState::Connected) {
        return false;
    }

    const auto pendingBytes = m_socket->bytesToWrite();
    const auto availableBytes = static_cast<quint64>(m_maximumPendingOutputBytes);
    const auto requestedBytes = static_cast<quint64>(data.size());

    if (pendingBytes < 0 || static_cast<quint64>(pendingBytes) > availableBytes || requestedBytes > availableBytes - static_cast<quint64>(pendingBytes)) {
        fail(TransportError::OutputLimitExceeded, "Pending output limit exceeded");
        return false;
    }

    if (m_socket->write(data) != data.size()) {
        fail(TransportError::SocketFailure, "Socket did not accept the complete output buffer");
        return false;
    }

    restartInactivityTimer();
    return true;
}

QByteArray TcpTransport::takeBufferedInput()
{
    if (!isOnOwningThread()) {
        return {};
    }

    return std::exchange(m_inputBuffer, QByteArray {});
}

void TcpTransport::handleConnected()
{
    if (m_state != ConnectionState::Connecting) {
        return;
    }

    m_connectionTimer->stop();
    setState(ConnectionState::Connected);
    restartInactivityTimer();
    emit connected();
}

void TcpTransport::handleDisconnected()
{
    if (m_state == ConnectionState::Closing) {
        finishClosed();
        return;
    }

    if (m_state == ConnectionState::Connected || m_state == ConnectionState::Connecting) {
        fail(TransportError::RemoteClosed, "Remote endpoint closed the connection");
    }
}

void TcpTransport::handleReadyRead()
{
    if (m_state != ConnectionState::Connected) {
        m_socket->readAll();
        return;
    }

    const auto incomingData = m_socket->readAll();
    const auto currentSize = static_cast<quint64>(m_inputBuffer.size());
    const auto incomingSize = static_cast<quint64>(incomingData.size());
    const auto maximumSize = static_cast<quint64>(m_maximumBufferedInputBytes);

    if (currentSize > maximumSize || incomingSize > maximumSize - currentSize) {
        fail(TransportError::InputLimitExceeded, "Buffered input limit exceeded");
        return;
    }

    m_inputBuffer.append(incomingData);
    restartInactivityTimer();
    emit dataAvailable(m_inputBuffer.size());
}

void TcpTransport::handleSocketError(const QAbstractSocket::SocketError socketError)
{
    if (m_state == ConnectionState::Closing || m_state == ConnectionState::Closed) {
        return;
    }

    if (socketError == QAbstractSocket::RemoteHostClosedError && m_state == ConnectionState::Connected) {
        return;
    }

    fail(TransportError::SocketFailure, "Socket operation failed");
}

void TcpTransport::handleConnectionTimeout()
{
    if (m_state == ConnectionState::Connecting) {
        fail(TransportError::ConnectionTimeout, "Connection attempt timed out");
    }
}

void TcpTransport::handleInactivityTimeout()
{
    if (m_state == ConnectionState::Connected) {
        fail(TransportError::InactivityTimeout, "Connection inactivity timeout elapsed");
    }
}

void TcpTransport::restartInactivityTimer()
{
    if (m_state == ConnectionState::Connected) {
        m_inactivityTimer->start(m_inactivityTimeoutMilliseconds);
    }
}

void TcpTransport::connectAttemptSignals(const quint64 attemptId)
{
    disconnect(m_socket, nullptr, this, nullptr);
    disconnect(m_connectionTimer, nullptr, this, nullptr);
    disconnect(m_inactivityTimer, nullptr, this, nullptr);

    const auto isCurrentAttempt = [this, attemptId]() { return attemptId == m_attemptId; };

    connect(m_socket, &QTcpSocket::connected, this, [this, isCurrentAttempt]() {
        if (isCurrentAttempt()) {
            handleConnected();
        }
    });
    connect(m_socket, &QTcpSocket::disconnected, this, [this, isCurrentAttempt]() {
        if (isCurrentAttempt()) {
            handleDisconnected();
        }
    });
    connect(m_socket, &QTcpSocket::readyRead, this, [this, isCurrentAttempt]() {
        if (isCurrentAttempt()) {
            handleReadyRead();
        }
    });
    connect(m_socket, &QTcpSocket::errorOccurred, this, [this, isCurrentAttempt](const QAbstractSocket::SocketError socketError) {
        if (isCurrentAttempt()) {
            handleSocketError(socketError);
        }
    });
    connect(m_connectionTimer, &QTimer::timeout, this, [this, isCurrentAttempt]() {
        if (isCurrentAttempt()) {
            handleConnectionTimeout();
        }
    });
    connect(m_inactivityTimer, &QTimer::timeout, this, [this, isCurrentAttempt]() {
        if (isCurrentAttempt()) {
            handleInactivityTimeout();
        }
    });
}

void TcpTransport::setState(const ConnectionState state)
{
    if (m_state == state) {
        return;
    }

    m_state = state;
    emit stateChanged(m_state);
}

void TcpTransport::fail(const TransportError error, QString description)
{
    if (m_terminalEventEmitted) {
        return;
    }

    m_connectionTimer->stop();
    m_inactivityTimer->stop();
    m_terminalEventEmitted = true;
    m_socket->abort();
    setState(ConnectionState::Closed);
    emit failureOccurred({.error = error, .description = std::move(description)});
    emit disconnected();
}

void TcpTransport::finishClosed()
{
    if (m_terminalEventEmitted) {
        setState(ConnectionState::Closed);
        return;
    }

    m_terminalEventEmitted = true;
    setState(ConnectionState::Closed);
    emit disconnected();
}

bool TcpTransport::optionsAreValid(const ConnectionOptions& options) const
{
    return !options.host.trimmed().isEmpty()
        && options.port != 0
        && options.connectionTimeout.count() > 0
        && options.connectionTimeout.count() <= std::numeric_limits<int>::max()
        && options.inactivityTimeout.count() > 0
        && options.inactivityTimeout.count() <= std::numeric_limits<int>::max()
        && options.maximumBufferedInputBytes > 0
        && options.maximumPendingOutputBytes > 0;
}

bool TcpTransport::isOnOwningThread() const
{
    return thread() == QThread::currentThread();
}

}
