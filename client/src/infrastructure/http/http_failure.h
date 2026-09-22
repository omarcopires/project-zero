#pragma once

#include "infrastructure/http/http_error.h"

#include <QMetaType>
#include <QString>

namespace infrastructure::http {

	struct HttpFailure {
		HttpError error;
		QString description;

		bool operator==(const HttpFailure &) const = default;
	};

}

Q_DECLARE_METATYPE(infrastructure::http::HttpFailure)
