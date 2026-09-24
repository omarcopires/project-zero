#pragma once

namespace application::world {

	enum class WorldSessionState {
		Idle,
		Connecting,
		AwaitingChallenge,
		AwaitingSessionPacket,
		LoginAccepted,
		Waiting,
		Active,
		Failed,
		Closed,
	};

}
