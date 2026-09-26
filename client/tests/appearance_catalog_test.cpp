#include <gtest/gtest.h>

#include "assets/appearance_catalog.h"
#include "appearances.pb.h"

#include <cstddef>
#include <cstdint>
#include <span>
#include <string>
#include <vector>

TEST(AppearanceCatalog, PreservesFrameGroupsAndSpriteMetadata) {
	tibia::protobuf::appearances::Appearances source;
	auto* appearance = source.add_object();
	appearance->set_id(4200);
	auto* frameGroup = appearance->add_frame_group();
	frameGroup->set_fixed_frame_group(tibia::protobuf::appearances::FIXED_FRAME_GROUP_OBJECT_INITIAL);
	frameGroup->set_id(0);

	auto* spriteInfo = frameGroup->mutable_sprite_info();
	spriteInfo->set_pattern_width(2);
	spriteInfo->set_pattern_height(3);
	spriteInfo->set_pattern_depth(1);
	spriteInfo->set_layers(2);
	spriteInfo->add_sprite_id(101);
	spriteInfo->add_sprite_id(102);
	spriteInfo->set_bounding_square(2);
	spriteInfo->set_is_opaque(false);
	auto* animation = spriteInfo->mutable_animation();
	animation->set_synchronized(true);
	animation->set_loop_type(tibia::protobuf::shared::ANIMATION_LOOP_TYPE_COUNTED);
	animation->set_loop_count(4);
	auto* phase = animation->add_sprite_phase();
	phase->set_duration_min(80);
	phase->set_duration_max(120);
	auto* box = spriteInfo->add_bounding_box_per_direction();
	box->set_x(1);
	box->set_y(2);
	box->set_width(28);
	box->set_height(29);

	std::string encoded;
	ASSERT_TRUE(source.SerializeToString(&encoded));
	const auto* bytes = reinterpret_cast<const std::byte*>(encoded.data());
	const auto catalog = assets::AppearanceCatalog::decode(
		std::span<const std::byte>(bytes, encoded.size())
	);
	ASSERT_TRUE(catalog.has_value());

	const auto* decoded = catalog->find(assets::AppearanceKind::Object, 4200);
	ASSERT_NE(decoded, nullptr);
	ASSERT_EQ(decoded->frameGroups.size(), 1);
	const auto& decodedGroup = decoded->frameGroups.front();
	ASSERT_TRUE(decodedGroup.fixedFrameGroup.has_value());
	EXPECT_EQ(*decodedGroup.fixedFrameGroup, assets::FixedFrameGroup::ObjectInitial);
	ASSERT_TRUE(decodedGroup.id.has_value());
	EXPECT_EQ(*decodedGroup.id, 0U);
	ASSERT_TRUE(decodedGroup.spriteInfo.has_value());

	const auto& decodedSprites = *decodedGroup.spriteInfo;
	EXPECT_EQ(decodedSprites.patternWidth, 2U);
	EXPECT_EQ(decodedSprites.patternHeight, 3U);
	EXPECT_EQ(decodedSprites.patternDepth, 1U);
	EXPECT_EQ(decodedSprites.layers, 2U);
	EXPECT_EQ(decodedSprites.spriteIds, (std::vector<std::uint32_t> { 101, 102 }));
	EXPECT_EQ(decodedSprites.boundingSquare, 2U);
	ASSERT_TRUE(decodedSprites.opaque.has_value());
	EXPECT_FALSE(*decodedSprites.opaque);
	ASSERT_TRUE(decodedSprites.animation.has_value());
	EXPECT_EQ(decodedSprites.animation->synchronized, true);
	EXPECT_EQ(decodedSprites.animation->loopType, assets::AnimationLoopType::Counted);
	EXPECT_EQ(decodedSprites.animation->loopCount, 4U);
	ASSERT_EQ(decodedSprites.animation->phases.size(), 1);
	EXPECT_EQ(decodedSprites.animation->phases.front().durationMinimum, 80U);
	EXPECT_EQ(decodedSprites.animation->phases.front().durationMaximum, 120U);
	ASSERT_EQ(decodedSprites.boundingBoxesPerDirection.size(), 1);
	EXPECT_EQ(decodedSprites.boundingBoxesPerDirection.front().x, 1U);
	EXPECT_EQ(decodedSprites.boundingBoxesPerDirection.front().y, 2U);
	EXPECT_EQ(decodedSprites.boundingBoxesPerDirection.front().width, 28U);
	EXPECT_EQ(decodedSprites.boundingBoxesPerDirection.front().height, 29U);
}

TEST(AppearanceCatalog, AcceptsAppearancesWithoutSpriteFrameGroups) {
	tibia::protobuf::appearances::Appearances source;
	source.add_object()->set_id(4201);

	std::string encoded;
	ASSERT_TRUE(source.SerializeToString(&encoded));
	const auto* bytes = reinterpret_cast<const std::byte*>(encoded.data());
	const auto catalog = assets::AppearanceCatalog::decode(
		std::span<const std::byte>(bytes, encoded.size())
	);
	ASSERT_TRUE(catalog.has_value());

	const auto* decoded = catalog->find(assets::AppearanceKind::Object, 4201);
	ASSERT_NE(decoded, nullptr);
	EXPECT_TRUE(decoded->frameGroups.empty());
}
