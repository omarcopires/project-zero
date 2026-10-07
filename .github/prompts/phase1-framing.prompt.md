---
description: "Historical phase 1 framing task: deterministic 15.25 buffer operations, typed errors, and tests; no build or execution."
agent: "agent"
argument-hint: "Optional focus: reading, writing, limits, or errors"
---

# Phase 1 — 15.25 framing (historical prompt)

Implement the documented [15.25 framing contract](../../docs/phase1-framing-contract.md) only after inspecting the current implementation. Do not guess undocumented wire details or probe the server to discover them. Use pure buffer/span operations with incremental reads: incomplete frames wait for more input, oversized frames fail with typed errors, and invalid data returns useful context without sensitive contents. Preserve byte order, lengths, and limits on writes; avoid unnecessary allocations.

Write, but do not run, deterministic tests for one valid frame, fragmented reads, concatenated frames, truncated input, invalid lengths/fields, and the exact size limit plus one. State bytes consumed, events, and errors in expectations. Follow [general](../copilot-instructions.md) and [C++](../instructions/cpp.instructions.md) rules. Report API, changed files, contract uncertainties, test coverage, and pending owner/CI validation. Do not commit without authorization.
