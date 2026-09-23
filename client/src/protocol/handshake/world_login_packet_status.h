#pragma once

namespace protocol::handshake {

	enum class WorldLoginPacketStatus {
		Ready,
		EmptyAssetHashIdentifier,
		MetadataStringTooLong,
		InvalidLoginBlock,
		EncryptionFailed,
		FrameEncodingFailed,
	};

}
