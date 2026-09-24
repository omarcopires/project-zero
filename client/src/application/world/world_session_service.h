#pragma once

#include "application/world/world_session_failure.h"
#include "application/world/world_session_request.h"
#include "application/world/world_session_state.h"
#include "infrastructure/transport/tcp_transport.h"

#include <QByteArray>
#include <QMetaType>
#include <QObject>

#include <cstddef>
#include <cstdint>
#include <span>
#include <vector>

Q_DECLARE_METATYPE(application::world::WorldSessionState)
Q_DECLARE_METATYPE(application::world::WorldSessionError)
Q_DECLARE_METATYPE(application::world::WorldSessionFailure)

namespace application::world {

	class WorldSessionService final : public QObject {
		Q_OBJECT

	public:
		explicit WorldSessionService(QObject* parent = nullptr);

		[[nodiscard]] bool start(const WorldSessionRequest &request);
		void close();
		[[nodiscard]] WorldSessionState state() const;

	signals:
		void stateChanged(application::world::WorldSessionState state);
		void sessionPayloadReceived(const QByteArray &payload);
		void loginAccepted(std::uint32_t playerId, std::uint16_t serverBeat);
		void loginAdviceReceived(const QString &message);
		void loginWaitReceived(const QString &message, std::uint8_t retrySeconds);
		void failureOccurred(const application::world::WorldSessionFailure &failure);

	private:
		void handleConnected();
		void handleDataAvailable();
		void handleTransportFailure();
		void handleDisconnected();
		void processInput();
		bool processChallenge(std::span<const std::byte> body);
		bool processSessionPacket(std::span<const std::byte> body);
		void setState(WorldSessionState state);
		void fail(WorldSessionError error, QString description);
		bool requestIsValid(const WorldSessionRequest &request) const;

		infrastructure::transport::TcpTransport* m_transport;
		WorldSessionState m_state = WorldSessionState::Idle;
		WorldSessionRequest m_request;
		std::vector<std::byte> m_input;
		std::uint32_t m_expectedIncomingSequence = 1;
	};

}
