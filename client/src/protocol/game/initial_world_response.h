#pragma once

#include <cstddef>
#include <cstdint>
#include <string>

namespace protocol::game {

	enum class InitialWorldResponseStatus {
		Ready,
		Empty,
		Truncated,
		UnsupportedOpcode,
	};

	enum class InitialWorldResponseKind {
		Pending,
		EnterWorld,
		UpdateNeeded,
		LoginError,
		LoginAdvice,
		LoginWait,
		LoginSuccess,
		LoginToken,
	};

	struct InitialWorldResponse {
		InitialWorldResponseStatus status = InitialWorldResponseStatus::Empty;
		InitialWorldResponseKind kind = InitialWorldResponseKind::Pending;
		std::size_t bytesConsumed = 0;
		std::string message;
		std::string storeImagesUrl;
		std::uint32_t playerId = 0;
		std::uint16_t serverBeat = 0;
		std::uint8_t waitSeconds = 0;
		bool tokenAccepted = false;
	};

}
