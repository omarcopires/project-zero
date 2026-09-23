#pragma once

#include "protocol/crypto/xtea.h"

#include <cstddef>
#include <cstdint>
#include <span>
#include <vector>

namespace protocol::framing {

	enum class ModernSessionStatus {
		Ready,
		EmptyPayload,
		InvalidSequence,
		UnexpectedSequence,
		InvalidBodySize,
		InvalidPadding,
		EncryptionFailed,
		DecompressionFailed,
		FrameEncodingFailed,
	};

	struct ModernSessionResult {
		ModernSessionStatus status = ModernSessionStatus::InvalidBodySize;
		std::uint32_t sequence = 0;
		std::vector<std::byte> bytes;
	};

	[[nodiscard]] ModernSessionResult encodeModernSessionPacket(
		std::span<const std::byte> payload,
		const crypto::XteaKey &key,
		std::uint32_t sequence);

	[[nodiscard]] ModernSessionResult decodeModernSessionBody(
		std::span<const std::byte> body,
		const crypto::XteaKey &key,
		std::uint32_t expectedSequence);

}
