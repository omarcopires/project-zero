#pragma once

#include "assets/lzma_decode_status.h"

#include <cstddef>
#include <vector>

namespace assets {

	struct LzmaDecodeResult {
		LzmaDecodeStatus status = LzmaDecodeStatus::InvalidStream;
		std::vector<std::byte> output;
	};

}
