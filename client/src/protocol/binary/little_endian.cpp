#include "protocol/binary/little_endian.h"

namespace protocol::binary {
	namespace {

		template <typename Value>
		std::optional<Value> read(std::span<const std::byte> bytes, const std::size_t offset) {
			if (offset > bytes.size() || bytes.size() - offset < sizeof(Value)) {
				return std::nullopt;
			}

			Value result = 0;
			for (std::size_t index = 0; index < sizeof(Value); ++index) {
				result |= static_cast<Value>(std::to_integer<Value>(bytes[offset + index]) << (index * 8));
			}
			return result;
		}

		template <typename Value>
		void append(std::vector<std::byte> &output, const Value value) {
			for (std::size_t index = 0; index < sizeof(Value); ++index) {
				output.push_back(static_cast<std::byte>((value >> (index * 8)) & 0xFF));
			}
		}

	}

	std::optional<std::uint16_t> readU16(const std::span<const std::byte> bytes, const std::size_t offset) {
		return read<std::uint16_t>(bytes, offset);
	}

	std::optional<std::uint32_t> readU32(const std::span<const std::byte> bytes, const std::size_t offset) {
		return read<std::uint32_t>(bytes, offset);
	}

	void appendU16(std::vector<std::byte> &output, const std::uint16_t value) {
		append(output, value);
	}

	void appendU32(std::vector<std::byte> &output, const std::uint32_t value) {
		append(output, value);
	}

}
