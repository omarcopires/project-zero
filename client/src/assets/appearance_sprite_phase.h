#pragma once

#include <cstdint>
#include <optional>

namespace assets {

	struct AppearanceSpritePhase {
		std::optional<std::uint32_t> durationMinimum;
		std::optional<std::uint32_t> durationMaximum;
	};

}
