#include "protocol/game/initial_world_response_codec.h"

#include "protocol/binary/length_prefixed_string.h"
#include "protocol/binary/little_endian.h"

#include <gtest/gtest.h>

#include <cstddef>
#include <cstdint>
#include <string_view>
#include <vector>

namespace protocol::game {
	namespace {

		void appendEncodedDouble(std::vector<std::byte> &payload) {
			payload.push_back(std::byte { 3 });
			binary::appendU32(payload, 0x80000000U);
		}

		std::vector<std::byte> messagePayload(const std::uint8_t opcode, const std::string_view message) {
			std::vector<std::byte> payload { static_cast<std::byte>(opcode) };
			EXPECT_TRUE(binary::appendStringU16(payload, message));
			return payload;
		}

		TEST(InitialWorldResponseCodec, DecodesLoginSuccessLayout) {
			std::vector<std::byte> payload { std::byte { 0x17 } };
			binary::appendU32(payload, 0x12345678U);
			binary::appendU16(payload, 50);
			appendEncodedDouble(payload);
			appendEncodedDouble(payload);
			appendEncodedDouble(payload);
			payload.push_back(std::byte { 1 });
			payload.push_back(std::byte { 0 });
			ASSERT_TRUE(binary::appendStringU16(payload, "https://store.invalid"));
			binary::appendU16(payload, 25);
			payload.push_back(std::byte { 1 });

			const auto result = decodeInitialWorldResponse(payload);

			EXPECT_EQ(result.status, InitialWorldResponseStatus::Ready);
			EXPECT_EQ(result.kind, InitialWorldResponseKind::LoginSuccess);
			EXPECT_EQ(result.bytesConsumed, payload.size());
			EXPECT_EQ(result.playerId, 0x12345678U);
			EXPECT_EQ(result.serverBeat, 50);
			EXPECT_EQ(result.storeImagesUrl, "https://store.invalid");
		}

		TEST(InitialWorldResponseCodec, LeavesFollowingOpcodesUnread) {
			auto payload = messagePayload(0x15, "Notice");
			const auto expectedSize = payload.size();
			payload.push_back(std::byte { 0x0F });

			const auto result = decodeInitialWorldResponse(payload);

			EXPECT_EQ(result.status, InitialWorldResponseStatus::Ready);
			EXPECT_EQ(result.kind, InitialWorldResponseKind::LoginAdvice);
			EXPECT_EQ(result.bytesConsumed, expectedSize);
		}

		TEST(InitialWorldResponseCodec, DecodesWaitingListResponse) {
			auto payload = messagePayload(0x16, "Please wait");
			payload.push_back(std::byte { 7 });

			const auto result = decodeInitialWorldResponse(payload);

			EXPECT_EQ(result.status, InitialWorldResponseStatus::Ready);
			EXPECT_EQ(result.kind, InitialWorldResponseKind::LoginWait);
			EXPECT_EQ(result.message, "Please wait");
			EXPECT_EQ(result.waitSeconds, 7);
		}

		TEST(InitialWorldResponseCodec, DecodesSingleByteStates) {
			const std::vector<std::byte> pending { std::byte { 0x0A } };
			const std::vector<std::byte> entered { std::byte { 0x0F } };

			EXPECT_EQ(decodeInitialWorldResponse(pending).kind, InitialWorldResponseKind::Pending);
			EXPECT_EQ(decodeInitialWorldResponse(entered).kind, InitialWorldResponseKind::EnterWorld);
		}

		TEST(InitialWorldResponseCodec, DecodesServerMessages) {
			EXPECT_EQ(decodeInitialWorldResponse(messagePayload(0x11, "signature")).kind, InitialWorldResponseKind::UpdateNeeded);
			EXPECT_EQ(decodeInitialWorldResponse(messagePayload(0x14, "Rejected")).kind, InitialWorldResponseKind::LoginError);
			EXPECT_EQ(decodeInitialWorldResponse(messagePayload(0x15, "Notice")).kind, InitialWorldResponseKind::LoginAdvice);
		}

		TEST(InitialWorldResponseCodec, DecodesLoginTokenResult) {
			const std::vector<std::byte> payload { std::byte { 0x18 }, std::byte { 1 } };

			const auto result = decodeInitialWorldResponse(payload);

			EXPECT_EQ(result.status, InitialWorldResponseStatus::Ready);
			EXPECT_EQ(result.kind, InitialWorldResponseKind::LoginToken);
			EXPECT_TRUE(result.tokenAccepted);
		}

		TEST(InitialWorldResponseCodec, RejectsTruncatedPayloads) {
			const std::vector<std::byte> message { std::byte { 0x14 }, std::byte { 5 }, std::byte { 0 }, std::byte { 'x' } };
			const std::vector<std::byte> success { std::byte { 0x17 } };

			EXPECT_EQ(decodeInitialWorldResponse(message).status, InitialWorldResponseStatus::Truncated);
			EXPECT_EQ(decodeInitialWorldResponse(success).status, InitialWorldResponseStatus::Truncated);
		}

		TEST(InitialWorldResponseCodec, RejectsEmptyAndUnsupportedPayloads) {
			const std::vector<std::byte> unsupported { std::byte { 0xAA } };

			EXPECT_EQ(decodeInitialWorldResponse({}).status, InitialWorldResponseStatus::Empty);
			EXPECT_EQ(decodeInitialWorldResponse(unsupported).status, InitialWorldResponseStatus::UnsupportedOpcode);
		}

	}
}
