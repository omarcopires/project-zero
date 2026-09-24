#pragma once

namespace protocol::game {

	enum class InitialWorldResponseStatus {
		Ready,
		Empty,
		Truncated,
		UnsupportedOpcode,
	};

}
