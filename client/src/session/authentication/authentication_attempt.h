#pragma once

#include <cstdint>

namespace session::authentication {

	struct AuthenticationAttempt {
		std::uint64_t id = 0;

		bool operator==(const AuthenticationAttempt &) const = default;
	};

}
