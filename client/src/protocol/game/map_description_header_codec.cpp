#include "protocol/game/map_description_header_codec.h"

#include "protocol/binary/little_endian.h"
#include "protocol/game/game_server_opcode.h"

#include <cstddef>
#include <cstdint>

namespace protocol::game {

	std::optional<MapDescriptionHeader> decodeMapDescriptionHeader(const std::span<const std::byte> payload) {
		constexpr std::size_t headerSize = 1 + (2 * sizeof(std::uint16_t)) + sizeof(std::uint8_t);
		if (payload.size() < headerSize
		    || static_cast<GameServerOpcode>(std::to_integer<std::uint8_t>(payload.front())) != GameServerOpcode::MapDescription) {
			return std::nullopt;
		}

		const auto x = binary::readU16(payload, 1);
		const auto y = binary::readU16(payload, 3);
		if (!x || !y) {
			return std::nullopt;
		}
		return MapDescriptionHeader {
			.center = {
				.x = *x,
				.y = *y,
				.floor = std::to_integer<std::uint8_t>(payload[5]),
			},
			.bytesConsumed = headerSize,
		};
	}

}
