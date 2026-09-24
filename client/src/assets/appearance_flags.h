#pragma once

#include <cstdint>

namespace assets {

	struct AppearanceFlags {
		bool cumulative = false;
		bool liquidPool = false;
		bool liquidContainer = false;
		bool container = false;
		std::uint32_t upgradeClassification = 0;
		bool expire = false;
		bool expireStop = false;
		bool clockExpire = false;
		bool wearOut = false;
		bool decoItemKit = false;
	};

}
