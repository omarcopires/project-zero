#pragma once

#include "protocol/constants/world_handshake_constants.h"

#include <array>
#include <cstddef>
#include <cstdint>
#include <span>
#include <vector>

namespace protocol::crypto {

	enum class XteaStatus {
		Ready,
		InvalidBlockSize,
	};

	struct XteaResult {
		XteaStatus status = XteaStatus::InvalidBlockSize;
		std::vector<std::byte> bytes;
	};

	using XteaKey = std::array<std::uint32_t, constants::xteaKeyWordCount>;

	[[nodiscard]] XteaResult encryptXtea(std::span<const std::byte> plaintext, const XteaKey &key);
	[[nodiscard]] XteaResult decryptXtea(std::span<const std::byte> ciphertext, const XteaKey &key);

}
