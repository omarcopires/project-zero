#pragma once

#include "infrastructure/transport/transport_error.h"

#include <QMetaType>
#include <QString>

namespace infrastructure::transport {

struct TransportFailure {
    TransportError error;
    QString description;

    bool operator==(const TransportFailure&) const = default;
};

}

Q_DECLARE_METATYPE(infrastructure::transport::TransportFailure)
