#include "application/world/world_session_service.h"

#include "protocol/framing/modern_frame.h"
#include "protocol/framing/modern_session_codec.h"
#include "protocol/game/game_server_opcode.h"
#include "protocol/game/initial_world_response_codec.h"
#include "protocol/game/map_description_codec.h"
#include "protocol/game/map_description_header_codec.h"
#include "protocol/handshake/world_challenge_codec.h"
#include "protocol/handshake/world_login_packet_codec.h"

#include <cstddef>
#include <optional>
#include <span>
#include <utility>

namespace application::world {
	namespace {

		constexpr std::uint32_t maximumSequence = 0x7FFFFFFFU;

		QByteArray toByteArray(const std::vector<std::byte> &bytes) {
			return {
				reinterpret_cast<const char*>(bytes.data()),
				static_cast<qsizetype>(bytes.size()),
			};
		}

		std::optional<std::size_t> findLoginSuccessOffset(const std::span<const std::byte> bytes) {
			for (std::size_t offset = 0; offset < bytes.size(); ++offset) {
				if (std::to_integer<std::uint8_t>(bytes[offset]) != 0x17) {
					continue;
				}
				const auto response = protocol::game::decodeInitialWorldResponse(bytes.subspan(offset));
				if (response.status != protocol::game::InitialWorldResponseStatus::Ready
				    || response.kind != protocol::game::InitialWorldResponseKind::LoginSuccess
				    || response.playerId == 0 || response.serverBeat != 50) {
					continue;
				}
				const auto nextOffset = offset + response.bytesConsumed;
				if (nextOffset == bytes.size()
				    || std::to_integer<std::uint8_t>(bytes[nextOffset]) == 0x1A) {
					return offset;
				}
			}
			return std::nullopt;
		}

	}

	WorldSessionService::WorldSessionService(QObject* parent) :
		QObject(parent),
		m_transport(new infrastructure::transport::TcpTransport(this)) {
		qRegisterMetaType<WorldSessionState>();
		qRegisterMetaType<WorldSessionError>();
		qRegisterMetaType<WorldSessionFailure>();
		qRegisterMetaType<protocol::game::MapDescription>();
		connect(m_transport, &infrastructure::transport::TcpTransport::connected, this, &WorldSessionService::handleConnected);
		connect(m_transport, &infrastructure::transport::TcpTransport::dataAvailable, this, &WorldSessionService::handleDataAvailable);
		connect(m_transport, &infrastructure::transport::TcpTransport::failureOccurred, this, &WorldSessionService::handleTransportFailure);
		connect(m_transport, &infrastructure::transport::TcpTransport::disconnected, this, &WorldSessionService::handleDisconnected);
	}

	WorldSessionService::WorldSessionService(
		std::shared_ptr<const assets::AppearanceCatalog> appearanceCatalog,
		QObject* parent) :
		WorldSessionService(parent) {
		m_appearanceCatalog = std::move(appearanceCatalog);
	}

	bool WorldSessionService::start(const WorldSessionRequest &request) {
		if (m_state != WorldSessionState::Idle && m_state != WorldSessionState::Closed
		    && m_state != WorldSessionState::Failed && m_state != WorldSessionState::Waiting) {
			return false;
		}
		if (!requestIsValid(request)) {
			fail(WorldSessionError::InvalidRequest, QStringLiteral("World session request is invalid"));
			return false;
		}

		m_request = request;
		m_input.clear();
		m_expectedIncomingSequence = 1;
		setState(WorldSessionState::Connecting);
		m_transport->connectToHost(request.connection);
		return true;
	}

	void WorldSessionService::close() {
		if (m_state == WorldSessionState::Closed) {
			return;
		}
		m_transport->close();
		m_input.clear();
		m_request = {};
		setState(WorldSessionState::Closed);
	}

	WorldSessionState WorldSessionService::state() const {
		return m_state;
	}

	void WorldSessionService::handleConnected() {
		if (m_state == WorldSessionState::Connecting) {
			setState(WorldSessionState::AwaitingChallenge);
		}
	}

	void WorldSessionService::handleDataAvailable() {
		const auto incoming = m_transport->takeBufferedInput();
		if (incoming.isEmpty()) {
			return;
		}
		const auto* begin = reinterpret_cast<const std::byte*>(incoming.constData());
		m_input.insert(m_input.end(), begin, begin + incoming.size());
		processInput();
	}

	void WorldSessionService::handleTransportFailure() {
		if (m_state != WorldSessionState::Failed && m_state != WorldSessionState::Closed
		    && m_state != WorldSessionState::Waiting) {
			fail(WorldSessionError::Transport, QStringLiteral("World transport failed"));
		}
	}

	void WorldSessionService::handleDisconnected() {
		if (m_state != WorldSessionState::Failed && m_state != WorldSessionState::Closed
		    && m_state != WorldSessionState::Waiting) {
			setState(WorldSessionState::Closed);
		}
	}

