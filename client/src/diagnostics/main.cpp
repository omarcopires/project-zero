#include "diagnostics/diagnostic_exit_code.h"
#include "diagnostics/fixture_inspector.h"
#include "infrastructure/logging/logger.h"
#include "infrastructure/transport/connection_options.h"
#include "infrastructure/transport/tcp_transport.h"
#include "infrastructure/transport/transport_error.h"
#include "infrastructure/transport/transport_failure.h"
#include "protocol/framing/frame_error.h"

#include <QCommandLineOption>
#include <QCommandLineParser>
#include <QCoreApplication>
#include <QFile>
#include <QHostAddress>
#include <QSettings>
#include <QStringList>

#include <chrono>
#include <cstddef>
#include <filesystem>
#include <span>
#include <string_view>

namespace {

	using diagnostics::DiagnosticExitCode;
	using infrastructure::logging::Logger;
	using infrastructure::transport::ConnectionOptions;
	using infrastructure::transport::TcpTransport;
	using infrastructure::transport::TransportError;
	using infrastructure::transport::TransportFailure;
	using protocol::framing::FrameError;

	constexpr qsizetype maximumFixtureSize = 16 * 1024 * 1024;

	int exitValue(const DiagnosticExitCode exitCode) {
		return static_cast<int>(exitCode);
	}

	std::string_view frameErrorName(const FrameError error) {
		switch (error) {
			case FrameError::Truncated:
				return "truncated";
			case FrameError::BodyTooLarge:
				return "body-too-large";
			case FrameError::InvalidBodySize:
				return "invalid-body-size";
		}

		return "unknown";
	}

	bool readFixture(const QString &path, QByteArray &fixture, Logger &logger) {
		QFile file(path);
		if (!file.open(QIODevice::ReadOnly)) {
			logger.error("readFixture", "Fixture could not be opened");
			return false;
		}

		if (file.size() > maximumFixtureSize) {
			logger.error("readFixture", "Fixture exceeds the {} byte diagnostic limit", maximumFixtureSize);
			return false;
		}

		fixture = file.readAll();
		if (file.error() != QFileDevice::NoError) {
			logger.error("readFixture", "Fixture could not be read");
			return false;
		}

		return true;
	}

	std::span<const std::byte> asBytes(const QByteArray &data) {
		return { reinterpret_cast<const std::byte*>(data.constData()), static_cast<std::size_t>(data.size()) };
	}

	int inspectFixtureFile(const QString &path, const std::size_t fragmentSize, const bool fragmented, Logger &logger) {
		QByteArray fixture;
		if (!readFixture(path, fixture, logger)) {
			return exitValue(DiagnosticExitCode::IncorrectUsage);
		}

		const auto result = fragmented ? diagnostics::inspectFragmentedFixture(asBytes(fixture), fragmentSize)
									   : diagnostics::inspectFixture(asBytes(fixture));
		if (result.error.has_value()) {
			logger.error(
				"inspectFixtureFile",
				"Fixture framing failed with error {}; bytes={}, frames={}",
				frameErrorName(*result.error),
				result.byteCount,
				result.frameCount
			);
			return exitValue(DiagnosticExitCode::FramingFailure);
		}

		logger.info(
			"inspectFixtureFile",
			"Fixture framing completed; bytes={}, frames={}, fragmented={}",
			result.byteCount,
			result.frameCount,
			fragmented
		);
		return exitValue(DiagnosticExitCode::Success);
	}

