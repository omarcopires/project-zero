#include "protocol/binary/little_endian.h"
#include "protocol/game/map_description_codec.h"

#include <gtest/gtest.h>

#include <cstddef>
#include <cstdint>
#include <vector>

namespace protocol::game {
	namespace {

		constexpr std::size_t surfaceTileCount = 18 * 14 * 8;

		void appendEmptyRun(std::vector<std::byte> &payload, const std::size_t tileCount) {
			const auto runCount = static_cast<std::uint16_t>(tileCount - 1);
			binary::appendU16(payload, static_cast<std::uint16_t>(0xFF00U | runCount));
		}

		std::vector<std::byte> emptySurfaceMap() {
			std::vector<std::byte> payload { std::byte { 0x64 } };
			binary::appendU16(payload, 200);
			binary::appendU16(payload, 200);
			payload.push_back(std::byte { 7 });

			auto remaining = surfaceTileCount;
			while (remaining > 256) {
				appendEmptyRun(payload, 256);
				remaining -= 256;
			}
			appendEmptyRun(payload, remaining);
			return payload;
		}

		TEST(MapDescriptionCodec, ExpandsEmptyRunsAcrossSurfaceFloors) {
			const auto payload = emptySurfaceMap();

			const auto result = decodeMapDescription(payload, {});

			EXPECT_EQ(result.status, MapDescriptionDecodeStatus::Ready);
			EXPECT_EQ(result.description.center.x, 200);
			EXPECT_EQ(result.description.center.y, 200);
			EXPECT_EQ(result.description.center.floor, 7);
			ASSERT_EQ(result.description.tiles.size(), surfaceTileCount);
			for (const auto& tile : result.description.tiles) {
				EXPECT_TRUE(tile.things.empty());
			}
			EXPECT_EQ(result.description.bytesConsumed, payload.size());
		}

		TEST(MapDescriptionCodec, LeavesFollowingPayloadBytesUnread) {
			auto payload = emptySurfaceMap();
			const auto mapBytes = payload.size();
			payload.push_back(std::byte { 0x0F });

			const auto result = decodeMapDescription(payload, {});

			ASSERT_EQ(result.status, MapDescriptionDecodeStatus::Ready);
			EXPECT_EQ(result.description.bytesConsumed, mapBytes);
		}

		TEST(MapDescriptionCodec, RejectsTruncatedEmptyRun) {
			auto payload = emptySurfaceMap();
			payload.pop_back();

			const auto result = decodeMapDescription(payload, {});

			EXPECT_EQ(result.status, MapDescriptionDecodeStatus::Truncated);
		}

		TEST(MapDescriptionCodec, AcceptsZeroSkipTerminatorAfterObject) {
			auto payload = emptySurfaceMap();
			payload.resize(6);
			binary::appendU16(payload, 100);
			payload.push_back(std::byte { 2 });
			binary::appendU16(payload, 0xFF00);

			std::size_t remaining = surfaceTileCount - 1;
			while (remaining > 256) {
				appendEmptyRun(payload, 256);
				remaining -= 256;
			}
			appendEmptyRun(payload, remaining);

			const assets::AppearanceDefinition object {
				.id = 100,
				.kind = assets::AppearanceKind::Object,
				.flags = { .cumulative = true },
			};
			const auto result = decodeMapDescription(
				payload,
				[&object](const assets::AppearanceKind kind, const std::uint32_t id) {
					return kind == object.kind && id == object.id ? &object : nullptr;
				});

			ASSERT_EQ(result.status, MapDescriptionDecodeStatus::Ready);
			ASSERT_EQ(result.description.tiles.size(), surfaceTileCount);
			ASSERT_EQ(result.description.tiles.front().things.size(), 1);
			EXPECT_EQ(result.description.tiles.front().things.front().id, 100);
			EXPECT_EQ(result.description.tiles.front().things.front().count, 2);
		}

	}
}
