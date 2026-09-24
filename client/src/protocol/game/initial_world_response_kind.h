#pragma once

namespace protocol::game {

	enum class InitialWorldResponseKind {
		Pending,
		EnterWorld,
		UpdateNeeded,
		LoginError,
		LoginAdvice,
		LoginWait,
		LoginSuccess,
		SessionEnd,
		Auxiliary,
	};

}
