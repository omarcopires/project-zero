#pragma once

#include "protocol/game/map_tile_terminator.h"

#include <cstddef>
#include <span>

namespace protocol::game {

	MapTileTerminator decodeMapTileTerminator(std::span<const std::byte> payload);

}
