#include "application/world/world_session_service.h"

#include "assets/appearance_catalog.h"
#include "protocol/binary/adler32.h"
#include "protocol/binary/length_prefixed_string.h"
#include "protocol/binary/little_endian.h"
#include "protocol/constants/world_handshake_constants.h"
#include "protocol/framing/modern_frame.h"
#include "protocol/framing/modern_session_codec.h"

#include <QHostAddress>
#include <QSignalSpy>
#include <QTcpServer>
#include <QTcpSocket>
#include <QtTest>

#include <chrono>
#include <cstddef>
#include <memory>
#include <span>
#include <vector>

using application::world::WorldSessionError;
using application::world::WorldSessionFailure;
using application::world::WorldSessionRequest;
using application::world::WorldSessionService;
using application::world::WorldSessionState;

class WorldSessionServiceTest final : public QObject {
	Q_OBJECT

private slots:
	void completesHandshakeAndPublishesFirstPayload();
	void ignoresPreLoginWorldUpdatesUntilLoginSuccess();
	void buffersFragmentedChallenge();
	void rejectsMalformedChallenge();
	void rejectsConcurrentStart();
};

namespace {

	constexpr protocol::crypto::XteaKey sessionKey { 0x01020304U, 0x11121314U, 0x21222324U, 0x31323334U };

	QByteArray toByteArray(const std::vector<std::byte> &bytes) {
		return { reinterpret_cast<const char*>(bytes.data()), static_cast<qsizetype>(bytes.size()) };
	}

	WorldSessionRequest requestFor(const QTcpServer &server) {
		WorldSessionRequest request;
		request.connection.host = QStringLiteral("127.0.0.1");
		request.connection.port = server.serverPort();
		request.connection.connectionTimeout = std::chrono::milliseconds { 1000 };
		request.connection.inactivityTimeout = std::chrono::milliseconds { 5000 };
		request.sessionKey = "synthetic-session";
		request.characterName = "Synthetic Character";
		request.assetHashIdentifier = "test";
		request.xteaKey = sessionKey;
		return request;
	}

	QByteArray challengeFrame() {
		std::vector<std::byte> payload;
		payload.push_back(std::byte { protocol::constants::modernChallengePaddingMarker });
		payload.push_back(std::byte { protocol::constants::serverLoginChallengeOpcode });
		protocol::binary::appendU32(payload, 0x41424344U);
		payload.push_back(std::byte { 0x5A });
		payload.push_back(std::byte { protocol::constants::modernChallengeTrailer });

		std::vector<std::byte> body;
		protocol::binary::appendU32(body, protocol::binary::adler32(payload));
		body.insert(body.end(), payload.begin(), payload.end());
		const auto frame = protocol::framing::encodeModernFrame(body);
		return toByteArray(frame.bytes);
	}

	WorldSessionFailure failureFrom(const QSignalSpy &spy) {
		return qvariant_cast<WorldSessionFailure>(spy.first().first());
	}

	std::vector<std::byte> loginSuccessPayload() {
		std::vector<std::byte> payload { std::byte { 0x17 } };
		protocol::binary::appendU32(payload, 0x12345678U);
		protocol::binary::appendU16(payload, 50);
		for (int index = 0; index < 3; ++index) {
			payload.push_back(std::byte { 3 });
			protocol::binary::appendU32(payload, 0x80000000U);
		}
		payload.push_back(std::byte { 1 });
		payload.push_back(std::byte { 0 });
		const auto appended = protocol::binary::appendStringU16(payload, "https://store.invalid");
		Q_ASSERT(appended);
		protocol::binary::appendU16(payload, 25);
		payload.push_back(std::byte { 1 });
		return payload;
	}

	std::vector<std::byte> emptySurfaceMapDescription() {
		constexpr std::size_t tileCount = 18 * 14 * 8;
		std::vector<std::byte> payload { std::byte { 0x64 } };
		protocol::binary::appendU16(payload, 200);
		protocol::binary::appendU16(payload, 200);
		payload.push_back(std::byte { 7 });

		auto remaining = tileCount;
		while (remaining > 256) {
			protocol::binary::appendU16(payload, 0xFFFF);
			remaining -= 256;
		}
		protocol::binary::appendU16(payload, static_cast<std::uint16_t>(0xFF00U | (remaining - 1)));
		return payload;
	}

}

