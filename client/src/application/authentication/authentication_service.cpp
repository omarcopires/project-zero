#include "application/authentication/authentication_service.h"

#include "infrastructure/http/http_error.h"
#include "session/authentication/authentication_failure_reason.h"
#include "session/authentication/login_codec.h"

namespace application::authentication {

	using infrastructure::http::HttpError;
	using session::authentication::AuthenticationFailureReason;
	using session::authentication::AuthenticationState;

	AuthenticationService::AuthenticationService(QObject* parent) : QObject(parent), m_transport(new infrastructure::http::HttpTransport(this)) {
		qRegisterMetaType<AuthenticationState>();
		connect(m_transport, &infrastructure::http::HttpTransport::completed, this, &AuthenticationService::handleCompleted);
		connect(m_transport, &infrastructure::http::HttpTransport::failureOccurred, this, &AuthenticationService::handleFailure);
	}

	bool AuthenticationService::authenticate(
		const infrastructure::http::HttpRequestOptions &options,
		const session::authentication::LoginRequest &request
	) {
		const auto encodedRequest = session::authentication::encodeLoginRequest(request);
		if (!encodedRequest.has_value()) {
			return false;
		}

		const auto attempt = m_coordinator.begin();
		if (!attempt.has_value()) {
			return false;
		}

		publishState();
		m_transport->postJson(options, *encodedRequest);
		return true;
	}

	void AuthenticationService::cancel() {
		const auto attempt = m_coordinator.activeAttempt();
		if (!attempt.has_value() || !m_coordinator.cancel(*attempt)) {
			return;
		}

		m_transport->cancel();
		publishState();
	}

	AuthenticationState AuthenticationService::state() const {
		return m_coordinator.state();
	}

	const session::authentication::LoginResponse* AuthenticationService::authenticatedSession() const {
		return m_coordinator.authenticatedSession();
	}

	void AuthenticationService::handleCompleted(const infrastructure::http::HttpResponse &response) {
		const auto attempt = m_coordinator.activeAttempt();
		if (!attempt.has_value()) {
			return;
		}

		m_coordinator.complete(*attempt, session::authentication::decodeLoginResponse(response.body));
		publishState();
	}

	void AuthenticationService::handleFailure(const infrastructure::http::HttpFailure &failure) {
		const auto attempt = m_coordinator.activeAttempt();
		if (!attempt.has_value()) {
			return;
		}

		const auto reason = failure.error == HttpError::Timeout ? AuthenticationFailureReason::Timeout : AuthenticationFailureReason::Transport;
		m_coordinator.fail(*attempt, reason);
		publishState();
	}

	void AuthenticationService::publishState() {
		emit stateChanged(m_coordinator.state());
	}

}
