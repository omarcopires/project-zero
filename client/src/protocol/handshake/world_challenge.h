#pragma once

#include <cstdint>

namespace protocol::handshake {

	struct WorldChallenge {
		std::uint32_t timestamp = 0;
		std::uint8_t random = 0;

		bool operator==(const WorldChallenge &) const = default;
	};

}
