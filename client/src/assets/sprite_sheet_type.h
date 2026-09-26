#pragma once

#include <cstdint>

namespace assets {

	enum class SpriteSheetType : std::uint8_t {
		Standard = 0,
		Tall = 1,
		Wide = 2,
		Large = 3,
		ExtraLarge = 11,
		Huge = 16,
		Enormous = 22,
	};

}
