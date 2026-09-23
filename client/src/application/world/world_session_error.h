#pragma once

namespace application::world {

	enum class WorldSessionError {
		InvalidRequest,
		Transport,
		InvalidFrame,
		InvalidChallenge,
		LoginEncodingFailed,
		LoginSendFailed,
		InvalidSessionPacket,
	};

}
