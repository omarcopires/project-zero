#include "protocol/game/initial_world_response_codec.h"

#include "protocol/binary/little_endian.h"

#include <cstdint>

namespace protocol::game {
	namespace {

		constexpr std::uint8_t pendingOpcode = 0x0A;
		constexpr std::uint8_t enterWorldOpcode = 0x0F;
		constexpr std::uint8_t updateNeededOpcode = 0x11;
		constexpr std::uint8_t loginErrorOpcode = 0x14;
		constexpr std::uint8_t loginAdviceOpcode = 0x15;
		constexpr std::uint8_t loginWaitOpcode = 0x16;
		constexpr std::uint8_t loginSuccessOpcode = 0x17;
		constexpr std::uint8_t loginTokenOpcode = 0x18;
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

		const auto opcode = std::to_integer<std::uint8_t>(payload.front());
		if (opcode == pendingOpcode || opcode == enterWorldOpcode) {
			return {
				.status = InitialWorldResponseStatus::Ready,
				.kind = opcode == pendingOpcode ? InitialWorldResponseKind::Pending : InitialWorldResponseKind::EnterWorld,
				.bytesConsumed = 1,
			};
		}
		if (opcode == updateNeededOpcode) {
			return messageResponse(payload, InitialWorldResponseKind::UpdateNeeded, false);
		}
		if (opcode == loginErrorOpcode) {
			return messageResponse(payload, InitialWorldResponseKind::LoginError, false);
		}
		if (opcode == loginAdviceOpcode) {
			return messageResponse(payload, InitialWorldResponseKind::LoginAdvice, false);
		}
		if (opcode == loginWaitOpcode) {
			return messageResponse(payload, InitialWorldResponseKind::LoginWait, true);
		}
		if (opcode == loginTokenOpcode) {
			if (payload.size() < 2) {
				return { .status = InitialWorldResponseStatus::Truncated, .kind = InitialWorldResponseKind::LoginToken };
			}
			return {
				.status = InitialWorldResponseStatus::Ready,
				.kind = InitialWorldResponseKind::LoginToken,
				.bytesConsumed = 2,
				.tokenAccepted = std::to_integer<std::uint8_t>(payload[1]) != 0,
			};
		}
		if (opcode != loginSuccessOpcode) {
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
