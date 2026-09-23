#include "protocol/handshake/world_challenge_codec.h"
#include "protocol/constants/world_handshake_constants.h"

#include <gtest/gtest.h>

#include <array>
#include <cstddef>
#include <cstdint>
#include <span>

namespace protocol::handshake {
	namespace {

		using ChallengeBytes = std::array<std::byte, modernWorldChallengeBodySize>;

		ChallengeBytes knownChallenge() {
			return {
				std::byte { 0xF6 },
				std::byte { 0x00 },
				std::byte { 0x40 },
				std::byte { 0x02 },
				std::byte { 0x01 },
				std::byte { 0x1F },
				std::byte { 0x04 },
				std::byte { 0x03 },
				std::byte { 0x02 },
				std::byte { 0x01 },
				std::byte { 0x5A },
				std::byte { 0x71 },
			};
		}

		void updateChecksum(ChallengeBytes &bytes) {
			std::uint32_t a = 1;
			std::uint32_t b = 0;
			for (const auto value : std::span(bytes).subspan(constants::checksumSize)) {
				a = (a + std::to_integer<std::uint8_t>(value)) % 65521;
				b = (b + a) % 65521;
			}
			const auto checksum = (b << 16) | a;
			for (std::size_t index = 0; index < 4; ++index) {
				bytes[index] = static_cast<std::byte>((checksum >> (index * 8)) & 0xFF);
			}
		}

		TEST(WorldChallengeCodec, DecodesKnownModernChallenge) {
			const auto result = decodeWorldChallenge(knownChallenge());

			ASSERT_EQ(result.status, WorldChallengeStatus::Ready);
			ASSERT_TRUE(result.challenge.has_value());
			EXPECT_EQ(result.challenge->timestamp, 0x01020304U);
			EXPECT_EQ(result.challenge->random, 0x5A);
		}

		TEST(WorldChallengeCodec, RejectsUnexpectedLength) {
			const auto bytes = knownChallenge();

			EXPECT_EQ(decodeWorldChallenge(std::span(bytes).first(11)).status, WorldChallengeStatus::InvalidLength);
			EXPECT_EQ(decodeWorldChallenge({}).status, WorldChallengeStatus::InvalidLength);
		}

		TEST(WorldChallengeCodec, RejectsInvalidChecksum) {
			auto bytes = knownChallenge();
			bytes[constants::checksumSize + constants::challengeRandomOffset] = std::byte { 0x5B };

			EXPECT_EQ(decodeWorldChallenge(bytes).status, WorldChallengeStatus::InvalidChecksum);
		}

		TEST(WorldChallengeCodec, RejectsInvalidPaddingMarker) {
			auto bytes = knownChallenge();
			bytes[constants::checksumSize + constants::challengePaddingOffset] = std::byte { 0x00 };
			updateChecksum(bytes);

			EXPECT_EQ(decodeWorldChallenge(bytes).status, WorldChallengeStatus::InvalidPadding);
		}

		TEST(WorldChallengeCodec, RejectsInvalidOpcode) {
			auto bytes = knownChallenge();
			bytes[constants::checksumSize + constants::challengeOpcodeOffset] = std::byte { 0x20 };
			updateChecksum(bytes);

			EXPECT_EQ(decodeWorldChallenge(bytes).status, WorldChallengeStatus::InvalidOpcode);
		}

		TEST(WorldChallengeCodec, RejectsInvalidTrailer) {
			auto bytes = knownChallenge();
			bytes[constants::checksumSize + constants::challengeTrailerOffset] = std::byte { 0x70 };
			updateChecksum(bytes);

			EXPECT_EQ(decodeWorldChallenge(bytes).status, WorldChallengeStatus::InvalidTrailer);
		}

	}
}
