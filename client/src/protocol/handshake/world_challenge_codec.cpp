#include "protocol/handshake/world_challenge_codec.h"

#include <cstdint>

namespace protocol::handshake {
	namespace {

		constexpr std::uint32_t adlerModulus = 65521;

		std::uint32_t readU32(const std::span<const std::byte> bytes) {
			return std::to_integer<std::uint32_t>(bytes[0])
				| (std::to_integer<std::uint32_t>(bytes[1]) << 8)
				| (std::to_integer<std::uint32_t>(bytes[2]) << 16)
				| (std::to_integer<std::uint32_t>(bytes[3]) << 24);
		}

		std::uint32_t adler32(const std::span<const std::byte> bytes) {
			std::uint32_t a = 1;
			std::uint32_t b = 0;
			for (const auto value : bytes) {
				a = (a + std::to_integer<std::uint8_t>(value)) % adlerModulus;
				b = (b + a) % adlerModulus;
			}
			return (b << 16) | a;
		}

	}

	WorldChallengeResult decodeWorldChallenge(const std::span<const std::byte> body) {
		if (body.size() != modernWorldChallengeBodySize) {
			return { .status = WorldChallengeStatus::InvalidLength };
		}

		const auto payload = body.subspan(4);
		if (readU32(body.first(4)) != adler32(payload)) {
			return { .status = WorldChallengeStatus::InvalidChecksum };
		}
		if (payload[0] != std::byte { 0x01 }) {
			return { .status = WorldChallengeStatus::InvalidPadding };
		}
		if (payload[1] != std::byte { 0x1F }) {
			return { .status = WorldChallengeStatus::InvalidOpcode };
		}
		if (payload[7] != std::byte { 0x71 }) {
			return { .status = WorldChallengeStatus::InvalidTrailer };
		}

		return {
			.status = WorldChallengeStatus::Ready,
			.challenge = WorldChallenge {
				.timestamp = readU32(payload.subspan(2, 4)),
				.random = std::to_integer<std::uint8_t>(payload[6]),
			},
		};
	}

}
