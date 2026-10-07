---
description: "Use when creating or reviewing C++ backend code: Clean Architecture, descriptive names, separate enums, spdlog, ownership, Qt contracts, and tests. Does not authorize builds or edits to the original frontend."
applyTo: "**/*.cpp,**/*.h,**/*.hpp,**/*.cc,**/*.cxx"
---

# C++ standards for the new engine

- Use the root `.clang-format` as the formatting authority. Its commented `BasedOnStyle` does not imply WebKit. `Standard: Latest` does not set the compiler's C++ standard.
- Use `PascalCase` for types and enumerators, `lowerCamelCase` for functions, methods, parameters, and variables, `m_` for new private class members, and `lowerCamelCase` for public data-structure fields. Required Qt and frontend API names are exceptions.
- Write new code and comments in English. Comments explain non-obvious invariants and constraints; architecture and history belong in `docs/` and tests.
- Use descriptive responsibility-based names, not brands or repository-derived prefixes. Preserve historical paths and external contracts.
- Keep domain independent of infrastructure. Use cases depend on domain and internal ports; adapters implement ports; composition selects concrete implementations. Avoid cycles, service locators, and socket/QML/spdlog/persistence dependencies in internal modules.
- Favor cohesive functions, explicit names, value semantics, and actual consumers for interfaces. Avoid ambiguous booleans, sentinel parameters, generic utility classes, duplicated rules, and layers that merely forward calls.
- Put each new `enum class` in its own header in its owning module. Use an explicit underlying type for binary contracts and validate external values before conversion. Isolate required Qt metadata exceptions in adapters.
- Name new C++ files in `lower_snake_case` with `.h`/`.cpp`. Make headers self-contained with minimal includes and no public `using namespace` directives. Do not rename protected files or APIs to fit the convention.
- Keep deterministic rules separate from transport, files, and rendering. Do not adopt OTClient engine globals such as `g_logger`, `g_ui`, or `g_modules`.
- Use RAII and explicit ownership. Do not combine QObject parent ownership with owning smart pointers without a documented lifetime model. Define the validity of non-owning references.
- Respect QObject thread affinity and Qt Quick rules. Transport must not modify QML objects directly from another thread; synchronize state used by rendering.
- Represent failures explicitly. Never turn network/decoding errors into success or retain invalid references after disconnect.
- Use spdlog only behind infrastructure adapters. Inject a minimal logging port only where a use case needs it; pure rules return results/errors. Do not use a global logger or scattered `printf`, `std::cout`, or `qDebug` as substitutes.
- Configure sinks, levels, and shutdown in composition. Initial profile: synchronous colored console and a plain file truncated on startup, without rotation or async queue. The required pattern is `[%Y-%m-%d %H:%M:%S.%e] [%n] [%^%l%$] %v`; payload is `[FunctionName] - Message`, captured at the call site and normalized as described in [coding standards](../../docs/coding-standards.md). Use typed `{}` formatting. Never use external text as a format string or log credentials, tokens, payloads, or sensitive data.
- Preserve exactly the names, roles, properties, methods, and signals consumed by the original QML. Adapt in new code; do not rename consumers.
- Write isolated rule and regression tests where warranted. Benchmarks do not replace correctness tests. Do not run builds, CTest, or compiled tests.
- Limit any future formatting to new or changed C++ files in scope. If a suitable formatter is unavailable, report it rather than changing `.clang-format`.

See [coding standards](../../docs/coding-standards.md) and [validation policy](../../docs/validation-policy.md).
