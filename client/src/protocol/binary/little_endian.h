#pragma once

#include <cstddef>
#include <cstdint>
#include <optional>
#include <span>
#include <vector>

namespace protocol::binary {

	std::optional<std::uint16_t> readU16(std::span<const std::byte> bytes, std::size_t offset = 0);
	std::optional<std::uint32_t> readU32(std::span<const std::byte> bytes, std::size_t offset = 0);
	void appendU16(std::vector<std::byte> &output, std::uint16_t value);
	void appendU32(std::vector<std::byte> &output, std::uint32_t value);

}
