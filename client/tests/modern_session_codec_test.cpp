#include "protocol/framing/modern_session_codec.h"

#include "protocol/binary/little_endian.h"
#include "protocol/crypto/xtea.h"
#include "protocol/framing/modern_frame.h"

#include <gtest/gtest.h>

#include <array>
#include <cstddef>
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

		TEST(ModernSessionCodec, RejectsCompressedIncomingPayload) {
			auto body = encodedBody(payload(1));
			body[3] |= std::byte { 0x80 };
			EXPECT_EQ(decodeModernSessionBody(body, testKey, 1).status, ModernSessionStatus::CompressedPayloadUnsupported);
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
