#include "protocol/binary/length_prefixed_string.h"

#include "protocol/binary/little_endian.h"

#include <cstdint>
#include <limits>

namespace protocol::binary {

	bool appendStringU16(std::vector<std::byte> &output, const std::string_view value) {
		if (value.size() > std::numeric_limits<std::uint16_t>::max()) {
			return false;
		}

		appendU16(output, static_cast<std::uint16_t>(value.size()));
		for (const auto character : value) {
			output.push_back(static_cast<std::byte>(static_cast<unsigned char>(character)));
		}
		return true;
	}

}
