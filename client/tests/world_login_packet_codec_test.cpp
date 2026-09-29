#include "protocol/handshake/world_login_packet_codec.h"

#include "core/client_identity.h"
#include "protocol/binary/adler32.h"
#include "protocol/binary/little_endian.h"
#include "protocol/constants/world_handshake_constants.h"
#include "protocol/framing/modern_frame.h"

#include <gtest/gtest.h>

#include <algorithm>
#include <cstddef>
#include <cstdint>
#include <string>

namespace protocol::handshake {
	namespace {

		WorldLoginPacketRequest validRequest() {
			WorldLoginPacketRequest request;
			request.assetHashIdentifier = "test";
			request.loginBlock.xteaKey = { 0x01020304U, 0x11121314U, 0x21222324U, 0x31323334U };
			request.loginBlock.sessionKey = "session";
			request.loginBlock.characterName = "Knight";
			request.loginBlock.challenge = { .timestamp = 0x41424344U, .random = 0x5A };
			return request;
		}

		TEST(WorldLoginPacketCodec, EncodesConfirmedCurrentLayout) {
			const auto request = validRequest();
			const auto result = encodeWorldLoginPacket(request);
			const auto versionText = std::to_string(client::identity::version);

			ASSERT_EQ(result.status, WorldLoginPacketStatus::Ready);
			ASSERT_EQ(result.bytes.size(), 158);
			EXPECT_EQ(binary::readU16(result.bytes, 0).value(), 19);

			const auto decoded = framing::decodeModernFrame(result.bytes);
			ASSERT_EQ(decoded.status, framing::FrameDecodeStatus::FrameReady);
			ASSERT_EQ(decoded.body.size(), 156);
			EXPECT_EQ(binary::readU32(decoded.body, 0).value(), binary::adler32(decoded.body.subspan(constants::checksumSize)));
			EXPECT_EQ(binary::readU16(decoded.body, 4).value(), constants::gameLoginProtocolId);
			EXPECT_EQ(binary::readU16(decoded.body, 6).value(), constants::windowsOperatingSystem);
			EXPECT_EQ(binary::readU16(decoded.body, 8).value(), client::identity::version);
			EXPECT_EQ(binary::readU32(decoded.body, 10).value(), client::identity::version);
			EXPECT_EQ(binary::readU16(decoded.body, 14).value(), versionText.size());
			EXPECT_TRUE(std::equal(versionText.begin(), versionText.end(), decoded.body.begin() + 16, [](const char left, const std::byte right) {
				return static_cast<unsigned char>(left) == std::to_integer<unsigned char>(right);
			}));
			EXPECT_EQ(binary::readU16(decoded.body, 20).value(), request.assetHashIdentifier.size());
			EXPECT_EQ(decoded.body[26], std::byte { constants::gamePreviewStateDisabled });
			EXPECT_FALSE(std::all_of(decoded.body.begin() + 27, decoded.body.begin() + 155, [](const auto value) {
				return value == std::byte { 0x00 };
			}));
			EXPECT_EQ(decoded.body[155], std::byte { 0x00 });
		}

		TEST(WorldLoginPacketCodec, IsDeterministicForSameRequest) {
			const auto request = validRequest();
			EXPECT_EQ(encodeWorldLoginPacket(request).bytes, encodeWorldLoginPacket(request).bytes);
		}

		TEST(WorldLoginPacketCodec, EncodesEmptyAssetHashIdentifier) {
			auto request = validRequest();
			request.assetHashIdentifier.clear();
			const auto result = encodeWorldLoginPacket(request);
			ASSERT_EQ(result.status, WorldLoginPacketStatus::Ready);
			const auto decoded = framing::decodeModernFrame(result.bytes);
			ASSERT_EQ(decoded.status, framing::FrameDecodeStatus::FrameReady);
			EXPECT_EQ(binary::readU16(decoded.body, 20).value(), 0);
			EXPECT_EQ(decoded.body[22], std::byte { constants::gamePreviewStateDisabled });
		}

		TEST(WorldLoginPacketCodec, RejectsMetadataBeyondWireLength) {
			auto request = validRequest();
			request.assetHashIdentifier = std::string(65536, 'a');
			EXPECT_EQ(encodeWorldLoginPacket(request).status, WorldLoginPacketStatus::MetadataStringTooLong);
		}

		TEST(WorldLoginPacketCodec, RejectsInvalidLoginBlock) {
			auto request = validRequest();
			request.loginBlock.sessionKey.clear();
			EXPECT_EQ(encodeWorldLoginPacket(request).status, WorldLoginPacketStatus::InvalidLoginBlock);
		}

	}
}
