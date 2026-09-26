#include "protocol/game/map_description_codec.h"

#include "protocol/binary/little_endian.h"
#include "protocol/game/container_special_type.h"
#include "protocol/game/creature_wire_type.h"
#include "protocol/game/game_server_thing_marker.h"
#include "protocol/game/map_description_header_codec.h"
#include "protocol/game/map_tile_terminator_codec.h"

#include <algorithm>
#include <cstddef>
#include <cstdint>
#include <functional>
#include <optional>
#include <span>
#include <utility>
#include <vector>

namespace protocol::game {
	namespace {

		constexpr std::uint16_t tileWidth = 18;
		constexpr std::uint16_t tileHeight = 14;
		constexpr std::int32_t horizontalRadius = 8;
		constexpr std::int32_t verticalRadius = 6;
		constexpr std::uint8_t surfaceFloor = 7;
		constexpr std::uint8_t floorCount = 16;
		constexpr std::uint8_t undergroundFloorRadius = 2;
		constexpr std::size_t maximumThingsPerTile = 10;
		constexpr std::uint8_t maximumCreatureIcons = 3;
		constexpr std::int32_t maximumCoordinate = 0xFFFF;

		class Cursor {
		public:
			explicit Cursor(const std::span<const std::byte> bytes, const std::size_t offset = 0) :
				m_bytes(bytes),
				m_offset(offset) {
			}

			std::optional<std::uint8_t> readU8() {
				if (!has(sizeof(std::uint8_t))) {
					return std::nullopt;
				}
				return std::to_integer<std::uint8_t>(m_bytes[m_offset++]);
			}

			std::optional<std::uint16_t> readU16() {
				const auto value = binary::readU16(m_bytes, m_offset);
				if (value) {
					m_offset += sizeof(std::uint16_t);
				}
				return value;
			}

			std::optional<std::uint32_t> readU32() {
				const auto value = binary::readU32(m_bytes, m_offset);
				if (value) {
					m_offset += sizeof(std::uint32_t);
				}
				return value;
			}

			std::span<const std::byte> remaining() const {
				return m_bytes.subspan(m_offset);
			}

			bool skip(const std::size_t count) {
				if (!has(count)) {
					return false;
				}
				m_offset += count;
				return true;
			}

			bool skipString() {
				const auto length = readU16();
				return length && skip(*length);
			}

			std::size_t offset() const {
				return m_offset;
			}

		private:
			bool has(const std::size_t count) const {
				return m_offset <= m_bytes.size() && count <= m_bytes.size() - m_offset;
			}

			std::span<const std::byte> m_bytes;
			std::size_t m_offset = 0;
		};

		struct TileDecodeState {
			MapDescriptionDecodeStatus status = MapDescriptionDecodeStatus::Ready;
			std::uint8_t pendingEmptyTiles = 0;
			bool invalidRunLength = false;
		};

		bool skipContainerPayload(Cursor &cursor, const ContainerSpecialType type) {
			switch (type) {
				case ContainerSpecialType::None:
				case ContainerSpecialType::LootContainer:
				case ContainerSpecialType::LootHighlight:
				case ContainerSpecialType::Obtain:
					return true;
				case ContainerSpecialType::ContentCounter:
					return cursor.skip(4);
				case ContainerSpecialType::Manager:
					return cursor.skip(8);
				case ContainerSpecialType::QuiverLoot:
					return cursor.skip(12);
			}
			return false;
		}

