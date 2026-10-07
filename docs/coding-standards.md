# Coding standards for the new engine

These rules apply to new C++20/Qt 6 code and configuration. They do not authorize editing, translating, modernizing, or formatting the original frontend. Preserve legacy names consumed by QML, including unusual spellings such as `liquideType` where required. The [AI instructions](../.github/copilot-instructions.md) and [validation policy](validation-policy.md) are operational companions.

## Formatting and naming

The root [`.clang-format`](../.clang-format) is authoritative. Its inspected settings include four-space indentation/tab width, `UseTab: AlignWithSpaces`, no column limit, namespace indentation, left pointer/right reference alignment, no include sorting, preserved include blocks, inserted braces/newline, and LF output. `BasedOnStyle` is commented out; do not assume WebKit. `Standard: Latest` affects formatting, not the compiler C++ standard. Do not format the entire tree or protected files.

Use `PascalCase` for types and enum values, `lowerCamelCase` for functions, methods, variables, parameters, and public data fields, and `m_` for new private members. New C++ filenames use `lower_snake_case` and `.h`/`.cpp`; headers are self-contained with minimal includes and no public `using namespace`. New code, comments, and internal messages are in English. Comments explain non-obvious reasons or invariants. Directories, namespaces, targets, executables, and manifest names describe responsibilities without a fixed brand or reference-repository prefix. Preserve external Qt/QML API spellings.

Each new `enum class` has its own header in the owning module. Use explicit underlying types for binary contracts, validate external values, and handle unknown values. Do not serialize native enum layout. Keep required Qt `Q_ENUM`/wrapper exceptions in presentation adapters and document their mapping, leaving domain enums independent.

## Architecture and lifecycle

Domain uses value types and the standard library, not Qt/QML, sockets, persistence, presentation, or spdlog. Use cases depend on domain and internal ports with real consumers. Infrastructure adapters implement ports. Composition chooses concrete implementations and owns their lifecycle. CMake targets should express the same dependency direction. Avoid cycles, global service locators, unused interfaces/factories, and pass-through layers. Keep pure framing and other deterministic rules testable without network or QML.

Use cohesive functions, explicit invariants, typed errors, RAII, and clear ownership. Do not combine QObject parent ownership with another owning pointer without a documented model. Define the validity of non-owning references, cancellation behavior, and shutdown order. Respect QObject thread affinity; transport must deliver events through appropriate signals/queues rather than mutating QML on another thread. Do not convert failures into apparent success or claim performance without controlled measurements. Preserve regression tests; benchmarks never replace correctness checks.

## Logging: spdlog

Use spdlog only behind infrastructure. Compose/inject the concrete logger at the application boundary; do not expose spdlog types to domain/use cases or use a global/default logger. Pure rules return results/errors. A logging port exists only if an internal consumer needs it. Regular logging does not use scattered `printf`, `std::cout`, or `qDebug`. Never log credentials, tokens, session keys, sensitive headers/URLs, or packet bodies. Handle sink failures and shutdown explicitly, and avoid recursion when forwarding Qt messages.

The required pattern is exactly `[%Y-%m-%d %H:%M:%S.%e] [%n] [%^%l%$] %v`: local timestamp with milliseconds, descriptive logger, level, and payload. The adapter composes payload as `[FunctionName] - Message`, capturing the function at the **call site**. Normalize only the message's first ASCII letter to uppercase, preserving the rest. Arguments use typed spdlog/fmt `{}` placeholders, never `%d`/`%s`; `%` in the pattern is spdlog syntax. Escape literal braces as `{{`/`}}`; never use external text as a format string.

The initial profile is synchronous, thread-safe colored console plus plain `debug.log` truncated at startup, flush from trace, info by default and debug with `--developer`. Keep the file outside Git. Rotation/retention and asynchronous queues require separate decisions. The reference format was inspected read-only on September 17, 2026 in the owner's reference client's logger and Lua adapter; it was source evidence, not a run of the new engine.

## Build, tests, and commits

Use target-specific CMake settings, vcpkg manifest with fixed baseline/triplet, and one Qt dependency source. Avoid personal paths and secrets in presets. Separate pure unit, Qt integration, controlled server, end-to-end, and performance checks. Agents may write requested tests/configuration but must not configure, build, install compiling dependencies, run tests/client/server, or trigger pipelines. Commits require owner request or feature approval and follow [English Conventional Commits](../.github/instructions/commits.instructions.md), with a title at most 72 characters and a wrapped explanatory body. Report actual static checks and pending executable validation.
