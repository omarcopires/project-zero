#pragma once

namespace protocol::handshake {

	enum class WorldChallengeStatus {
		Ready,
		InvalidLength,
		InvalidChecksum,
		InvalidPadding,
		InvalidOpcode,
		InvalidTrailer,
	};

}
