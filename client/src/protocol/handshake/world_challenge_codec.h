#pragma once

#include "protocol/constants/world_handshake_constants.h"
#include "protocol/handshake/world_challenge_result.h"

#include <cstddef>
#include <span>

namespace protocol::handshake {

	inline constexpr std::size_t modernWorldChallengeBodySize = constants::modernWorldChallengeBodySize;

	WorldChallengeResult decodeWorldChallenge(std::span<const std::byte> body);

}
