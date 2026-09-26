#pragma once

#include "assets/appearance_frame_group.h"
#include "assets/appearance_flags.h"
#include "assets/appearance_kind.h"

#include <cstdint>
#include <vector>

namespace assets {

	struct AppearanceDefinition {
		std::uint32_t id = 0;
		AppearanceKind kind = AppearanceKind::Object;
		AppearanceFlags flags;
		std::vector<AppearanceFrameGroup> frameGroups;
	};

}