		bool decodeObject(
			Cursor &cursor,
			const std::uint16_t id,
			const AppearanceLookup &appearanceLookup,
			MapThing &thing,
			MapDescriptionDecodeStatus &status) {
			const auto *appearance = appearanceLookup
				? appearanceLookup(assets::AppearanceKind::Object, id)
				: nullptr;
			if (appearance == nullptr) {
				status = MapDescriptionDecodeStatus::UnknownAppearance;
				return false;
			}

			thing.kind = MapThingKind::Object;
			thing.id = id;
			const auto &flags = appearance->flags;
			if (flags.cumulative) {
				const auto count = cursor.readU8();
				if (!count) {
					status = MapDescriptionDecodeStatus::Truncated;
					return false;
				}
				thing.count = *count;
			}
			if (flags.liquidPool || flags.liquidContainer) {
				const auto subtype = cursor.readU8();
				if (!subtype) {
					status = MapDescriptionDecodeStatus::Truncated;
					return false;
				}
				thing.subtype = *subtype;
			}
			if (flags.container) {
				const auto typeValue = cursor.readU8();
				if (!typeValue) {
					status = MapDescriptionDecodeStatus::Truncated;
					return false;
				}
				const auto type = static_cast<ContainerSpecialType>(*typeValue);
				if (!skipContainerPayload(cursor, type)) {
					const bool knownType = type == ContainerSpecialType::None
						|| type == ContainerSpecialType::LootContainer
						|| type == ContainerSpecialType::ContentCounter
						|| type == ContainerSpecialType::LootHighlight
						|| type == ContainerSpecialType::Obtain
						|| type == ContainerSpecialType::Manager
						|| type == ContainerSpecialType::QuiverLoot;
					status = knownType
						? MapDescriptionDecodeStatus::Truncated
						: MapDescriptionDecodeStatus::UnsupportedContainerType;
					return false;
				}
			}
			if (flags.upgradeClassification > 0) {
				const auto tier = cursor.readU8();
				if (!tier) {
					status = MapDescriptionDecodeStatus::Truncated;
					return false;
				}
				thing.tier = *tier;
			}
			if ((flags.expire || flags.expireStop || flags.clockExpire) && !cursor.skip(5)) {
				status = MapDescriptionDecodeStatus::Truncated;
				return false;
			}
			if (flags.wearOut && !cursor.skip(5)) {
				status = MapDescriptionDecodeStatus::Truncated;
				return false;
			}
			if (flags.decoItemKit) {
				if (!cursor.skip(sizeof(std::uint16_t))) {
					status = MapDescriptionDecodeStatus::Truncated;
					return false;
				}
				status = MapDescriptionDecodeStatus::UnsupportedAppearanceFeature;
				return false;
			}
			return true;
		}

		bool skipCreatureOutfit(
			Cursor &cursor,
			const AppearanceLookup &appearanceLookup,
			MapThing &thing,
			MapDescriptionDecodeStatus &status) {
			const auto lookType = cursor.readU16();
			if (!lookType) {
				status = MapDescriptionDecodeStatus::Truncated;
				return false;
			}
			std::uint32_t appearanceId = *lookType;
			bool appearanceIsObject = false;
			if (*lookType != 0) {
				if (!appearanceLookup || !appearanceLookup(assets::AppearanceKind::Outfit, *lookType)) {
					status = MapDescriptionDecodeStatus::UnknownAppearance;
					return false;
				}
				if (!cursor.skip(5)) {
					status = MapDescriptionDecodeStatus::Truncated;
					return false;
				}
			} else {
				const auto lookTypeEx = cursor.readU16();
				if (!lookTypeEx) {
					status = MapDescriptionDecodeStatus::Truncated;
					return false;
				}
				appearanceId = *lookTypeEx;
				appearanceIsObject = *lookTypeEx != 0;
				if (*lookTypeEx != 0
				    && (!appearanceLookup || !appearanceLookup(assets::AppearanceKind::Object, *lookTypeEx))) {
					status = MapDescriptionDecodeStatus::UnknownAppearance;
					return false;
				}
			}

			const auto mount = cursor.readU16();
			if (!mount) {
				status = MapDescriptionDecodeStatus::Truncated;
				return false;
			}
			if (*mount != 0) {
				if (!appearanceLookup || !appearanceLookup(assets::AppearanceKind::Outfit, *mount)) {
					status = MapDescriptionDecodeStatus::UnknownAppearance;
					return false;
				}
				if (!cursor.skip(4)) {
					status = MapDescriptionDecodeStatus::Truncated;
					return false;
				}
			}
			thing.appearanceId = appearanceId;
			thing.appearanceIsObject = appearanceIsObject;
			return true;
		}

