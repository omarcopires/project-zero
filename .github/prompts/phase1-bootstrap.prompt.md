---
description: "Historical phase 1 bootstrap task: create client/, target-based CMake, a vcpkg manifest, and Windows presets. Write files only; never configure or build."
agent: "agent"
argument-hint: "Optional scope or target-name changes"
---

# Phase 1 — project bootstrap (historical prompt)

Create the initial structure described in the [phase 1 plan](../../docs/phase1-bootstrap-transport.md). This phase is already recorded as completed; inspect the current repository before applying any part of this prompt. File writing alone does not authorize CMake, Ninja, MSBuild, vcpkg compilation, CTest, or tests.

Confirm the phase 0 choices first: C++20, Qt 6 from vcpkg, MSVC, fixed baseline, and `x64-windows`. Read the [general instructions](../copilot-instructions.md) and [C++ rules](../instructions/cpp.instructions.md). Keep CMake modules in `cmake/`, a root `vcpkg.json` and `CMakePresets.json`, code in `client/src/`, tests in `client/tests/`, and local settings in `client/config/`. Use descriptive target names, explicit dependencies, Clean Architecture, spdlog behind infrastructure, and one header per new enum. Do not touch protected frontend resources or `.clang-format`.

Report files changed, target purposes, unresolved decisions, and executable validation pending for the owner/CI. Do not commit without authorization.
