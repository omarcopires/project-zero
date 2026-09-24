#pragma once

#include <cstdint>

namespace protocol::game {

	enum class CreatureWireType : std::uint8_t {
		Player = 0,
		Monster = 1,
		Npc = 2,
		SummonPlayer = 3,
		SummonOther = 4,
		Hidden = 5,
	};

}
