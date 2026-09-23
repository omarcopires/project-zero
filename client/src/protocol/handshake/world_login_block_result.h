#pragma once

#include "protocol/handshake/world_login_block_status.h"

#include <cstddef>
#include <vector>

namespace protocol::handshake {

	struct WorldLoginBlockResult {
		WorldLoginBlockStatus status = WorldLoginBlockStatus::PayloadTooLarge;
		std::vector<std::byte> plaintext;
	};

}
