#pragma once

#include "assets/appearance_definition.h"
#include "protocol/game/map_description_decode_result.h"

#include <cstdint>
#include <functional>
#include <span>

namespace protocol::game {

	using AppearanceLookup = std::function<const assets::AppearanceDefinition *(assets::AppearanceKind, std::uint32_t)>;

	MapDescriptionDecodeResult decodeMapDescription(
		std::span<const std::byte> payload,
		const AppearanceLookup &appearanceLookup);

}
