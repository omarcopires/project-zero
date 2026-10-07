---
description: "Historical phase 1 headless diagnostics task; never run the binary or build."
agent: "agent"
argument-hint: "Optional subcommand: connect, inspect-fixture, or simulate-stream"
---

# Phase 1 — headless diagnostics (historical prompt)

Implement `diagnostics` as described in the [phase 1 plan](../../docs/phase1-bootstrap-transport.md), after checking what already exists. The CLI has no QML. Its minimum commands are `connect` (loopback connection and clean disconnect without payload), `inspect-fixture` (offline synthetic fixture), and `simulate-stream` (in-memory fragmentation). Use distinct exit codes for success, connection failure, timeout, framing error, and invalid usage.

Compose an injected spdlog adapter with configured sinks and orderly shutdown. Log only states, counters, and errors. Never log credentials, tokens, or packet bodies. Do not add arbitrary hexadecimal sending, endpoint scanning, or real-payload capture. Read local configuration outside Git. Follow [C++ standards](../instructions/cpp.instructions.md), preserve the original frontend, and do not run builds, tests, diagnostics, client, or server. Report files, commands the owner could run, limitations, and pending validation. Do not commit without authorization.
