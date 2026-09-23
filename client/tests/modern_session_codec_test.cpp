#include "protocol/framing/modern_session_codec.h"

#include "protocol/binary/little_endian.h"
#include "protocol/crypto/xtea.h"
#include "protocol/framing/modern_frame.h"

#include <gtest/gtest.h>

#include <array>
#include <cstddef>
#include <string>
#include <vector>

namespace protocol::framing {
	namespace {

		constexpr crypto::XteaKey testKey { 0x01020304U, 0x11121314U, 0x21222324U, 0x31323334U };

		std::vector<std::byte> payload(const std::size_t size) {
			std::vector<std::byte> bytes(size);
			for (std::size_t index = 0; index < size; ++index) {
				bytes[index] = static_cast<std::byte>(index + 1);
			}
			return bytes;
		}

		std::vector<std::byte> encodedBody(const std::vector<std::byte> &bytes, const std::uint32_t sequence = 1) {
			const auto encoded = encodeModernSessionPacket(bytes, testKey, sequence);
			EXPECT_EQ(encoded.status, ModernSessionStatus::Ready);
			const auto frame = decodeModernFrame(encoded.bytes);
			EXPECT_EQ(frame.status, FrameDecodeStatus::FrameReady);
			return std::vector<std::byte>(frame.body.begin(), frame.body.end());
		}

		TEST(ModernSessionCodec, FramesAndRoundTripsPayload) {
			const auto input = payload(10);
			const auto encoded = encodeModernSessionPacket(input, testKey, 1);

			ASSERT_EQ(encoded.status, ModernSessionStatus::Ready);
			EXPECT_EQ(encoded.sequence, 1);
			EXPECT_EQ(binary::readU16(encoded.bytes).value(), 2);
			const auto frame = decodeModernFrame(encoded.bytes);
			ASSERT_EQ(frame.status, FrameDecodeStatus::FrameReady);
			EXPECT_EQ(binary::readU32(frame.body).value(), 1);

			const auto decoded = decodeModernSessionBody(frame.body, testKey, 1);
			EXPECT_EQ(decoded.status, ModernSessionStatus::Ready);
			EXPECT_EQ(decoded.sequence, 1);
			EXPECT_EQ(decoded.bytes, input);
		}

		TEST(ModernSessionCodec, HandlesPaddingBoundaries) {
			for (const auto size : { std::size_t { 7 }, std::size_t { 8 } }) {
				const auto input = payload(size);
				const auto decoded = decodeModernSessionBody(encodedBody(input), testKey, 1);
				EXPECT_EQ(decoded.status, ModernSessionStatus::Ready);
				EXPECT_EQ(decoded.bytes, input);
			}
		}

		TEST(ModernSessionCodec, RejectsEmptyPayload) {
			EXPECT_EQ(encodeModernSessionPacket({}, testKey, 1).status, ModernSessionStatus::EmptyPayload);
		}

		TEST(ModernSessionCodec, RejectsInvalidOutgoingSequence) {
			EXPECT_EQ(encodeModernSessionPacket(payload(1), testKey, 0).status, ModernSessionStatus::InvalidSequence);
			EXPECT_EQ(encodeModernSessionPacket(payload(1), testKey, 0x80000000U).status, ModernSessionStatus::InvalidSequence);
		}

		TEST(ModernSessionCodec, RejectsUnexpectedIncomingSequence) {
			const auto body = encodedBody(payload(1), 2);
			const auto decoded = decodeModernSessionBody(body, testKey, 1);
			EXPECT_EQ(decoded.status, ModernSessionStatus::UnexpectedSequence);
			EXPECT_EQ(decoded.sequence, 2);
		}

		TEST(ModernSessionCodec, DecompressesCompressedIncomingPayload) {
			const std::array<std::byte, 31> compressed {
				std::byte { 0x4B }, std::byte { 0xCE }, std::byte { 0xCF }, std::byte { 0x2D },
				std::byte { 0x28 }, std::byte { 0x4A }, std::byte { 0x2D }, std::byte { 0x2E },
				std::byte { 0x4E }, std::byte { 0x4D }, std::byte { 0xD1 }, std::byte { 0x2D },
				std::byte { 0x4E }, std::byte { 0x2D }, std::byte { 0x2E }, std::byte { 0xCE },
				std::byte { 0xCC }, std::byte { 0xCF }, std::byte { 0xD3 }, std::byte { 0x2D },
				std::byte { 0x48 }, std::byte { 0xAC }, std::byte { 0xCC }, std::byte { 0xC9 },
				std::byte { 0x4F }, std::byte { 0x4C }, std::byte { 0x49 }, std::byte { 0x1E },
				std::byte { 0x92 }, std::byte { 0x32 }, std::byte { 0x00 },
			};
			std::vector<std::byte> plaintext { std::byte { 0x00 } };
			plaintext.insert(plaintext.end(), compressed.begin(), compressed.end());
			const auto encrypted = crypto::encryptXtea(plaintext, testKey);
			ASSERT_EQ(encrypted.status, crypto::XteaStatus::Ready);
			std::vector<std::byte> body;
			binary::appendU32(body, 0x80000001U);
			body.insert(body.end(), encrypted.bytes.begin(), encrypted.bytes.end());

			const auto decoded = decodeModernSessionBody(body, testKey, 1);
			ASSERT_EQ(decoded.status, ModernSessionStatus::Ready);
			const std::string unit = "compressed-session-payload";
			const std::vector<std::byte> expectedUnit(
				reinterpret_cast<const std::byte*>(unit.data()),
				reinterpret_cast<const std::byte*>(unit.data() + unit.size()));
			std::vector<std::byte> expected;
			for (int repetition = 0; repetition < 8; ++repetition) {
				expected.insert(expected.end(), expectedUnit.begin(), expectedUnit.end());
			}
			EXPECT_EQ(decoded.bytes, expected);
		}

		TEST(ModernSessionCodec, RejectsMalformedBody) {
			const std::array<std::byte, 11> body {};
			EXPECT_EQ(decodeModernSessionBody(body, testKey, 1).status, ModernSessionStatus::InvalidBodySize);
			EXPECT_EQ(decodeModernSessionBody({}, testKey, 0).status, ModernSessionStatus::InvalidSequence);
		}

		TEST(ModernSessionCodec, RejectsInvalidPadding) {
			std::array<std::byte, 8> plaintext {};
			plaintext.front() = std::byte { 0x08 };
			const auto encrypted = crypto::encryptXtea(plaintext, testKey);
			ASSERT_EQ(encrypted.status, crypto::XteaStatus::Ready);
			std::vector<std::byte> body;
			binary::appendU32(body, 1);
			body.insert(body.end(), encrypted.bytes.begin(), encrypted.bytes.end());
			EXPECT_EQ(decodeModernSessionBody(body, testKey, 1).status, ModernSessionStatus::InvalidPadding);
		}

	}
}
