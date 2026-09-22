#include "session/authentication/authentication_coordinator.h"

#include <utility>

namespace session::authentication {

	std::optional<AuthenticationAttempt> AuthenticationCoordinator::begin() {
		if (m_state == AuthenticationState::Authenticating) {
			return std::nullopt;
		}

		m_activeAttempt = AuthenticationAttempt { .id = m_nextAttemptId++ };
		m_authenticatedSession.reset();
		m_failureReason = AuthenticationFailureReason::None;
		m_state = AuthenticationState::Authenticating;
		return m_activeAttempt;
	}

	bool AuthenticationCoordinator::cancel(const AuthenticationAttempt attempt) {
		if (!isCurrent(attempt)) {
			return false;
		}

		clearActiveAttempt();
		m_state = AuthenticationState::Cancelled;
		return true;
	}

	bool AuthenticationCoordinator::complete(const AuthenticationAttempt attempt, LoginResponse response) {
		if (!isCurrent(attempt)) {
			return false;
		}

		clearActiveAttempt();
		switch (response.status) {
			case LoginResponseStatus::Success:
				m_authenticatedSession = std::move(response);
				m_state = AuthenticationState::Authenticated;
				break;
			case LoginResponseStatus::AuthenticationRejected:
				m_state = AuthenticationState::Rejected;
				break;
			case LoginResponseStatus::UnsupportedChallenge:
				m_state = AuthenticationState::UnsupportedChallenge;
				break;
			case LoginResponseStatus::InvalidResponse:
				m_failureReason = AuthenticationFailureReason::IncompatibleResponse;
				m_state = AuthenticationState::Failed;
				break;
		}
		return true;
	}

	bool AuthenticationCoordinator::fail(const AuthenticationAttempt attempt, const AuthenticationFailureReason reason) {
		if (!isCurrent(attempt) || reason == AuthenticationFailureReason::None || reason == AuthenticationFailureReason::IncompatibleResponse) {
			return false;
		}

		clearActiveAttempt();
		m_failureReason = reason;
		m_state = AuthenticationState::Failed;
		return true;
	}

	AuthenticationState AuthenticationCoordinator::state() const {
		return m_state;
	}

	AuthenticationFailureReason AuthenticationCoordinator::failureReason() const {
		return m_failureReason;
	}

	std::optional<AuthenticationAttempt> AuthenticationCoordinator::activeAttempt() const {
		return m_activeAttempt;
	}

	const LoginResponse* AuthenticationCoordinator::authenticatedSession() const {
		return m_authenticatedSession ? &*m_authenticatedSession : nullptr;
	}

	bool AuthenticationCoordinator::isCurrent(const AuthenticationAttempt attempt) const {
		return m_state == AuthenticationState::Authenticating && m_activeAttempt == attempt;
	}

	void AuthenticationCoordinator::clearActiveAttempt() {
		m_activeAttempt.reset();
	}

}
