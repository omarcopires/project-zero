#pragma once

#include <QByteArray>
#include <QMetaType>

namespace infrastructure::http {

	struct HttpResponse {
		int statusCode = 0;
		QByteArray body;

		bool operator==(const HttpResponse &) const = default;
	};

}

Q_DECLARE_METATYPE(infrastructure::http::HttpResponse)
