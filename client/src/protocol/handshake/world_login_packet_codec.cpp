#include "protocol/handshake/world_login_packet_codec.h"

#include "core/client_identity.h"
#include "protocol/binary/adler32.h"
#include "protocol/binary/length_prefixed_string.h"
#include "protocol/binary/little_endian.h"
#include "protocol/constants/world_handshake_constants.h"
#include "protocol/crypto/raw_rsa.h"
#include "protocol/framing/modern_frame.h"
#include "protocol/handshake/world_login_block_codec.h"

#include <string>
#include <utility>
#include <vector>

namespace protocol::handshake {

	WorldLoginPacketResult encodeWorldLoginPacket(const WorldLoginPacketRequest &request) {
		if (request.assetHashIdentifier.empty()) {
			return { .status = WorldLoginPacketStatus::EmptyAssetHashIdentifier };
		}

		const auto loginBlock = encodeWorldLoginBlock(request.loginBlock);
		if (loginBlock.status != WorldLoginBlockStatus::Ready) {
			return { .status = WorldLoginPacketStatus::InvalidLoginBlock };
		}
		const auto encryptedBlock = crypto::encryptRawRsa(
			loginBlock.plaintext,
			constants::openTibiaRsaModulus,
			constants::openTibiaRsaExponent);
		if (encryptedBlock.status != crypto::RawRsaStatus::Ready) {
			return { .status = WorldLoginPacketStatus::EncryptionFailed };
		}

		std::vector<std::byte> payload;
		binary::appendU16(payload, constants::gameLoginProtocolId);
		binary::appendU16(payload, constants::windowsOperatingSystem);
		binary::appendU16(payload, client::identity::version);
		binary::appendU32(payload, client::identity::version);
		if (!binary::appendStringU16(payload, std::to_string(client::identity::version))
		    || !binary::appendStringU16(payload, request.assetHashIdentifier)) {
			return { .status = WorldLoginPacketStatus::MetadataStringTooLong };
		}
		payload.push_back(static_cast<std::byte>(constants::gamePreviewStateDisabled));
		payload.insert(payload.end(), encryptedBlock.ciphertext.begin(), encryptedBlock.ciphertext.end());

		const auto bodySizeWithoutPadding = constants::checksumSize + payload.size();
		const auto remainder = bodySizeWithoutPadding % framing::modernFrameBlockSize;
		const auto paddingSize = (framing::modernFrameExtraBytes + framing::modernFrameBlockSize - remainder)
			% framing::modernFrameBlockSize;
		payload.resize(payload.size() + paddingSize, std::byte { 0x00 });

		std::vector<std::byte> body;
		body.reserve(constants::checksumSize + payload.size());
		binary::appendU32(body, binary::adler32(payload));
		body.insert(body.end(), payload.begin(), payload.end());

		auto frame = framing::encodeModernFrame(body);
		if (frame.error) {
			return { .status = WorldLoginPacketStatus::FrameEncodingFailed };
		}
		return { .status = WorldLoginPacketStatus::Ready, .bytes = std::move(frame.bytes) };
	}

}
