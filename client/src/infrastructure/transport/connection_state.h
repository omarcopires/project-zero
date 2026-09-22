#pragma once

#include <QMetaType>

namespace infrastructure::transport {

enum class ConnectionState {
    Idle,
    Connecting,
    Connected,
    Closing,
    Closed,
};

}

Q_DECLARE_METATYPE(infrastructure::transport::ConnectionState)
