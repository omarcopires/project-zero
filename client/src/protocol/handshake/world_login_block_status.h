#pragma once

namespace protocol::handshake {

	enum class WorldLoginBlockStatus {
		Ready,
		EmptySessionKey,
		EmptyCharacterName,
		StringTooLong,
		PayloadTooLarge,
	};

}
