#pragma once

namespace diagnostics {

	enum class DiagnosticExitCode : int {
		Success = 0,
		ConnectionFailure = 2,
		Timeout = 3,
		FramingFailure = 4,
		IncorrectUsage = 5,
	};

}
