#pragma once

#include <string>

namespace session::authentication {

	struct LoginCharacter {
		std::string name;
		int worldId = -1;

		bool operator==(const LoginCharacter &) const = default;
	};

}
