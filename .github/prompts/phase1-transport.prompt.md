---
description: "Historical phase 1 asynchronous TCP transport task; no build or execution."
agent: "agent"
argument-hint: "Optional focus: connection, buffers, timeouts, or shutdown"
---

# Phase 1 — asynchronous TCP transport (historical prompt)

Inspect the existing transport first, then implement any remaining scope from the [phase 1 plan](../../docs/phase1-bootstrap-transport.md). Provide asynchronous connection, incremental read buffers, configurable connection/read timeouts, cooperative cancellation, clean close notifications, and typed network/timeout/remote-close/cancellation errors. Preserve boundaries across partial reads. Define ownership and lifetime clearly and respect QObject thread affinity; transport must not touch QML objects directly.

Transport implements internal ports; pure framing does not depend on sockets. Do not interpret game messages here. Compose injected infrastructure logging without concrete logger types in the core or sensitive packet logging. Use responsibility-based names and separate enum headers. Follow [C++ rules](../instructions/cpp.instructions.md), preserve original frontend resources, and write but do not execute tests. Report files, lifecycle decisions, written coverage, and pending build/validation. Do not commit without authorization.
