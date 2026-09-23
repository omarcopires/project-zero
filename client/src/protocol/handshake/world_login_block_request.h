#pragma once

#include "protocol/constants/world_handshake_constants.h"
#include "protocol/handshake/world_challenge.h"

#include <array>
#include <cstdint>
#include <string>

namespace protocol::handshake {

	struct WorldLoginBlockRequest {
		std::array<std::uint32_t, constants::xteaKeyWordCount> xteaKey {};
		std::string sessionKey;
		std::string characterName;
		WorldChallenge challenge;
		std::uint16_t otcV8Version = constants::currentProtocolVersion;
	};

}
