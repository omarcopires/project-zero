#pragma once

#include "protocol/game/map_tile.h"
#include "protocol/game/world_position.h"

#include <cstddef>
#include <vector>

namespace protocol::game {

	struct MapDescription {
		WorldPosition center;
		std::vector<MapTile> tiles;
		std::size_t bytesConsumed = 0;
	};

}
