#pragma once

namespace assets {

	enum class LzmaDecodeStatus {
		Decoded,
		EmptyInput,
		InvalidConfiguration,
		InvalidContainerHeader,
		MemoryLimitExceeded,
		ResourceFailure,
		OutputLimitExceeded,
		InvalidStream,
		TruncatedInput,
		TrailingData,
	};

}