	void WorldSessionService::processInput() {
		while (!m_input.empty() && m_state != WorldSessionState::Failed && m_state != WorldSessionState::Closed) {
			const auto frame = protocol::framing::decodeModernFrame(m_input);
			if (frame.status == protocol::framing::FrameDecodeStatus::NeedMoreData) {
				return;
			}
			if (frame.status != protocol::framing::FrameDecodeStatus::FrameReady) {
				fail(WorldSessionError::InvalidFrame, QStringLiteral("World frame is invalid"));
				return;
			}

			const auto handled = m_state == WorldSessionState::AwaitingChallenge
				? processChallenge(frame.body)
				: processSessionPacket(frame.body);
			if (!handled) {
				return;
			}
			m_input.erase(m_input.begin(), m_input.begin() + static_cast<std::ptrdiff_t>(frame.bytesConsumed));
		}
	}

	bool WorldSessionService::processChallenge(const std::span<const std::byte> body) {
		const auto challenge = protocol::handshake::decodeWorldChallenge(body);
		if (challenge.status != protocol::handshake::WorldChallengeStatus::Ready) {
			fail(WorldSessionError::InvalidChallenge, QStringLiteral("World challenge is invalid"));
			return false;
		}

		protocol::handshake::WorldLoginPacketRequest loginRequest;
		loginRequest.assetHashIdentifier = m_request.assetHashIdentifier;
		loginRequest.loginBlock.xteaKey = m_request.xteaKey;
		loginRequest.loginBlock.sessionKey = m_request.sessionKey;
		loginRequest.loginBlock.characterName = m_request.characterName;
		loginRequest.loginBlock.challenge = challenge.challenge.value();
		const auto loginPacket = protocol::handshake::encodeWorldLoginPacket(loginRequest);
		if (loginPacket.status != protocol::handshake::WorldLoginPacketStatus::Ready) {
			fail(WorldSessionError::LoginEncodingFailed, QStringLiteral("World login packet could not be encoded"));
			return false;
		}
		if (!m_transport->send(toByteArray(loginPacket.bytes))) {
			fail(WorldSessionError::LoginSendFailed, QStringLiteral("World login packet could not be sent"));
			return false;
		}
		setState(WorldSessionState::AwaitingSessionPacket);
		return true;
	}

