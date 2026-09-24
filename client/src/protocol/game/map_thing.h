#pragma once

#include "protocol/game/map_thing_kind.h"

#include <cstdint>

namespace protocol::game {

	struct MapThing {
		MapThingKind kind = MapThingKind::Object;
		std::uint32_t id = 0;
		std::uint32_t appearanceId = 0;
		std::uint8_t count = 0;
		std::uint8_t subtype = 0;
		std::uint8_t tier = 0;
		bool appearanceIsObject = false;
	};

}
