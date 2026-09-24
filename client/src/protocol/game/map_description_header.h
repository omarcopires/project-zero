#pragma once

#include "protocol/game/world_position.h"

#include <cstddef>

namespace protocol::game {

	struct MapDescriptionHeader {
		WorldPosition center;
		std::size_t bytesConsumed = 0;
	};

}
