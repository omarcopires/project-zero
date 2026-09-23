#pragma once

#include "protocol/handshake/world_login_packet_status.h"

#include <cstddef>
#include <vector>

namespace protocol::handshake {

	struct WorldLoginPacketResult {
		WorldLoginPacketStatus status = WorldLoginPacketStatus::FrameEncodingFailed;
		std::vector<std::byte> bytes;
	};

}
