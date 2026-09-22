#pragma once

namespace session::authentication {

	enum class LoginResponseStatus {
		Success,
		AuthenticationRejected,
		UnsupportedChallenge,
		InvalidResponse,
	};

}
