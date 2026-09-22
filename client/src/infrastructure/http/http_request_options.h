#pragma once

#include <QUrl>

#include <chrono>
#include <cstddef>

namespace infrastructure::http {

	struct HttpRequestOptions {
		QUrl endpoint;
		std::chrono::milliseconds deadline { 5000 };
		std::size_t maximumResponseBytes = 1024 * 1024;
	};

}
