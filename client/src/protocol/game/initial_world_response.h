#pragma once

#include "protocol/game/initial_world_response_kind.h"
#include "protocol/game/initial_world_response_status.h"

#include <cstddef>
#include <cstdint>
#include <string>

namespace protocol::game {

	struct InitialWorldResponse {
		InitialWorldResponseStatus status = InitialWorldResponseStatus::Empty;
		InitialWorldResponseKind kind = InitialWorldResponseKind::Pending;
		std::size_t bytesConsumed = 0;
		std::string message;
		std::string storeImagesUrl;
		std::uint32_t playerId = 0;
		std::uint16_t serverBeat = 0;
		std::uint8_t waitSeconds = 0;
		std::uint8_t sessionEndReason = 0;
	};

}
