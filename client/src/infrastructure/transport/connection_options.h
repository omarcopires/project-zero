#pragma once

#include <QString>
#include <QtGlobal>

#include <chrono>
#include <cstddef>

namespace infrastructure::transport {

struct ConnectionOptions {
    QString host;
    quint16 port = 0;
    std::chrono::milliseconds connectionTimeout{5000};
    std::chrono::milliseconds inactivityTimeout{30000};
    std::size_t maximumBufferedInputBytes = 1024 * 1024;
    std::size_t maximumPendingOutputBytes = 1024 * 1024;
};

}