	bool WorldSessionService::processSessionPacket(const std::span<const std::byte> body) {
		if (m_state != WorldSessionState::AwaitingSessionPacket
		    && m_state != WorldSessionState::LoginAccepted
		    && m_state != WorldSessionState::Active) {
			fail(WorldSessionError::InvalidFrame, QStringLiteral("World frame arrived in an invalid state"));
			return false;
		}
		const auto decoded = protocol::framing::decodeModernSessionBody(body, m_request.xteaKey, m_expectedIncomingSequence);
		if (decoded.status != protocol::framing::ModernSessionStatus::Ready) {
			fail(WorldSessionError::InvalidSessionPacket,
				QStringLiteral("Encrypted world session packet is invalid (codec status %1)")
					.arg(static_cast<int>(decoded.status)));
			return false;
		}

		m_expectedIncomingSequence = m_expectedIncomingSequence == maximumSequence ? 1 : m_expectedIncomingSequence + 1;
		const auto payload = toByteArray(decoded.bytes);
		const auto response = protocol::game::decodeInitialWorldResponse(decoded.bytes);
		if (m_state == WorldSessionState::Active) {
			if (!processMapDescriptionHeader(decoded.bytes)) {
				return false;
			}
			if (decoded.bytes.empty()
			    || static_cast<protocol::game::GameServerOpcode>(std::to_integer<std::uint8_t>(decoded.bytes.front()))
			        != protocol::game::GameServerOpcode::SessionEnd) {
				emit sessionPayloadReceived(payload);
				return true;
			}
			if (response.status == protocol::game::InitialWorldResponseStatus::Truncated) {
				fail(WorldSessionError::InvalidSessionPacket, QStringLiteral("World session end response is truncated"));
				return false;
			}
			if (response.status == protocol::game::InitialWorldResponseStatus::Ready
			    && response.kind == protocol::game::InitialWorldResponseKind::SessionEnd) {
				setState(WorldSessionState::Closed);
				m_transport->close();
				m_request = {};
				emit sessionEnded(response.sessionEndReason);
				emit sessionPayloadReceived(payload);
				return true;
			}
			emit sessionPayloadReceived(payload);
			return true;
		}

		if (decoded.bytes.empty()) {
			fail(WorldSessionError::InvalidSessionPacket, QStringLiteral("Initial world response is empty"));
			return false;
		}
		std::size_t offset = 0;
		if (m_state == WorldSessionState::AwaitingSessionPacket) {
			const auto firstOpcode = std::to_integer<std::uint8_t>(decoded.bytes.front());
			const bool directLoginResponse = firstOpcode == 0x11 || firstOpcode == 0x14
			    || firstOpcode == 0x15 || firstOpcode == 0x16 || firstOpcode == 0x18;
			if (!directLoginResponse) {
				const auto loginOffset = findLoginSuccessOffset(decoded.bytes);
				if (!loginOffset) {
					// Canary can send resource, stat, container and other world updates before login success.
					emit sessionPayloadReceived(payload);
					return true;
				}
				offset = *loginOffset;
			}
		}
		while (offset < decoded.bytes.size()) {
			const auto event = protocol::game::decodeInitialWorldResponse(
				std::span<const std::byte>(decoded.bytes).subspan(offset));
			if (event.status != protocol::game::InitialWorldResponseStatus::Ready) {
				if (m_state == WorldSessionState::LoginAccepted
				    && event.status == protocol::game::InitialWorldResponseStatus::UnsupportedOpcode) {
					break;
				}
				fail(WorldSessionError::InvalidSessionPacket,
					QStringLiteral("Initial world response is invalid or unsupported (status %1, opcode 0x%2, offset %3)")
						.arg(static_cast<int>(event.status))
						.arg(static_cast<qulonglong>(std::to_integer<std::uint8_t>(decoded.bytes[offset])), 2, 16, QChar('0'))
						.arg(static_cast<qulonglong>(offset)));
				return false;
			}

			offset += event.bytesConsumed;
			switch (event.kind) {
				case protocol::game::InitialWorldResponseKind::LoginSuccess:
					setState(WorldSessionState::LoginAccepted);
					emit loginAccepted(event.playerId, event.serverBeat);
					break;
				case protocol::game::InitialWorldResponseKind::Pending:
					setState(WorldSessionState::LoginAccepted);
					break;
				case protocol::game::InitialWorldResponseKind::EnterWorld:
					setState(WorldSessionState::Active);
					break;
				case protocol::game::InitialWorldResponseKind::LoginAdvice:
					emit loginAdviceReceived(QString::fromStdString(event.message));
					break;
				case protocol::game::InitialWorldResponseKind::LoginWait:
					setState(WorldSessionState::Waiting);
					emit loginWaitReceived(QString::fromStdString(event.message), event.waitSeconds);
					emit sessionPayloadReceived(payload);
					return true;
				case protocol::game::InitialWorldResponseKind::LoginError:
					fail(WorldSessionError::ServerRejected, QString::fromStdString(event.message));
					return false;
				case protocol::game::InitialWorldResponseKind::UpdateNeeded:
					fail(WorldSessionError::UpdateRequired, QString::fromStdString(event.message));
					return false;
				case protocol::game::InitialWorldResponseKind::SessionEnd:
					setState(WorldSessionState::Closed);
					m_transport->close();
					m_request = {};
					emit sessionEnded(event.sessionEndReason);
					emit sessionPayloadReceived(payload);
					return true;
				case protocol::game::InitialWorldResponseKind::Auxiliary:
					break;
			}
			if (m_state == WorldSessionState::Active) {
				if (offset < decoded.bytes.size()
				    && !processMapDescriptionHeader(std::span<const std::byte>(decoded.bytes).subspan(offset))) {
					return false;
				}
				break;
			}
		}
		emit sessionPayloadReceived(payload);
		return true;
	}

	bool WorldSessionService::processMapDescriptionHeader(const std::span<const std::byte> payload) {
		if (payload.empty()
		    || static_cast<protocol::game::GameServerOpcode>(std::to_integer<std::uint8_t>(payload.front()))
		        != protocol::game::GameServerOpcode::MapDescription) {
			return true;
		}

		const auto header = protocol::game::decodeMapDescriptionHeader(payload);
		if (!header) {
			fail(WorldSessionError::InvalidMapDescription, QStringLiteral("Initial map description header is invalid"));
			return false;
		}
		if (m_appearanceCatalog) {
			const auto decoded = protocol::game::decodeMapDescription(
				payload,
				[this](const assets::AppearanceKind kind, const std::uint32_t id) {
					return m_appearanceCatalog->find(kind, id);
				});
			if (decoded.status != protocol::game::MapDescriptionDecodeStatus::Ready) {
				fail(WorldSessionError::InvalidMapDescription,
					QStringLiteral("Initial map tile data is invalid or unsupported (status %1, decoded tiles %2)")
						.arg(static_cast<int>(decoded.status))
						.arg(static_cast<qulonglong>(decoded.description.tiles.size())));
				return false;
			}
			emit initialMapDescriptionReceived(decoded.description);
		}
		emit initialMapPositionReceived(header->center.x, header->center.y, header->center.floor);
		return true;
	}

	void WorldSessionService::setState(const WorldSessionState state) {
		if (m_state == state) {
			return;
		}
		m_state = state;
		emit stateChanged(m_state);
	}

	void WorldSessionService::fail(const WorldSessionError error, QString description) {
		if (m_state == WorldSessionState::Failed) {
			return;
		}
		setState(WorldSessionState::Failed);
		m_transport->close();
		m_input.clear();
		m_request = {};
		emit failureOccurred({ .error = error, .description = std::move(description) });
	}

	bool WorldSessionService::requestIsValid(const WorldSessionRequest &request) const {
		return !request.connection.host.trimmed().isEmpty()
		    && request.connection.port != 0
		    && !request.sessionKey.empty()
		    && !request.characterName.empty();
	}

}
