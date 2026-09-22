#pragma once

#include <QMetaType>

namespace infrastructure::transport {

enum class TransportError {
    InvalidConfiguration,
    InvalidState,
    ConnectionTimeout,
    InactivityTimeout,
    RemoteClosed,
    SocketFailure,
    InputLimitExceeded,
    OutputLimitExceeded,
};

}

Q_DECLARE_METATYPE(infrastructure::transport::TransportError)