		bool skipCreature(
			Cursor &cursor,
			const std::uint16_t marker,
			const AppearanceLookup &appearanceLookup,
			MapThing &thing,
			MapDescriptionDecodeStatus &status) {
			const bool known = marker == static_cast<std::uint16_t>(GameServerThingMarker::KnownCreature);
			const bool unknown = marker == static_cast<std::uint16_t>(GameServerThingMarker::UnknownCreature);
			const bool update = marker == static_cast<std::uint16_t>(GameServerThingMarker::CreatureUpdate);
			if (!known && !unknown && !update) {
				status = MapDescriptionDecodeStatus::InvalidThing;
				return false;
			}

			if (update) {
				const auto id = cursor.readU32();
				if (!id || !cursor.skip(2)) {
					status = MapDescriptionDecodeStatus::Truncated;
					return false;
				}
				thing.kind = MapThingKind::CreatureUpdate;
				thing.id = *id;
				return true;
			}

			if (unknown && !cursor.skip(4)) {
				status = MapDescriptionDecodeStatus::Truncated;
				return false;
			}
			const auto id = cursor.readU32();
			if (!id) {
				status = MapDescriptionDecodeStatus::Truncated;
				return false;
			}
			thing.kind = MapThingKind::Creature;
			thing.id = *id;

			if (unknown) {
				const auto creatureType = cursor.readU8();
				if (!creatureType) {
					status = MapDescriptionDecodeStatus::Truncated;
					return false;
				}
				if (*creatureType > static_cast<std::uint8_t>(CreatureWireType::Hidden)) {
					status = MapDescriptionDecodeStatus::InvalidThing;
					return false;
				}
				if (*creatureType == static_cast<std::uint8_t>(CreatureWireType::SummonPlayer) && !cursor.skip(4)) {
					status = MapDescriptionDecodeStatus::Truncated;
					return false;
				}
				if (!cursor.skipString()) {
					status = MapDescriptionDecodeStatus::Truncated;
					return false;
				}
			}

			if (!cursor.skip(2)) {
				status = MapDescriptionDecodeStatus::Truncated;
				return false;
			}
			if (!skipCreatureOutfit(cursor, appearanceLookup, thing, status)) {
				return false;
			}
			if (!cursor.skip(4)) {
				status = MapDescriptionDecodeStatus::Truncated;
				return false;
			}
			const auto iconCount = cursor.readU8();
			if (!iconCount || *iconCount > maximumCreatureIcons || !cursor.skip(static_cast<std::size_t>(*iconCount) * 4)) {
				status = MapDescriptionDecodeStatus::Truncated;
				return false;
			}
			if (!cursor.skip(2 + (known ? 0 : 1))) {
				status = MapDescriptionDecodeStatus::Truncated;
				return false;
			}

			const auto finalCreatureType = cursor.readU8();
			if (!finalCreatureType) {
				status = MapDescriptionDecodeStatus::Truncated;
				return false;
			}
			if (*finalCreatureType > static_cast<std::uint8_t>(CreatureWireType::Hidden)) {
				status = MapDescriptionDecodeStatus::InvalidThing;
				return false;
			}
			if (*finalCreatureType == static_cast<std::uint8_t>(CreatureWireType::SummonPlayer) && !cursor.skip(4)) {
				status = MapDescriptionDecodeStatus::Truncated;
				return false;
			}
			if (*finalCreatureType == static_cast<std::uint8_t>(CreatureWireType::Player) && !cursor.skip(1)) {
				status = MapDescriptionDecodeStatus::Truncated;
				return false;
			}
			if (!cursor.skip(4)) {
				status = MapDescriptionDecodeStatus::Truncated;
				return false;
			}
			return true;
		}

		bool decodeTile(
			Cursor &cursor,
			const WorldPosition position,
			const AppearanceLookup &appearanceLookup,
			MapTile &tile,
			TileDecodeState &state) {
			const auto firstTerminator = decodeMapTileTerminator(cursor.remaining());
			if (firstTerminator.status == MapTileTerminatorStatus::EmptyRun) {
				if (!cursor.skip(firstTerminator.bytesConsumed)) {
					state.status = MapDescriptionDecodeStatus::Truncated;
					return false;
				}
				state.pendingEmptyTiles = firstTerminator.emptyTileCount;
				state.invalidRunLength = firstTerminator.emptyTileCount == 0;
				return true;
			}
			if (firstTerminator.status != MapTileTerminatorStatus::ThingData) {
				state.status = MapDescriptionDecodeStatus::Truncated;
				return false;
			}

			tile.position = position;
			for (std::size_t count = 0; count <= maximumThingsPerTile; ++count) {
				const auto nextTerminator = decodeMapTileTerminator(cursor.remaining());
				if (nextTerminator.status == MapTileTerminatorStatus::EmptyRun) {
					if (!cursor.skip(nextTerminator.bytesConsumed)) {
						state.status = MapDescriptionDecodeStatus::Truncated;
						return false;
					}
					state.pendingEmptyTiles = nextTerminator.emptyTileCount;
					state.invalidRunLength = false;
					return true;
				}
				if (nextTerminator.status != MapTileTerminatorStatus::ThingData) {
					state.status = MapDescriptionDecodeStatus::Truncated;
					return false;
				}
				if (count == maximumThingsPerTile) {
					state.status = MapDescriptionDecodeStatus::TooManyThingsOnTile;
					return false;
				}

				const auto id = cursor.readU16();
				if (!id || *id == 0) {
					state.status = MapDescriptionDecodeStatus::InvalidThing;
					return false;
				}
				MapThing thing;
				if (*id == static_cast<std::uint16_t>(GameServerThingMarker::KnownCreature)
				    || *id == static_cast<std::uint16_t>(GameServerThingMarker::UnknownCreature)
				    || *id == static_cast<std::uint16_t>(GameServerThingMarker::CreatureUpdate)) {
					if (!skipCreature(cursor, *id, appearanceLookup, thing, state.status)) {
						return false;
					}
				} else {
					if (!decodeObject(cursor, *id, appearanceLookup, thing, state.status)) {
						return false;
					}
				}
				tile.things.push_back(thing);
			}
			state.status = MapDescriptionDecodeStatus::TooManyThingsOnTile;
			return false;
		}

