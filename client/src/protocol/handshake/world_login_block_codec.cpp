#include "protocol/handshake/world_login_block_codec.h"

#include "protocol/binary/length_prefixed_string.h"
#include "protocol/binary/little_endian.h"
#include "protocol/constants/world_handshake_constants.h"

#include <utility>

namespace protocol::handshake {

	WorldLoginBlockResult encodeWorldLoginBlock(const WorldLoginBlockRequest &request) {
		if (request.sessionKey.empty()) {
			return { .status = WorldLoginBlockStatus::EmptySessionKey };
		}
		if (request.characterName.empty()) {
			return { .status = WorldLoginBlockStatus::EmptyCharacterName };
		}

		std::vector<std::byte> plaintext;
		plaintext.reserve(constants::rsaBlockSize);
		plaintext.push_back(static_cast<std::byte>(constants::rsaPlaintextLeadingByte));
		for (const auto word : request.xteaKey) {
			binary::appendU32(plaintext, word);
		}
		plaintext.push_back(static_cast<std::byte>(constants::gameMasterFlagDisabled));

		if (!binary::appendStringU16(plaintext, request.sessionKey)
		    || !binary::appendStringU16(plaintext, request.characterName)) {
			return { .status = WorldLoginBlockStatus::StringTooLong };
		}
		binary::appendU32(plaintext, request.challenge.timestamp);
		plaintext.push_back(static_cast<std::byte>(request.challenge.random));
		binary::appendU16(plaintext, 0);

		if (plaintext.size() > constants::rsaBlockSize) {
			return { .status = WorldLoginBlockStatus::PayloadTooLarge };
		}
		plaintext.resize(constants::rsaBlockSize, std::byte { 0x00 });
		return { .status = WorldLoginBlockStatus::Ready, .plaintext = std::move(plaintext) };
	}

}
