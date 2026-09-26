#pragma once

namespace assets {

	enum class LzmaDecodeStatus {
		Decoded,
		EmptyInput,
		InvalidConfiguration,
		MemoryLimitExceeded,
		ResourceFailure,
		OutputLimitExceeded,
		InvalidStream,
		TruncatedInput,
		TrailingData,
	};

}
