#pragma once

#include "protocol/game/map_description_header.h"

#include <cstddef>
#include <optional>
#include <span>

namespace protocol::game {

	std::optional<MapDescriptionHeader> decodeMapDescriptionHeader(std::span<const std::byte> payload);

}
