#pragma once

#include "protocol/game/map_tile_terminator_status.h"

#include <cstddef>
#include <cstdint>

namespace protocol::game {

	struct MapTileTerminator {
		MapTileTerminatorStatus status;
		std::uint8_t emptyTileCount;
		std::size_t bytesConsumed;
	};

}
