#pragma once

#include <cstdint>
#include <optional>

namespace assets {

	struct AppearanceBox {
		std::optional<std::uint32_t> x;
		std::optional<std::uint32_t> y;
		std::optional<std::uint32_t> width;
		std::optional<std::uint32_t> height;
	};

}
