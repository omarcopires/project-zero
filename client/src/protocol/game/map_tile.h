#pragma once

#include "protocol/game/map_thing.h"
#include "protocol/game/world_position.h"

#include <vector>

namespace protocol::game {

	struct MapTile {
		WorldPosition position;
		std::vector<MapThing> things;
	};

}
