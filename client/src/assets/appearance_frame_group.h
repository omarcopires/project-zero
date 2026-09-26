#pragma once

#include "assets/appearance_sprite_info.h"
#include "assets/fixed_frame_group.h"

#include <cstdint>
#include <optional>

namespace assets {

	struct AppearanceFrameGroup {
		std::optional<FixedFrameGroup> fixedFrameGroup;
		std::optional<std::uint32_t> id;
		std::optional<AppearanceSpriteInfo> spriteInfo;
	};

}
