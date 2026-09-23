#include "application/world/world_session_service.h"

#include "protocol/binary/adler32.h"
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

}

void WorldSessionServiceTest::completesHandshakeAndPublishesFirstPayload() {
	QTcpServer server;
	QVERIFY(server.listen(QHostAddress::LocalHost));
	WorldSessionService service;
	QSignalSpy payloadSpy(&service, &WorldSessionService::sessionPayloadReceived);
	QSignalSpy failureSpy(&service, &WorldSessionService::failureOccurred);
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

	const std::vector<std::byte> firstPayload { std::byte { 0xAA }, std::byte { 0xBB } };
	const auto firstPacket = protocol::framing::encodeModernSessionPacket(firstPayload, sessionKey, 1);
	QCOMPARE(firstPacket.status, protocol::framing::ModernSessionStatus::Ready);
	const auto firstPacketBytes = toByteArray(firstPacket.bytes);
	QCOMPARE(peer->write(firstPacketBytes), static_cast<qint64>(firstPacketBytes.size()));
	QVERIFY(peer->waitForBytesWritten());

	QTRY_COMPARE(payloadSpy.count(), 1);
	QCOMPARE(service.state(), WorldSessionState::Active);
	QCOMPARE(payloadSpy.first().first().toByteArray(), QByteArray::fromHex("aabb"));
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
