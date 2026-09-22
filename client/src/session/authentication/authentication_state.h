#pragma once

namespace session::authentication {

	enum class AuthenticationState {
		Idle,
		Authenticating,
		Authenticated,
		Rejected,
		UnsupportedChallenge,
		Failed,
		Cancelled,
	};

}
