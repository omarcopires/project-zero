#pragma once

#include "session/authentication/login_character.h"
#include "session/authentication/login_response_status.h"
#include "session/authentication/login_world.h"

#include <string>
#include <vector>

namespace session::authentication {

	struct LoginResponse {
		LoginResponseStatus status = LoginResponseStatus::InvalidResponse;
		std::string sessionKey;
		std::vector<LoginWorld> worlds;
		std::vector<LoginCharacter> characters;
	};

}
