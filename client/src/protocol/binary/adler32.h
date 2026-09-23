#pragma once

#include <cstddef>
#include <cstdint>
#include <span>

namespace protocol::binary {

	std::uint32_t adler32(std::span<const std::byte> bytes);

}
