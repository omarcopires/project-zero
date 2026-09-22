#pragma once

#include "infrastructure/http/http_failure.h"
#include "infrastructure/http/http_request_options.h"
#include "infrastructure/http/http_response.h"
#include "infrastructure/http/http_transport.h"
#include "session/authentication/authentication_coordinator.h"
#include "session/authentication/authentication_state.h"
#include "session/authentication/login_request.h"
#include "session/authentication/login_response.h"

#include <QMetaType>
#include <QObject>

Q_DECLARE_METATYPE(session::authentication::AuthenticationState)

namespace application::authentication {

	class AuthenticationService final : public QObject {
		Q_OBJECT

	public:
		explicit AuthenticationService(QObject* parent = nullptr);

		bool authenticate(const infrastructure::http::HttpRequestOptions &options, const session::authentication::LoginRequest &request);
		void cancel();

		session::authentication::AuthenticationState state() const;
		const session::authentication::LoginResponse* authenticatedSession() const;

	signals:
		void stateChanged(session::authentication::AuthenticationState state);

	private:
		void handleCompleted(const infrastructure::http::HttpResponse &response);
		void handleFailure(const infrastructure::http::HttpFailure &failure);
		void publishState();

		infrastructure::http::HttpTransport* m_transport;
		session::authentication::AuthenticationCoordinator m_coordinator;
	};

}
