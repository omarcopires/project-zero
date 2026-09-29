#pragma once

namespace protocol::handshake {

	enum class WorldLoginPacketStatus {
		Ready,
		MetadataStringTooLong,
		InvalidLoginBlock,
		EncryptionFailed,
		FrameEncodingFailed,
	};

}
