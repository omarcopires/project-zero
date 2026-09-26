#pragma once

#include "assets/lzma_decode_result.h"

#include <cstddef>
#include <cstdint>
#include <span>

namespace assets {

	LzmaDecodeResult decodeLzmaAlone(
		std::span<const std::byte> compressedBytes,
		std::size_t maximumOutputBytes,
		std::uint64_t maximumMemoryBytes
	);

}
