#pragma once

#include "session/authentication/authentication_attempt.h"
#include "session/authentication/authentication_failure_reason.h"
#include "session/authentication/authentication_state.h"
#include "session/authentication/login_response.h"

#include <cstdint>
#include <optional>

namespace session::authentication {

	class AuthenticationCoordinator final {
	public:
		std::optional<AuthenticationAttempt> begin();
		bool cancel(AuthenticationAttempt attempt);
		bool complete(AuthenticationAttempt attempt, LoginResponse response);
		bool fail(AuthenticationAttempt attempt, AuthenticationFailureReason reason);

		AuthenticationState state() const;
		AuthenticationFailureReason failureReason() const;
		std::optional<AuthenticationAttempt> activeAttempt() const;
		const LoginResponse* authenticatedSession() const;

	private:
		bool isCurrent(AuthenticationAttempt attempt) const;
		void clearActiveAttempt();

		AuthenticationState m_state = AuthenticationState::Idle;
		AuthenticationFailureReason m_failureReason = AuthenticationFailureReason::None;
		std::optional<AuthenticationAttempt> m_activeAttempt;
		std::optional<LoginResponse> m_authenticatedSession;
		std::uint64_t m_nextAttemptId = 1;
	};

}
