# Phase 1 — core bootstrap and transport

**Historical plan and implementation record.** Phase 1 established the C++20/Qt 6 CMake/vcpkg project, target-based modules, a headless `diagnostics` CLI, asynchronous TCP and HTTP transport, 15.25 outer framing, structured logging, and deterministic tests. The [acceptance record](phase1-acceptance.md) reports owner validation in the existing environment, with clean-machine reproducibility outstanding.

## Architecture

Domain and use cases own typed results and internal ports without Qt/QML, sockets, or spdlog. Transport implements the ports and owns connections, buffers, and timers without interpreting game messages. Framing is pure buffer processing: incomplete input waits, EOF with remaining bytes is truncation, and invalid or oversized frames fail explicitly. Composition creates adapters and handles shutdown. Logging uses an injected infrastructure spdlog adapter with the pattern and payload specified in [coding standards](coding-standards.md); it excludes credentials, tokens, and packet contents.

The original scope was deliberately headless. It excluded authentication messages, world state, resources, rendering, and modifications to the original frontend. The root build files are `CMakeLists.txt`, `CMakePresets.json`, and `vcpkg.json`; supporting modules are in `cmake/`, source and tests in `client/`, and local configuration stays outside Git.

## Transport and diagnostics contracts

TCP I/O is asynchronous with bounded incremental buffers, configurable connection/inactivity timeouts, cooperative cancellation, explicit ownership, clean close, and typed failures. State transitions and a single terminal event per attempt matter; late callbacks must not revive canceled attempts. Qt transport does not access QML directly across threads. HTTP limits response size and duration, rejects unauthorized redirects, supports cancellation, and confines plain HTTP to loopback. HTTPS must validate certificates.

The diagnostic CLI supports passive loopback `connect` without payload, offline `inspect-fixture`, and in-memory `simulate-stream`. It must not become an arbitrary packet sender, scanner, or real-payload dump. Exit codes distinguish success, connection/timeout/framing failure, and misuse. Fixtures are synthetic.

## Recorded validation and limits

The owner reported successive passing suites as phase work accumulated: 2, 9, 17, 28, 35, then 43 tests on September 22, 2026. A separate passive `diagnostics.exe connect` run reported connection and clean close at the configured loopback endpoint without a payload. Each count applied to that revision only; it is not a current suite result. The 43-test result covered the later HTTP harness. No clean-machine or CI reproduction was reported in the phase acceptance.

Connection alone does not establish protocol compatibility, and synthetic HTTP tests do not establish real authentication. Agents may write tests and inspect diffs but may not configure, build, run CTest, execute diagnostics, or trigger CI; see [validation policy](validation-policy.md). The current project has moved past this phase; consult the [README](../README.md) for current implementation and limitations.
