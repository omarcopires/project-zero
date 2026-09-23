#include "protocol/handshake/world_login_block_codec.h"

#include "protocol/binary/little_endian.h"
#include "protocol/constants/world_handshake_constants.h"

#include <gtest/gtest.h>

#include <algorithm>
#include <cstddef>
#include <cstdint>
#include <string>
#include <string_view>
#include <vector>

namespace protocol::handshake {
	namespace {

		WorldLoginBlockRequest validRequest() {
			return {
				.xteaKey = { 0x01020304U, 0x11121314U, 0x21222324U, 0x31323334U },
				.sessionKey = "session",
				.characterName = "Knight",
				.challenge = { .timestamp = 0x41424344U, .random = 0x5A },
			};
		}

		bool equalsText(const std::vector<std::byte>::const_iterator begin, const std::vector<std::byte>::const_iterator end, const std::string_view text) {
			return static_cast<std::size_t>(end - begin) == text.size()
				&& std::equal(begin, end, text.begin(), [](const std::byte left, const char right) {
					   return std::to_integer<unsigned char>(left) == static_cast<unsigned char>(right);
				   });
		}

		TEST(WorldLoginBlockCodec, EncodesConfirmedServerFields) {
			const auto result = encodeWorldLoginBlock(validRequest());

			ASSERT_EQ(result.status, WorldLoginBlockStatus::Ready);
			ASSERT_EQ(result.plaintext.size(), constants::rsaBlockSize);
			EXPECT_EQ(result.plaintext[0], std::byte { constants::rsaPlaintextLeadingByte });
			EXPECT_EQ(binary::readU32(result.plaintext, 1).value(), 0x01020304U);
			EXPECT_EQ(binary::readU32(result.plaintext, 13).value(), 0x31323334U);
			EXPECT_EQ(result.plaintext[17], std::byte { constants::gameMasterFlagDisabled });
			EXPECT_EQ(binary::readU16(result.plaintext, 18).value(), 7);
			EXPECT_TRUE(equalsText(result.plaintext.begin() + 20, result.plaintext.begin() + 27, "session"));
			EXPECT_EQ(binary::readU16(result.plaintext, 27).value(), 6);
			EXPECT_TRUE(equalsText(result.plaintext.begin() + 29, result.plaintext.begin() + 35, "Knight"));
			EXPECT_EQ(binary::readU32(result.plaintext, 35).value(), 0x41424344U);
			EXPECT_EQ(result.plaintext[39], std::byte { 0x5A });
			EXPECT_EQ(binary::readU16(result.plaintext, 40).value(), 0);
			EXPECT_TRUE(std::all_of(result.plaintext.begin() + 42, result.plaintext.end(), [](const auto value) { return value == std::byte { 0x00 }; }));
		}

		TEST(WorldLoginBlockCodec, RejectsEmptySessionKey) {
			auto request = validRequest();
			request.sessionKey.clear();
			EXPECT_EQ(encodeWorldLoginBlock(request).status, WorldLoginBlockStatus::EmptySessionKey);
		}

		TEST(WorldLoginBlockCodec, RejectsEmptyCharacterName) {
			auto request = validRequest();
			request.characterName.clear();
			EXPECT_EQ(encodeWorldLoginBlock(request).status, WorldLoginBlockStatus::EmptyCharacterName);
		}

		TEST(WorldLoginBlockCodec, RejectsStringBeyondWireLength) {
			auto request = validRequest();
			request.sessionKey = std::string(65536, 's');
			EXPECT_EQ(encodeWorldLoginBlock(request).status, WorldLoginBlockStatus::StringTooLong);
		}

		TEST(WorldLoginBlockCodec, RejectsPayloadBeyondRsaBlock) {
			auto request = validRequest();
			request.sessionKey = std::string(60, 's');
			request.characterName = std::string(60, 'c');
			EXPECT_EQ(encodeWorldLoginBlock(request).status, WorldLoginBlockStatus::PayloadTooLarge);
		}

		TEST(WorldLoginBlockCodec, AcceptsPayloadAtExactRsaLimit) {
			auto request = validRequest();
			request.sessionKey = std::string(30, 's');
			request.characterName = std::string(69, 'c');
			const auto result = encodeWorldLoginBlock(request);

			EXPECT_EQ(result.status, WorldLoginBlockStatus::Ready);
			EXPECT_EQ(result.plaintext.size(), constants::rsaBlockSize);
		}

	}
}
