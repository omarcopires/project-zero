#pragma once

#include "assets/appearance_definition.h"

#include <cstddef>
#include <cstdint>
#include <optional>
#include <span>
#include <unordered_map>
#include <vector>

namespace assets {

	class AppearanceCatalog {
	public:
		static std::optional<AppearanceCatalog> decode(std::span<const std::byte> protobufBytes);

		const AppearanceDefinition *find(AppearanceKind kind, std::uint32_t id) const noexcept;
		std::size_t size(AppearanceKind kind) const noexcept;

	private:
		bool add(
			AppearanceKind kind,
			std::uint32_t id,
			const AppearanceFlags &flags,
			std::vector<AppearanceFrameGroup> frameGroups
		);

		std::unordered_map<std::uint32_t, AppearanceDefinition> m_objects;
		std::unordered_map<std::uint32_t, AppearanceDefinition> m_outfits;
		std::unordered_map<std::uint32_t, AppearanceDefinition> m_effects;
		std::unordered_map<std::uint32_t, AppearanceDefinition> m_missiles;
	};

}
