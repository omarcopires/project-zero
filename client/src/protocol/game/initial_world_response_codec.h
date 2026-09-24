#pragma once

#include "protocol/game/initial_world_response.h"

#include <cstddef>
#include <span>

namespace protocol::game {

	InitialWorldResponse decodeInitialWorldResponse(std::span<const std::byte> payload);

}
