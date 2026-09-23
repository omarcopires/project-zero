#pragma once

#include <cstddef>
#include <cstdint>

namespace protocol::constants {

	inline constexpr std::size_t checksumSize = 4;
	inline constexpr std::size_t modernWorldChallengePayloadSize = 8;
	inline constexpr std::size_t modernWorldChallengeBodySize = checksumSize + modernWorldChallengePayloadSize;

	inline constexpr std::size_t challengePaddingOffset = 0;
	inline constexpr std::size_t challengeOpcodeOffset = 1;
	inline constexpr std::size_t challengeTimestampOffset = 2;
	inline constexpr std::size_t challengeRandomOffset = 6;
	inline constexpr std::size_t challengeTrailerOffset = 7;

	inline constexpr std::uint8_t modernChallengePaddingMarker = 0x01;
	inline constexpr std::uint8_t serverLoginChallengeOpcode = 0x1F;
	inline constexpr std::uint8_t modernChallengeTrailer = 0x71;

	inline constexpr std::uint16_t gameLoginProtocolId = 0x000A;
	inline constexpr std::uint16_t currentProtocolVersion = 1525;
	inline constexpr std::size_t rsaBlockSize = 128;
	inline constexpr std::size_t xteaKeyWordCount = 4;

}
