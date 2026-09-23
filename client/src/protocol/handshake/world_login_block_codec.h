#pragma once

#include "protocol/handshake/world_login_block_request.h"
#include "protocol/handshake/world_login_block_result.h"

namespace protocol::handshake {

	WorldLoginBlockResult encodeWorldLoginBlock(const WorldLoginBlockRequest &request);

}