void WorldSessionServiceTest::completesHandshakeAndPublishesFirstPayload() {
	QTcpServer server;
	QVERIFY(server.listen(QHostAddress::LocalHost));
	WorldSessionService service(std::make_shared<const assets::AppearanceCatalog>(), nullptr);
	QSignalSpy payloadSpy(&service, &WorldSessionService::sessionPayloadReceived);
	QSignalSpy acceptedSpy(&service, &WorldSessionService::loginAccepted);
	QSignalSpy failureSpy(&service, &WorldSessionService::failureOccurred);
	QSignalSpy mapPositionSpy(&service, &WorldSessionService::initialMapPositionReceived);
	QSignalSpy mapDescriptionSpy(&service, &WorldSessionService::initialMapDescriptionReceived);
	QVERIFY(service.start(requestFor(server)));

	QTRY_VERIFY(server.hasPendingConnections());
	auto* peer = server.nextPendingConnection();
	const auto challenge = challengeFrame();
	QCOMPARE(peer->write(challenge), static_cast<qint64>(challenge.size()));
	QVERIFY(peer->waitForBytesWritten());
	QTRY_COMPARE(service.state(), WorldSessionState::AwaitingSessionPacket);
	QTRY_VERIFY(peer->bytesAvailable() > 0);
	const auto loginBytes = peer->readAll();
	const auto* loginBegin = reinterpret_cast<const std::byte*>(loginBytes.constData());
	const auto loginFrame = protocol::framing::decodeModernFrame(
		std::span<const std::byte>(loginBegin, static_cast<std::size_t>(loginBytes.size())));
	QCOMPARE(loginFrame.status, protocol::framing::FrameDecodeStatus::FrameReady);
	QCOMPARE(loginFrame.bytesConsumed, static_cast<std::size_t>(loginBytes.size()));

	const auto firstPayload = loginSuccessPayload();
	const auto firstPacket = protocol::framing::encodeModernSessionPacket(firstPayload, sessionKey, 1);
	QCOMPARE(firstPacket.status, protocol::framing::ModernSessionStatus::Ready);
	const auto firstPacketBytes = toByteArray(firstPacket.bytes);
	QCOMPARE(peer->write(firstPacketBytes), static_cast<qint64>(firstPacketBytes.size()));
	QVERIFY(peer->waitForBytesWritten());

	QTRY_COMPARE(payloadSpy.count(), 1);
	QCOMPARE(service.state(), WorldSessionState::LoginAccepted);
	QCOMPARE(payloadSpy.first().first().toByteArray(), toByteArray(firstPayload));
	QCOMPARE(acceptedSpy.count(), 1);
	QCOMPARE(acceptedSpy.first().at(0).toUInt(), 0x12345678U);
	QCOMPARE(acceptedSpy.first().at(1).toUInt(), 50U);
	QCOMPARE(failureSpy.count(), 0);

	std::vector<std::byte> enterWorldPayload { std::byte { 0x0F } };
	const auto mapDescription = emptySurfaceMapDescription();
	enterWorldPayload.insert(enterWorldPayload.end(), mapDescription.begin(), mapDescription.end());
	const auto enterWorldPacket = protocol::framing::encodeModernSessionPacket(enterWorldPayload, sessionKey, 2);
	QCOMPARE(enterWorldPacket.status, protocol::framing::ModernSessionStatus::Ready);
	const auto enterWorldPacketBytes = toByteArray(enterWorldPacket.bytes);
	QCOMPARE(peer->write(enterWorldPacketBytes), static_cast<qint64>(enterWorldPacketBytes.size()));
	QVERIFY(peer->waitForBytesWritten());

	QTRY_COMPARE(mapDescriptionSpy.count(), 1);
	QCOMPARE(service.state(), WorldSessionState::Active);
	QCOMPARE(mapPositionSpy.count(), 1);
	QCOMPARE(mapPositionSpy.first().at(0).toUInt(), 200U);
	const auto decodedMap = qvariant_cast<protocol::game::MapDescription>(mapDescriptionSpy.first().first());
	QCOMPARE(decodedMap.center.floor, 7);
	QCOMPARE(decodedMap.tiles.size(), static_cast<std::size_t>(18 * 14 * 8));
	QCOMPARE(decodedMap.bytesConsumed, mapDescription.size());
	QCOMPARE(failureSpy.count(), 0);
}

