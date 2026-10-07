---
description: "Historical phase 1 test-writing task; writing tests is allowed, running builds and tests is prohibited."
agent: "agent"
argument-hint: "Optional component: framing, transport, or core"
---

# Phase 1 — automated tests (historical prompt)

Inspect existing suites, then write tests under `client/tests/` according to the [phase 1 plan](../../docs/phase1-bootstrap-transport.md) and [validation policy](../../docs/validation-policy.md). Cover pure framing with valid, partial, concatenated, truncated, invalid, and boundary inputs; cover Qt transport connection/disconnection/error signals, lifetime, cancellation, and timeouts using local test sockets or mocks. Add a regression case for each fixed defect.

Use GoogleTest for core and Qt Test for Qt objects where the current build supports them. Name tests by behavior and use deterministic synthetic fixtures without real servers, external networks, secrets, or unknown dumps. Register suites in CTest. Preserve the original frontend. Do not run CMake, CTest, compiled tests, client, server, or pipelines. Report suites and scenarios, dependency changes, and that tests were written but not executed. Do not commit without authorization.
