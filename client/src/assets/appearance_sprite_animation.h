#pragma once

#include "assets/animation_loop_type.h"
#include "assets/appearance_sprite_phase.h"

#include <cstdint>
#include <optional>
#include <vector>

namespace assets {

	struct AppearanceSpriteAnimation {
		std::optional<bool> synchronized;
		std::optional<AnimationLoopType> loopType;
		std::optional<std::uint32_t> loopCount;
		std::vector<AppearanceSpritePhase> phases;
	};

}
