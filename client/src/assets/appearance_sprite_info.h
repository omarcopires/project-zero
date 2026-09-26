#pragma once

#include "assets/appearance_box.h"
#include "assets/appearance_sprite_animation.h"

#include <cstdint>
#include <optional>
#include <vector>

namespace assets {

	struct AppearanceSpriteInfo {
		std::optional<std::uint32_t> patternWidth;
		std::optional<std::uint32_t> patternHeight;
		std::optional<std::uint32_t> patternDepth;
		std::optional<std::uint32_t> layers;
		std::vector<std::uint32_t> spriteIds;
		std::optional<std::uint32_t> boundingSquare;
		std::optional<AppearanceSpriteAnimation> animation;
		std::optional<bool> opaque;
		std::vector<AppearanceBox> boundingBoxesPerDirection;
	};

}
