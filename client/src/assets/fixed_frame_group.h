#pragma once

#include <cstdint>

namespace assets {

	enum class FixedFrameGroup : std::uint32_t {
		OutfitIdle = 0,
		OutfitMoving = 1,
		ObjectInitial = 2,
	};

}
