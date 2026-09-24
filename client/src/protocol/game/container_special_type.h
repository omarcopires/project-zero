#pragma once

#include <cstdint>

namespace protocol::game {

	enum class ContainerSpecialType : std::uint8_t {
		None = 0,
		LootContainer = 1,
		ContentCounter = 2,
		LootHighlight = 4,
		Obtain = 8,
		Manager = 9,
		QuiverLoot = 11,
	};

}