		std::vector<std::uint8_t> floorsFor(const std::uint8_t centerFloor) {
			std::vector<std::uint8_t> floors;
			if (centerFloor > surfaceFloor) {
				const auto first = centerFloor > undergroundFloorRadius ? centerFloor - undergroundFloorRadius : 0;
				const auto last = std::min<std::uint8_t>(floorCount - 1, centerFloor + undergroundFloorRadius);
				for (int floor = first; floor <= last; ++floor) {
					floors.push_back(static_cast<std::uint8_t>(floor));
				}
				return floors;
			}

			for (std::int32_t floor = surfaceFloor; floor >= 0; --floor) {
				floors.push_back(static_cast<std::uint8_t>(floor));
			}
			return floors;
		}

	}

	MapDescriptionDecodeResult decodeMapDescription(
		const std::span<const std::byte> payload,
		const AppearanceLookup &appearanceLookup) {
		const auto header = decodeMapDescriptionHeader(payload);
		if (!header || header->center.floor >= floorCount) {
			return { .status = MapDescriptionDecodeStatus::InvalidHeader };
		}

		MapDescription description;
		description.center = header->center;
		Cursor cursor(payload, header->bytesConsumed);
		TileDecodeState state;
		const auto floors = floorsFor(header->center.floor);
		description.tiles.reserve(static_cast<std::size_t>(tileWidth) * tileHeight * floors.size());
		const auto minimumX = static_cast<std::int32_t>(header->center.x) - horizontalRadius;
		const auto minimumY = static_cast<std::int32_t>(header->center.y) - verticalRadius;
		const auto maximumX = minimumX + static_cast<std::int32_t>(tileWidth) - 1
			+ static_cast<std::int32_t>(floors.size()) - 1;
		const auto maximumY = minimumY + static_cast<std::int32_t>(tileHeight) - 1
			+ static_cast<std::int32_t>(floors.size()) - 1;
		if (minimumX < 0 || minimumY < 0 || maximumX > maximumCoordinate || maximumY > maximumCoordinate) {
			return { .status = MapDescriptionDecodeStatus::InvalidHeader };
		}

		for (const auto floor : floors) {
			const auto floorOffset = static_cast<std::int32_t>(header->center.floor) - floor;
			for (std::uint16_t x = 0; x < tileWidth; ++x) {
				for (std::uint16_t y = 0; y < tileHeight; ++y) {
					const WorldPosition position {
						.x = static_cast<std::uint16_t>(static_cast<std::int32_t>(header->center.x) - horizontalRadius + x + floorOffset),
						.y = static_cast<std::uint16_t>(static_cast<std::int32_t>(header->center.y) - verticalRadius + y + floorOffset),
						.floor = floor,
					};
					if (state.pendingEmptyTiles > 0) {
						--state.pendingEmptyTiles;
						description.tiles.push_back({ .position = position });
						continue;
					}

					MapTile tile;
					if (!decodeTile(cursor, position, appearanceLookup, tile, state)) {
						return { .status = state.status, .description = std::move(description) };
					}
					if (state.invalidRunLength) {
						return { .status = MapDescriptionDecodeStatus::InvalidRunLength, .description = std::move(description) };
					}
					description.tiles.push_back(std::move(tile));
				}
			}
		}

		if (state.pendingEmptyTiles != 0) {
			return { .status = MapDescriptionDecodeStatus::InvalidRunLength, .description = std::move(description) };
		}
		description.bytesConsumed = cursor.offset();
		return { .status = MapDescriptionDecodeStatus::Ready, .description = std::move(description) };
	}

}