void WorldSessionServiceTest::ignoresPreLoginWorldUpdatesUntilLoginSuccess() {
	QTcpServer server;
	QVERIFY(server.listen(QHostAddress::LocalHost));
	WorldSessionService service;
	QSignalSpy acceptedSpy(&service, &WorldSessionService::loginAccepted);
	QSignalSpy failureSpy(&service, &WorldSessionService::failureOccurred);
	QSignalSpy payloadSpy(&service, &WorldSessionService::sessionPayloadReceived);
	QVERIFY(service.start(requestFor(server)));
	QTRY_VERIFY(server.hasPendingConnections());
	auto* peer = server.nextPendingConnection();
	const auto challenge = challengeFrame();
	QCOMPARE(peer->write(challenge), static_cast<qint64>(challenge.size()));
	QVERIFY(peer->waitForBytesWritten());
	QTRY_COMPARE(service.state(), WorldSessionState::AwaitingSessionPacket);
	QTRY_VERIFY(peer->bytesAvailable() > 0);
	peer->readAll();

	// Container updates can arrive in complete encrypted frames before the login response.
	const std::vector<std::byte> containerUpdate { std::byte { 0x6E }, std::byte { 0x17 }, std::byte { 0x00 } };
	const auto first = protocol::framing::encodeModernSessionPacket(containerUpdate, sessionKey, 1);
	QCOMPARE(first.status, protocol::framing::ModernSessionStatus::Ready);
	const auto firstBytes = toByteArray(first.bytes);
	QCOMPARE(peer->write(firstBytes), static_cast<qint64>(firstBytes.size()));
	QVERIFY(peer->waitForBytesWritten());
	QTRY_COMPARE(payloadSpy.count(), 1);
	QTRY_COMPARE(service.state(), WorldSessionState::AwaitingSessionPacket);
	QCOMPARE(failureSpy.count(), 0);
	QCOMPARE(acceptedSpy.count(), 0);

	// A server flush can also mix auxiliary updates and the complete login response.
	std::vector<std::byte> mixed { std::byte { 0x61 }, std::byte { 0x17 }, std::byte { 0x00 } };
	const auto success = loginSuccessPayload();
	mixed.insert(mixed.end(), success.begin(), success.end());
	mixed.push_back(std::byte { 0x1A });
	mixed.push_back(std::byte { 0x00 });
	const auto second = protocol::framing::encodeModernSessionPacket(mixed, sessionKey, 2);
	QCOMPARE(second.status, protocol::framing::ModernSessionStatus::Ready);
	const auto secondBytes = toByteArray(second.bytes);
	QCOMPARE(peer->write(secondBytes), static_cast<qint64>(secondBytes.size()));
	QVERIFY(peer->waitForBytesWritten());
	QTRY_COMPARE(acceptedSpy.count(), 1);
	QCOMPARE(service.state(), WorldSessionState::LoginAccepted);
	QCOMPARE(failureSpy.count(), 0);
}

void WorldSessionServiceTest::buffersFragmentedChallenge() {
	QTcpServer server;
	QVERIFY(server.listen(QHostAddress::LocalHost));
	WorldSessionService service;
	QVERIFY(service.start(requestFor(server)));
	QTRY_VERIFY(server.hasPendingConnections());
	auto* peer = server.nextPendingConnection();
	const auto challenge = challengeFrame();

	QCOMPARE(peer->write(challenge.first(5)), static_cast<qint64>(5));
	QVERIFY(peer->waitForBytesWritten());
	QTest::qWait(20);
	QCOMPARE(service.state(), WorldSessionState::AwaitingChallenge);
	QCOMPARE(peer->write(challenge.sliced(5)), static_cast<qint64>(challenge.size() - 5));
	QVERIFY(peer->waitForBytesWritten());
	QTRY_COMPARE(service.state(), WorldSessionState::AwaitingSessionPacket);
}

void WorldSessionServiceTest::rejectsMalformedChallenge() {
	QTcpServer server;
	QVERIFY(server.listen(QHostAddress::LocalHost));
	WorldSessionService service;
	QSignalSpy failureSpy(&service, &WorldSessionService::failureOccurred);
	QVERIFY(service.start(requestFor(server)));
	QTRY_VERIFY(server.hasPendingConnections());
	auto* peer = server.nextPendingConnection();
	auto challenge = challengeFrame();
	challenge[2] = static_cast<char>(challenge.at(2) ^ 0x01);

	QCOMPARE(peer->write(challenge), static_cast<qint64>(challenge.size()));
	QVERIFY(peer->waitForBytesWritten());
	QTRY_COMPARE(failureSpy.count(), 1);
	QCOMPARE(service.state(), WorldSessionState::Failed);
	QCOMPARE(failureFrom(failureSpy).error, WorldSessionError::InvalidChallenge);
}

void WorldSessionServiceTest::rejectsConcurrentStart() {
	QTcpServer server;
	QVERIFY(server.listen(QHostAddress::LocalHost));
	WorldSessionService service;
	const auto request = requestFor(server);
	QVERIFY(service.start(request));
	QVERIFY(!service.start(request));
	service.close();
	QCOMPARE(service.state(), WorldSessionState::Closed);
}

QTEST_GUILESS_MAIN(WorldSessionServiceTest)

#include "world_session_service_test.moc"
