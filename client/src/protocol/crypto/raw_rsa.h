#pragma once

#include <cstddef>
#include <cstdint>
#include <span>
#include <string_view>
#include <vector>

namespace protocol::crypto {

	enum class RawRsaStatus {
		Ready,
		InvalidBlockSize,
		InvalidPublicKey,
		MessageOutOfRange,
		EncryptionFailed,
	};

	struct RawRsaResult {
		RawRsaStatus status { RawRsaStatus::EncryptionFailed };
		std::vector<std::byte> ciphertext;
	};

	[[nodiscard]] RawRsaResult encryptRawRsa(
		std::span<const std::byte> plaintext,
		std::string_view modulusDecimal,
		std::uint32_t exponent);

}
