#pragma once

#include <cstdint>

namespace protocol::game {

	enum class GameServerOpcode : std::uint8_t {
		PendingState = 0x0A,
		EnterWorld = 0x0F,
		UpdateNeeded = 0x11,
		LoginError = 0x14,
		LoginAdvice = 0x15,
		LoginWait = 0x16,
		LoginSuccess = 0x17,
		SessionEnd = 0x18,
		AllowBugReport = 0x1A,
		MapDescription = 0x64,
		PlayerStats = 0xA0,
		ExivaRestrictions = 0xCA,
		ResourceBalance = 0xEE,
		ServerTime = 0xEF,
	};

}
