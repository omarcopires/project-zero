#pragma once

#include <string>

namespace session::authentication {

	struct LoginRequest {
		std::string email;
		std::string password;
	};

}
