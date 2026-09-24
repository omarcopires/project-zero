#include "assets/appearance_catalog.h"

#include "appearances.pb.h"

#include <cstddef>
#include <cstdint>
#include <limits>
#include <span>

namespace assets {
	namespace {

		AppearanceFlags readFlags(const tibia::protobuf::appearances::Appearance &appearance) {
			AppearanceFlags flags;
			if (!appearance.has_flags()) {
				return flags;
			}

			const auto &source = appearance.flags();
			flags.cumulative = source.cumulative();
			flags.liquidPool = source.liquidpool();
			flags.liquidContainer = source.liquidcontainer();
			flags.container = source.container();
			if (source.has_upgradeclassification()) {
				flags.upgradeClassification = source.upgradeclassification().upgrade_classification();
			}
			flags.expire = source.expire();
			flags.expireStop = source.expirestop();
			flags.clockExpire = source.clockexpire();
			flags.wearOut = source.wearout();
			flags.decoItemKit = source.deco_item_kit();
			return flags;
		}

	}

	std::optional<AppearanceCatalog> AppearanceCatalog::decode(const std::span<const std::byte> protobufBytes) {
		if (protobufBytes.empty() || protobufBytes.size() > static_cast<std::size_t>(std::numeric_limits<int>::max())) {
			return std::nullopt;
		}

		tibia::protobuf::appearances::Appearances source;
		if (!source.ParseFromArray(protobufBytes.data(), static_cast<int>(protobufBytes.size()))) {
			return std::nullopt;
		}

		AppearanceCatalog catalog;
		const auto addRange = [&](const auto &appearances, const AppearanceKind kind) {
			for (const auto &appearance : appearances) {
				if (!appearance.has_id() || !catalog.add(kind, appearance.id(), readFlags(appearance))) {
					return false;
				}
			}
			return true;
		};

		if (!addRange(source.object(), AppearanceKind::Object)
		    || !addRange(source.outfit(), AppearanceKind::Outfit)
		    || !addRange(source.effect(), AppearanceKind::Effect)
		    || !addRange(source.missile(), AppearanceKind::Missile)) {
			return std::nullopt;
		}
		return catalog;
	}

	const AppearanceDefinition *AppearanceCatalog::find(const AppearanceKind kind, const std::uint32_t id) const noexcept {
		const std::unordered_map<std::uint32_t, AppearanceDefinition> *entries = nullptr;
		switch (kind) {
			case AppearanceKind::Object:
				entries = &m_objects;
				break;
			case AppearanceKind::Outfit:
				entries = &m_outfits;
				break;
			case AppearanceKind::Effect:
				entries = &m_effects;
				break;
			case AppearanceKind::Missile:
				entries = &m_missiles;
				break;
		}
		if (entries == nullptr) {
			return nullptr;
		}
		const auto found = entries->find(id);
		return found == entries->end() ? nullptr : &found->second;
	}

	std::size_t AppearanceCatalog::size(const AppearanceKind kind) const noexcept {
		switch (kind) {
			case AppearanceKind::Object:
				return m_objects.size();
			case AppearanceKind::Outfit:
				return m_outfits.size();
			case AppearanceKind::Effect:
				return m_effects.size();
			case AppearanceKind::Missile:
				return m_missiles.size();
		}
		return 0;
	}

	bool AppearanceCatalog::add(const AppearanceKind kind, const std::uint32_t id, const AppearanceFlags &flags) {
		std::unordered_map<std::uint32_t, AppearanceDefinition> *entries = nullptr;
		switch (kind) {
			case AppearanceKind::Object:
				entries = &m_objects;
				break;
			case AppearanceKind::Outfit:
				entries = &m_outfits;
				break;
			case AppearanceKind::Effect:
				entries = &m_effects;
				break;
			case AppearanceKind::Missile:
				entries = &m_missiles;
				break;
		}
		if (entries == nullptr) {
			return false;
		}
		return entries->emplace(id, AppearanceDefinition { .id = id, .kind = kind, .flags = flags }).second;
	}

}
