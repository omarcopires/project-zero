#pragma once

#include <cstdint>

namespace protocol::game {

	enum class GameServerThingMarker : std::uint16_t {
		UnknownCreature = 0x0061,
		KnownCreature = 0x0062,
		CreatureUpdate = 0x0063,
	};

}
