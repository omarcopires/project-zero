#pragma once

#include "session/authentication/login_request.h"
#include "session/authentication/login_response.h"

#include <QByteArray>

#include <optional>

namespace session::authentication {

	std::optional<QByteArray> encodeLoginRequest(const LoginRequest &request);
	LoginResponse decodeLoginResponse(const QByteArray &responseBody);

}
