#include "protocol/game/initial_world_response_codec.h"

#include "protocol/binary/little_endian.h"
#include "protocol/game/game_server_opcode.h"

#include <cstdint>

namespace protocol::game {
	namespace {

		constexpr std::size_t encodedDoubleSize = 5;

		bool readString(const std::span<const std::byte> payload, std::size_t &offset, std::string &value) {
			const auto length = binary::readU16(payload, offset);
			if (!length || offset + sizeof(std::uint16_t) + *length > payload.size()) {
				return false;
			}
			offset += sizeof(std::uint16_t);
			value.assign(reinterpret_cast<const char*>(payload.data() + offset), *length);
			offset += *length;
			return true;
		}

		bool skipStringList(const std::span<const std::byte> payload, std::size_t &offset) {
			const auto count = binary::readU16(payload, offset);
			if (!count) {
				return false;
			}
			offset += sizeof(std::uint16_t);
			for (std::uint16_t index = 0; index < *count; ++index) {
				const auto length = binary::readU16(payload, offset);
				if (!length || offset + sizeof(std::uint16_t) + *length > payload.size()) {
					return false;
				}
				offset += sizeof(std::uint16_t) + *length;
			}
			return true;
		}

		InitialWorldResponse messageResponse(
			const std::span<const std::byte> payload,
			const InitialWorldResponseKind kind,
			const bool hasWaitSeconds) {
			InitialWorldResponse result { .kind = kind };
			std::size_t offset = 1;
			if (!readString(payload, offset, result.message)
			    || (hasWaitSeconds && offset >= payload.size())) {
				result.status = InitialWorldResponseStatus::Truncated;
				return result;
			}
			if (hasWaitSeconds) {
				result.waitSeconds = std::to_integer<std::uint8_t>(payload[offset++]);
			}
			result.status = InitialWorldResponseStatus::Ready;
			result.bytesConsumed = offset;
			return result;
		}

	}

	InitialWorldResponse decodeInitialWorldResponse(const std::span<const std::byte> payload) {
		if (payload.empty()) {
			return {};
		}

		const auto opcode = static_cast<GameServerOpcode>(std::to_integer<std::uint8_t>(payload.front()));
		if (opcode == GameServerOpcode::PendingState || opcode == GameServerOpcode::EnterWorld) {
			return {
				.status = InitialWorldResponseStatus::Ready,
				.kind = opcode == GameServerOpcode::PendingState ? InitialWorldResponseKind::Pending : InitialWorldResponseKind::EnterWorld,
				.bytesConsumed = 1,
			};
		}
		if (opcode == GameServerOpcode::UpdateNeeded) {
			return messageResponse(payload, InitialWorldResponseKind::UpdateNeeded, false);
		}
		if (opcode == GameServerOpcode::LoginError) {
			return messageResponse(payload, InitialWorldResponseKind::LoginError, false);
		}
		if (opcode == GameServerOpcode::LoginAdvice) {
			return messageResponse(payload, InitialWorldResponseKind::LoginAdvice, false);
		}
		if (opcode == GameServerOpcode::LoginWait) {
			return messageResponse(payload, InitialWorldResponseKind::LoginWait, true);
		}
		if (opcode == GameServerOpcode::SessionEnd) {
			if (payload.size() < 2) {
				return { .status = InitialWorldResponseStatus::Truncated, .kind = InitialWorldResponseKind::SessionEnd };
			}
			return {
				.status = InitialWorldResponseStatus::Ready,
				.kind = InitialWorldResponseKind::SessionEnd,
				.bytesConsumed = 2,
				.sessionEndReason = std::to_integer<std::uint8_t>(payload[1]),
			};
		}
		if (opcode == GameServerOpcode::AllowBugReport || opcode == GameServerOpcode::ServerTime) {
			const std::size_t dataSize = opcode == GameServerOpcode::AllowBugReport ? 1 : 2;
			if (payload.size() < 1 + dataSize) {
				return { .status = InitialWorldResponseStatus::Truncated, .kind = InitialWorldResponseKind::Auxiliary };
			}
			return {
				.status = InitialWorldResponseStatus::Ready,
				.kind = InitialWorldResponseKind::Auxiliary,
				.bytesConsumed = 1 + dataSize,
			};
		}
		if (opcode == GameServerOpcode::ExivaRestrictions) {
			std::size_t offset = 1;
			if (payload.size() - offset < 6) {
				return { .status = InitialWorldResponseStatus::Truncated, .kind = InitialWorldResponseKind::Auxiliary };
			}
			offset += 6;
			for (int listIndex = 0; listIndex < 4; ++listIndex) {
				if (!skipStringList(payload, offset)) {
					return { .status = InitialWorldResponseStatus::Truncated, .kind = InitialWorldResponseKind::Auxiliary };
				}
			}
			return {
				.status = InitialWorldResponseStatus::Ready,
				.kind = InitialWorldResponseKind::Auxiliary,
				.bytesConsumed = offset,
			};
		}
		if (opcode != GameServerOpcode::LoginSuccess) {
			return { .status = InitialWorldResponseStatus::UnsupportedOpcode };
		}

		InitialWorldResponse result { .kind = InitialWorldResponseKind::LoginSuccess };
		constexpr std::size_t fixedPrefixSize = 1 + sizeof(std::uint32_t) + sizeof(std::uint16_t)
		    + (3 * encodedDoubleSize) + 2;
		if (payload.size() < fixedPrefixSize) {
			result.status = InitialWorldResponseStatus::Truncated;
			return result;
		}
		result.playerId = *binary::readU32(payload, 1);
		result.serverBeat = *binary::readU16(payload, 5);
		std::size_t offset = fixedPrefixSize;
		if (!readString(payload, offset, result.storeImagesUrl) || payload.size() - offset < 3) {
			result.status = InitialWorldResponseStatus::Truncated;
			return result;
		}
		offset += sizeof(std::uint16_t); // Store coin packet size.
		offset += 1; // Exiva button enabled.
		result.status = InitialWorldResponseStatus::Ready;
		result.bytesConsumed = offset;
		return result;
	}

}
