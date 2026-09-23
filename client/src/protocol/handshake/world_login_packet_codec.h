#pragma once

#include "protocol/handshake/world_login_packet_request.h"
#include "protocol/handshake/world_login_packet_result.h"

namespace protocol::handshake {

	[[nodiscard]] WorldLoginPacketResult encodeWorldLoginPacket(const WorldLoginPacketRequest &request);

}
