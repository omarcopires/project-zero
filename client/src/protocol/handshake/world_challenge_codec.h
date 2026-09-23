#pragma once

#include "protocol/handshake/world_challenge_result.h"

#include <cstddef>
#include <span>

namespace protocol::handshake {

	inline constexpr std::size_t modernWorldChallengeBodySize = 12;

	WorldChallengeResult decodeWorldChallenge(std::span<const std::byte> body);

}
