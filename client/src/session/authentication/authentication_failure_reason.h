#pragma once

namespace session::authentication {

	enum class AuthenticationFailureReason {
		None,
		Transport,
		Timeout,
		IncompatibleResponse,
	};

}
