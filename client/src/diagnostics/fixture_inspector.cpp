#include "diagnostics/fixture_inspector.h"

#include "protocol/framing/frame_decode_status.h"
#include "protocol/framing/frame_input_state.h"
#include "protocol/framing/modern_frame.h"

#include <algorithm>
#include <vector>

namespace diagnostics {
	namespace {

		using protocol::framing::decodeModernFrame;
		using protocol::framing::FrameDecodeStatus;
		using protocol::framing::FrameError;
		using protocol::framing::FrameInputState;

		bool consumeAvailableFrames(std::vector<std::byte> &bufferedData, FixtureInspectionResult &result, const FrameInputState inputState) {
			while (true) {
				const auto decoded = decodeModernFrame(bufferedData, inputState);
				switch (decoded.status) {
					case FrameDecodeStatus::FrameReady:
						++result.frameCount;
						bufferedData.erase(bufferedData.begin(), bufferedData.begin() + static_cast<std::ptrdiff_t>(decoded.bytesConsumed));
						break;
					case FrameDecodeStatus::NeedMoreData:
					case FrameDecodeStatus::StreamEnded:
						return true;
					case FrameDecodeStatus::Failure:
						result.error = decoded.error.value_or(FrameError::Truncated);
						return false;
				}
			}
		}

	}

	FixtureInspectionResult inspectFixture(const std::span<const std::byte> fixture) {
		FixtureInspectionResult result { .byteCount = fixture.size() };
		std::vector<std::byte> bufferedData(fixture.begin(), fixture.end());
		consumeAvailableFrames(bufferedData, result, FrameInputState::EndOfStream);
		return result;
	}

	FixtureInspectionResult inspectFragmentedFixture(const std::span<const std::byte> fixture, const std::size_t fragmentSize) {
		FixtureInspectionResult result { .byteCount = fixture.size() };
		if (fragmentSize == 0) {
			result.error = FrameError::InvalidBodySize;
			return result;
		}

		std::vector<std::byte> bufferedData;
		bufferedData.reserve(fixture.size());
		for (std::size_t offset = 0; offset < fixture.size(); offset += fragmentSize) {
			const auto currentSize = std::min(fragmentSize, fixture.size() - offset);
			const auto fragment = fixture.subspan(offset, currentSize);
			bufferedData.insert(bufferedData.end(), fragment.begin(), fragment.end());
			if (!consumeAvailableFrames(bufferedData, result, FrameInputState::Open)) {
				return result;
			}
		}

		consumeAvailableFrames(bufferedData, result, FrameInputState::EndOfStream);
		return result;
	}

}
