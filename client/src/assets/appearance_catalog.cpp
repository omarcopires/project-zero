#include "assets/appearance_catalog.h"

#include "appearances.pb.h"

#include <cstddef>
#include <cstdint>
#include <limits>
#include <span>
#include <utility>

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

		std::optional<FixedFrameGroup> readFixedFrameGroup(
			const tibia::protobuf::appearances::FIXED_FRAME_GROUP value
		) {
			using namespace tibia::protobuf::appearances;
			switch (value) {
				case FIXED_FRAME_GROUP_OUTFIT_IDLE:
					return FixedFrameGroup::OutfitIdle;
				case FIXED_FRAME_GROUP_OUTFIT_MOVING:
					return FixedFrameGroup::OutfitMoving;
				case FIXED_FRAME_GROUP_OBJECT_INITIAL:
					return FixedFrameGroup::ObjectInitial;
			}
			return std::nullopt;
		}

		std::optional<AnimationLoopType> readAnimationLoopType(
			const tibia::protobuf::shared::ANIMATION_LOOP_TYPE value
		) {
			using namespace tibia::protobuf::shared;
			switch (value) {
				case ANIMATION_LOOP_TYPE_PINGPONG:
					return AnimationLoopType::PingPong;
				case ANIMATION_LOOP_TYPE_INFINITE:
					return AnimationLoopType::Infinite;
				case ANIMATION_LOOP_TYPE_COUNTED:
					return AnimationLoopType::Counted;
			}
			return std::nullopt;
		}

		AppearanceBox readBox(const tibia::protobuf::appearances::Box &source) {
			AppearanceBox box;
			if (source.has_x()) {
				box.x = source.x();
			}
			if (source.has_y()) {
				box.y = source.y();
			}
			if (source.has_width()) {
				box.width = source.width();
			}
			if (source.has_height()) {
				box.height = source.height();
			}
			return box;
		}

		std::optional<AppearanceSpriteAnimation> readAnimation(
			const tibia::protobuf::appearances::SpriteAnimation &source
		) {
			AppearanceSpriteAnimation animation;
			if (source.has_synchronized()) {
				animation.synchronized = source.synchronized();
			}
			if (source.has_loop_type()) {
				const auto loopType = readAnimationLoopType(source.loop_type());
				if (!loopType.has_value()) {
					return std::nullopt;
				}
				animation.loopType = *loopType;
			}
			if (source.has_loop_count()) {
				animation.loopCount = source.loop_count();
			}
			animation.phases.reserve(static_cast<std::size_t>(source.sprite_phase_size()));
			for (const auto &sourcePhase : source.sprite_phase()) {
				AppearanceSpritePhase phase;
				if (sourcePhase.has_duration_min()) {
					phase.durationMinimum = sourcePhase.duration_min();
				}
				if (sourcePhase.has_duration_max()) {
					phase.durationMaximum = sourcePhase.duration_max();
				}
				animation.phases.push_back(std::move(phase));
			}
			return animation;
		}

		std::optional<AppearanceSpriteInfo> readSpriteInfo(
			const tibia::protobuf::appearances::SpriteInfo &source
		) {
			AppearanceSpriteInfo spriteInfo;
			if (source.has_pattern_width()) {
				spriteInfo.patternWidth = source.pattern_width();
			}
			if (source.has_pattern_height()) {
				spriteInfo.patternHeight = source.pattern_height();
			}
			if (source.has_pattern_depth()) {
				spriteInfo.patternDepth = source.pattern_depth();
			}
			if (source.has_layers()) {
				spriteInfo.layers = source.layers();
			}
			spriteInfo.spriteIds.reserve(static_cast<std::size_t>(source.sprite_id_size()));
			for (const auto spriteId : source.sprite_id()) {
				spriteInfo.spriteIds.push_back(spriteId);
			}
			if (source.has_bounding_square()) {
				spriteInfo.boundingSquare = source.bounding_square();
			}
			if (source.has_animation()) {
				auto animation = readAnimation(source.animation());
				if (!animation.has_value()) {
					return std::nullopt;
				}
				spriteInfo.animation = std::move(*animation);
			}
			if (source.has_is_opaque()) {
				spriteInfo.opaque = source.is_opaque();
			}
			spriteInfo.boundingBoxesPerDirection.reserve(
				static_cast<std::size_t>(source.bounding_box_per_direction_size())
			);
			for (const auto &box : source.bounding_box_per_direction()) {
				spriteInfo.boundingBoxesPerDirection.push_back(readBox(box));
			}
			return spriteInfo;
		}

		std::optional<AppearanceFrameGroup> readFrameGroup(
			const tibia::protobuf::appearances::FrameGroup &source
		) {
			AppearanceFrameGroup frameGroup;
			if (source.has_fixed_frame_group()) {
				const auto fixedFrameGroup = readFixedFrameGroup(source.fixed_frame_group());
				if (!fixedFrameGroup.has_value()) {
					return std::nullopt;
				}
				frameGroup.fixedFrameGroup = *fixedFrameGroup;
			}
			if (source.has_id()) {
				frameGroup.id = source.id();
			}
			if (source.has_sprite_info()) {
				auto spriteInfo = readSpriteInfo(source.sprite_info());
				if (!spriteInfo.has_value()) {
					return std::nullopt;
				}
				frameGroup.spriteInfo = std::move(*spriteInfo);
			}
			return frameGroup;
		}

		std::optional<std::vector<AppearanceFrameGroup>> readFrameGroups(
			const tibia::protobuf::appearances::Appearance &source
		) {
			std::vector<AppearanceFrameGroup> frameGroups;
			frameGroups.reserve(static_cast<std::size_t>(source.frame_group_size()));
			for (const auto &sourceFrameGroup : source.frame_group()) {
				auto frameGroup = readFrameGroup(sourceFrameGroup);
				if (!frameGroup.has_value()) {
					return std::nullopt;
				}
				frameGroups.push_back(std::move(*frameGroup));
			}
			return frameGroups;
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
				if (!appearance.has_id()) {
					return false;
				}
				auto frameGroups = readFrameGroups(appearance);
				if (!frameGroups.has_value()
				    || !catalog.add(kind, appearance.id(), readFlags(appearance), std::move(*frameGroups))) {
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

	bool AppearanceCatalog::add(
		const AppearanceKind kind,
		const std::uint32_t id,
		const AppearanceFlags &flags,
		std::vector<AppearanceFrameGroup> frameGroups
	) {
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
		return entries->emplace(
			id,
			AppearanceDefinition {
				.id = id,
				.kind = kind,
				.flags = flags,
				.frameGroups = std::move(frameGroups),
			}
		).second;
	}

}
