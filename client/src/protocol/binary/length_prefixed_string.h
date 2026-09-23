#pragma once

#include <cstddef>
#include <string_view>
#include <vector>

namespace protocol::binary {

	bool appendStringU16(std::vector<std::byte> &output, std::string_view value);

}
