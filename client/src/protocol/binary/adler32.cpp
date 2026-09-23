#include "protocol/binary/adler32.h"

namespace protocol::binary {
	namespace {

		constexpr std::uint32_t adlerModulus = 65521;

	}

	std::uint32_t adler32(const std::span<const std::byte> bytes) {
		std::uint32_t a = 1;
		std::uint32_t b = 0;
		for (const auto value : bytes) {
			a = (a + std::to_integer<std::uint8_t>(value)) % adlerModulus;
			b = (b + a) % adlerModulus;
		}
		return (b << 16) | a;
	}

}
