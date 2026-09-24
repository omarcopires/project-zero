#pragma once

#include "assets/appearance_flags.h"
#include "assets/appearance_kind.h"

#include <cstdint>

namespace assets {

	struct AppearanceDefinition {
		std::uint32_t id = 0;
		AppearanceKind kind = AppearanceKind::Object;
		AppearanceFlags flags;
	};

}
