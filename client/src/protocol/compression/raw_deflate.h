#pragma once

#include <cstddef>
#include <span>
#include <vector>

namespace protocol::compression {

	enum class RawDeflateStatus {
		Ready,
		EmptyInput,
		InvalidOutputLimit,
		OutputLimitExceeded,
		InvalidStream,
		TrailingData,
	};

	struct RawDeflateResult {
		RawDeflateStatus status = RawDeflateStatus::InvalidStream;
		std::vector<std::byte> bytes;
	};

	[[nodiscard]] RawDeflateResult decompressRawDeflate(
		std::span<const std::byte> compressed,
		std::size_t maximumOutputBytes);

}