	int connectPassively(QCoreApplication &application, const QString &configurationPath, Logger &logger) {
		QSettings settings(configurationPath, QSettings::IniFormat);
		const auto host = settings.value(QStringLiteral("network/world_host")).toString();
		bool portIsValid = false;
		const auto portValue = settings.value(QStringLiteral("network/world_port")).toUInt(&portIsValid);

		QHostAddress address;
		if (!portIsValid || portValue == 0 || portValue > 65535 || !address.setAddress(host) || !address.isLoopback()) {
			logger.error("connectPassively", "Configuration must specify a loopback world endpoint");
			return exitValue(DiagnosticExitCode::IncorrectUsage);
		}

		ConnectionOptions options;
		options.host = host;
		options.port = static_cast<quint16>(portValue);
		options.connectionTimeout = std::chrono::milliseconds {
			settings.value(QStringLiteral("diagnostics/connection_timeout_ms"), 5000).toInt()
		};
		options.inactivityTimeout = std::chrono::milliseconds {
			settings.value(QStringLiteral("diagnostics/inactivity_timeout_ms"), 30000).toInt()
		};

		TcpTransport transport;
		bool connectionEstablished = false;
		bool terminalResultSelected = false;

		QObject::connect(&transport, &TcpTransport::connected, &application, [&] {
			connectionEstablished = true;
			logger.info("connectPassively", "Loopback connection established; closing without sending data");
			transport.close();
		});
		QObject::connect(&transport, &TcpTransport::failureOccurred, &application, [&](const TransportFailure &failure) {
			if (terminalResultSelected) {
				return;
			}

			terminalResultSelected = true;
			const auto timedOut = failure.error == TransportError::ConnectionTimeout || failure.error == TransportError::InactivityTimeout;
			logger.error("connectPassively", "Loopback connection failed; timeout={}", timedOut);
			application.exit(exitValue(timedOut ? DiagnosticExitCode::Timeout : DiagnosticExitCode::ConnectionFailure));
		});
		QObject::connect(&transport, &TcpTransport::disconnected, &application, [&] {
			if (terminalResultSelected) {
				return;
			}

			terminalResultSelected = true;
			logger.info("connectPassively", "Loopback connection closed; connected={}", connectionEstablished);
			application.exit(exitValue(connectionEstablished ? DiagnosticExitCode::Success : DiagnosticExitCode::ConnectionFailure));
		});

		logger.info("connectPassively", "Starting passive loopback connection");
		transport.connectToHost(options);
		return application.exec();
	}

	int run(QCoreApplication &application, Logger &logger) {
		QCommandLineParser parser;
		parser.setApplicationDescription(QStringLiteral("Headless transport and framing diagnostics"));
		parser.addHelpOption();
		parser.addOption({ QStringLiteral("config"), QStringLiteral("Local configuration file"), QStringLiteral("path"), QStringLiteral("client/config/local.ini") });
		parser.addOption({ QStringLiteral("fragment-size"), QStringLiteral("Fragment size for simulate-stream"), QStringLiteral("bytes"), QStringLiteral("3") });
		parser.addOption({ QStringLiteral("developer"), QStringLiteral("Enable developer logging") });
		parser.addPositionalArgument(QStringLiteral("command"), QStringLiteral("connect, inspect-fixture, or simulate-stream"));
		parser.addPositionalArgument(QStringLiteral("fixture"), QStringLiteral("Synthetic fixture path for offline commands"), QStringLiteral("[fixture]"));

		if (!parser.parse(application.arguments())) {
			logger.error("run", "Invalid command line: {}", parser.errorText().toStdString());
			return exitValue(DiagnosticExitCode::IncorrectUsage);
		}

		const auto arguments = parser.positionalArguments();
		if (arguments.isEmpty()) {
			logger.error("run", "A diagnostic command is required");
			return exitValue(DiagnosticExitCode::IncorrectUsage);
		}

		const auto &command = arguments.first();
		if (command == QStringLiteral("connect")) {
			if (arguments.size() != 1) {
				logger.error("run", "The connect command does not accept a fixture");
				return exitValue(DiagnosticExitCode::IncorrectUsage);
			}
			return connectPassively(application, parser.value(QStringLiteral("config")), logger);
		}

		if (arguments.size() != 2) {
			logger.error("run", "The offline command requires exactly one fixture");
			return exitValue(DiagnosticExitCode::IncorrectUsage);
		}

		if (command == QStringLiteral("inspect-fixture")) {
			return inspectFixtureFile(arguments.at(1), 0, false, logger);
		}

		if (command == QStringLiteral("simulate-stream")) {
			bool fragmentSizeIsValid = false;
			const auto fragmentSize = parser.value(QStringLiteral("fragment-size")).toULongLong(&fragmentSizeIsValid);
			if (!fragmentSizeIsValid || fragmentSize == 0) {
				logger.error("run", "Fragment size must be a positive integer");
				return exitValue(DiagnosticExitCode::IncorrectUsage);
			}
			return inspectFixtureFile(arguments.at(1), static_cast<std::size_t>(fragmentSize), true, logger);
		}

		logger.error("run", "Unknown diagnostic command");
		return exitValue(DiagnosticExitCode::IncorrectUsage);
	}

}

int main(int argc, char* argv[]) {
	QCoreApplication application(argc, argv);
	application.setApplicationName(QStringLiteral("diagnostics"));

	try {
		const auto arguments = application.arguments();
		Logger logger({
			.loggerName = "diagnostics",
			.filePath = std::filesystem::path("debug.log"),
			.developerMode = arguments.contains(QStringLiteral("--developer")),
		});
		return run(application, logger);
	} catch (...) {
		return exitValue(DiagnosticExitCode::IncorrectUsage);
	}
}
