#pragma once

#include <cstdint>
#include <string>

namespace session::selection {

	struct WorldConnectionTarget {
		std::string sessionKey;
		std::string characterName;
		std::string worldName;
		std::string host;
		std::uint16_t port = 0;

		bool operator==(const WorldConnectionTarget &) const = default;
	};

}
