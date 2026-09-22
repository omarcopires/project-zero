#pragma once

#include <QMetaType>

namespace infrastructure::http {

	enum class HttpError {
		InvalidConfiguration,
		OperationInProgress,
		Timeout,
		Cancelled,
		ResponseTooLarge,
		RedirectRejected,
		NetworkFailure,
	};

}

Q_DECLARE_METATYPE(infrastructure::http::HttpError)
