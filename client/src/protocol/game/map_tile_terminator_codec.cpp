#include "protocol/game/map_tile_terminator_codec.h"

#include "protocol/binary/little_endian.h"

#include <cstddef>
#include <cstdint>

namespace protocol::game {
	namespace {

		constexpr std::size_t terminatorSize = sizeof(std::uint16_t);
		constexpr std::uint16_t tileListTerminatorBase = 0xFF00;
		constexpr std::uint16_t emptyTileCountMask = 0x00FF;

	}

	MapTileTerminator decodeMapTileTerminator(const std::span<const std::byte> payload) {
		if (payload.empty()) {
			return { .status = MapTileTerminatorStatus::EmptyInput };
		}
		if (payload.size() < terminatorSize) {
			return { .status = MapTileTerminatorStatus::Truncated };
		}

		const auto value = binary::readU16(payload);
		if (!value) {
			return { .status = MapTileTerminatorStatus::Truncated };
		}
		if (*value < tileListTerminatorBase) {
			return { .status = MapTileTerminatorStatus::ThingData };
		}

		return {
			.status = MapTileTerminatorStatus::EmptyRun,
			.emptyTileCount = static_cast<std::uint8_t>(*value & emptyTileCountMask),
			.bytesConsumed = terminatorSize,
		};
	}

}
