#include "protocol/crypto/raw_rsa.h"

#include "protocol/constants/world_handshake_constants.h"

#include <gtest/gtest.h>

#include <array>
#include <cstddef>
#include <cstdint>
#include <string_view>

namespace protocol::crypto {
	namespace {

		std::array<std::byte, constants::rsaBlockSize> sequenceBlock() {
			std::array<std::byte, constants::rsaBlockSize> block {};
			for (std::size_t index = 0; index < block.size(); ++index) {
				block[index] = static_cast<std::byte>(index);
			}
			return block;
		}

		TEST(RawRsa, MatchesKnownOpenTibiaVector) {
			constexpr std::string_view expectedHex =
				"6deee571cee50312881746969dfe68d7d9440e6c35307c8f728d8eeaac8e2161"
				"55c7b3215cefe29024a6cae2d49941d414251120651fb3d0bd9129ad8a2b3007"
				"274f027a25b81feac2940a34817715b8e1f772b30e5bb83103faeee7eee347c4"
				"215b5df6c56acb2238954af01011856281b32a777c62b62440ebf7dbf5f7ea2e";
			const auto result = encryptRawRsa(
				sequenceBlock(),
				constants::openTibiaRsaModulus,
				constants::openTibiaRsaExponent);

			ASSERT_EQ(result.status, RawRsaStatus::Ready);
			ASSERT_EQ(result.ciphertext.size(), constants::rsaBlockSize);
			for (std::size_t index = 0; index < result.ciphertext.size(); ++index) {
				const auto hexValue = [](const char digit) {
					return digit <= '9' ? digit - '0' : digit - 'a' + 10;
				};
				const auto expected = static_cast<unsigned char>(
					(hexValue(expectedHex[index * 2]) << 4) | hexValue(expectedHex[index * 2 + 1]));
				EXPECT_EQ(std::to_integer<unsigned char>(result.ciphertext[index]), expected) << index;
			}
		}

		TEST(RawRsa, PreservesNumericOne) {
			auto block = std::array<std::byte, constants::rsaBlockSize> {};
			block.back() = std::byte { 0x01 };
			const auto result = encryptRawRsa(
				block,
				constants::openTibiaRsaModulus,
				constants::openTibiaRsaExponent);

			ASSERT_EQ(result.status, RawRsaStatus::Ready);
			EXPECT_EQ(result.ciphertext, std::vector<std::byte>(block.begin(), block.end()));
		}

		TEST(RawRsa, RejectsWrongBlockSize) {
			const std::array<std::byte, 127> block {};
			EXPECT_EQ(
				encryptRawRsa(block, constants::openTibiaRsaModulus, constants::openTibiaRsaExponent).status,
				RawRsaStatus::InvalidBlockSize);
		}

		TEST(RawRsa, RejectsInvalidPublicKey) {
			EXPECT_EQ(
				encryptRawRsa(sequenceBlock(), "not-a-number", constants::openTibiaRsaExponent).status,
				RawRsaStatus::InvalidPublicKey);
			EXPECT_EQ(
				encryptRawRsa(sequenceBlock(), constants::openTibiaRsaModulus, 2).status,
				RawRsaStatus::InvalidPublicKey);
		}

		TEST(RawRsa, RejectsMessageOutsideModulus) {
			auto outOfRange = std::array<std::byte, constants::rsaBlockSize> {};
			outOfRange.fill(std::byte { 0xFF });
			EXPECT_EQ(
				encryptRawRsa(outOfRange, constants::openTibiaRsaModulus, constants::openTibiaRsaExponent).status,
				RawRsaStatus::MessageOutOfRange);
		}

	}
}
