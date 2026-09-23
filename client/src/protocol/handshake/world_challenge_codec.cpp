#include "protocol/handshake/world_challenge_codec.h"

#include "protocol/binary/adler32.h"
#include "protocol/binary/little_endian.h"
#include "protocol/constants/world_handshake_constants.h"

namespace protocol::handshake {

	WorldChallengeResult decodeWorldChallenge(const std::span<const std::byte> body) {
		if (body.size() != constants::modernWorldChallengeBodySize) {
			return { .status = WorldChallengeStatus::InvalidLength };
		}

		const auto payload = body.subspan(constants::checksumSize);
		if (binary::readU32(body).value() != binary::adler32(payload)) {
			return { .status = WorldChallengeStatus::InvalidChecksum };
		}
		if (payload[constants::challengePaddingOffset] != static_cast<std::byte>(constants::modernChallengePaddingMarker)) {
			return { .status = WorldChallengeStatus::InvalidPadding };
		}
		if (payload[constants::challengeOpcodeOffset] != static_cast<std::byte>(constants::serverLoginChallengeOpcode)) {
			return { .status = WorldChallengeStatus::InvalidOpcode };
		}
		if (payload[constants::challengeTrailerOffset] != static_cast<std::byte>(constants::modernChallengeTrailer)) {
			return { .status = WorldChallengeStatus::InvalidTrailer };
		}

		return {
			.status = WorldChallengeStatus::Ready,
			.challenge = WorldChallenge {
				.timestamp = binary::readU32(payload, constants::challengeTimestampOffset).value(),
				.random = std::to_integer<std::uint8_t>(payload[constants::challengeRandomOffset]),
			},
		};
	}

}
