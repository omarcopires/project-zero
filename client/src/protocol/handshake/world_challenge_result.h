#pragma once

#include "protocol/handshake/world_challenge.h"
#include "protocol/handshake/world_challenge_status.h"

#include <optional>

namespace protocol::handshake {

	struct WorldChallengeResult {
		WorldChallengeStatus status = WorldChallengeStatus::InvalidLength;
		std::optional<WorldChallenge> challenge;
	};

}
