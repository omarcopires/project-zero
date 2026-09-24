#pragma once

#include <cstdint>

namespace protocol::game {

	struct WorldPosition {
		std::uint16_t x = 0;
		std::uint16_t y = 0;
		std::uint8_t floor = 0;
	};

}
