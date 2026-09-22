#pragma once

#include "diagnostics/fixture_inspection_result.h"

#include <cstddef>
#include <span>

namespace diagnostics {

	FixtureInspectionResult inspectFixture(std::span<const std::byte> fixture);
	FixtureInspectionResult inspectFragmentedFixture(std::span<const std::byte> fixture, std::size_t fragmentSize);

}
