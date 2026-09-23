#pragma once

#include <cstddef>
#include <cstdint>
#include <string_view>

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
	inline constexpr std::uint8_t rsaPlaintextLeadingByte = 0x00;
	inline constexpr std::uint8_t gameMasterFlagDisabled = 0x00;
	inline constexpr std::string_view otcV8Probe = "OTCv8";
	inline constexpr std::uint32_t openTibiaRsaExponent = 65537;
	inline constexpr std::string_view openTibiaRsaModulus =
		"1091201329673994292788609605089955415282375029027981291234687579"
		"3726629149257644633073969600111060390723088861007265581882535850"
		"3429057592827629436413108566029093628212635953836686562675849720"
		"6207862794310902180176810615217550567108238764764442605581471797"
		"07119674283982419152118103759076030616683978566631413";

}
