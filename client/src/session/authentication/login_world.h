#pragma once

#include <cstdint>
#include <string>

namespace session::authentication {

	struct LoginWorld {
		int id = -1;
		std::string name;
		std::string host;
		std::uint16_t port = 0;

		bool operator==(const LoginWorld &) const = default;
	};

}
