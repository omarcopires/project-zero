#pragma once

namespace application::world {

	enum class WorldSessionState {
		Idle,
		Connecting,
		AwaitingChallenge,
		AwaitingSessionPacket,
		Active,
		Failed,
		Closed,
	};

}
