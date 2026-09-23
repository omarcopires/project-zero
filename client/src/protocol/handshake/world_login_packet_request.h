#pragma once

#include "protocol/handshake/world_login_block_request.h"

#include <string>

namespace protocol::handshake {

	struct WorldLoginPacketRequest {
		std::string assetHashIdentifier;
		WorldLoginBlockRequest loginBlock;
	};

}
