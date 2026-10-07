# Client engine project plan

**Baseline plan dated September 17, 2026.** This plan records intended phases and historical decisions. Some phase-status text in earlier versions became stale as implementation progressed. For current source-backed capability and known limits, start with the [README](../README.md), [login integration](game-login-integration.md), and [map rendering](world-map-rendering.md).

## Fixed direction

Build a new Windows-first C++20/Qt 6 engine with CMake and vcpkg for the **15.25 development server only**. Keep original QML/images/other frontend trees byte-for-byte intact. Use responsibility-based names, Clean Architecture, Clean Code, explicit ownership, spdlog behind infrastructure, and separate headers for new enum classes. Do not transplant OTClient engine globals or convert QML to OTUI. Preserve exact QML API contracts through new adapters. Build/test execution belongs to the owner or established CI under the [validation policy](validation-policy.md).

The documented toolchain selection was Qt 6.11.1 through vcpkg, MSVC 14.51.36231, CMake 4.3.1-msvc1, Ninja, fixed vcpkg baseline `fa8cecf91d7f31a1715a7a6524f208897ffb33ce`, and dynamic `x64-windows`. The checked-in manifest/preset are the current build source of truth. Selection alone was never proof of clean-machine compatibility.

## Phases and gates

| Phase | Intended outcome | Historical/current position |
| --- | --- | --- |
| 0 — contracts/resources/toolchain | Record server profile, reference behavior, original QML APIs, assets, and environment | Documentation closed with qualifications; see [phase 0](phase0-acceptance.md) |
| 1 — bootstrap/transport | Target-based build, headless diagnostics, TCP/HTTP transport, outer framing, logging and tests | Owner accepted in the existing environment; clean-machine reproduction pending in that record; see [phase 1](phase1-acceptance.md) |
| 2 — authentication/session | HTTP login, character selection, world handshake, explicit failure states | Implemented in increments; historical contracts: [authentication](phase2-authentication-contract.md), [world handshake](phase2-world-handshake-contract.md) |
| 3 — initial world/assets | Typed initial map/world data and matching appearance resources | Initial response/map codecs and asset loaders exist; full server asset-ID correspondence and world behavior remain open |
| 4 — original frontend/map | Host original QML, controllers/models/providers, first map presentation | Login/selection and first static map are connected; many QML behaviors and visual layers remain incomplete |
| 5 — playable MVP | Movement, chat, inventory/containers, basic combat through original UI | Not complete; no claim of playable MVP |
| 6 — stabilization/package | Windows automation, clean-machine packaging, long sessions, reproducible performance | Future work |

Each increment follows server evidence → deterministic protocol/domain rule → Qt adapter → original frontend integration → tests and owner/CI validation. A TCP connection is not proof of protocol compatibility; choosing a character is not proof of world entry; a fallback image is not proof of asset correctness. Missing contracts block the affected feature and must not be hidden with simulated success or modified frontend copies.

## Architecture and acceptance

Transport owns asynchronous I/O, limits, cancellation, and framing. Protocol converts 15.25 bytes to typed events/commands. Session coordinates authentication and endpoint transitions. Domain models world state independently of QML. Resource modules load catalogs and sprites. Qt adapters expose the original component names, properties, roles, signals, methods, and image providers. Rendering composes state in Qt Quick with thread-safe handoff. Presentation remains the original QML.

External acceptance should cover reproducible configure/build/CTest, controlled server accounts and disposable data, error/cancel/disconnect paths, resource-ID matching, correct QML imports/URLs/fonts/translations, visual coordinates at multiple DPI scales, long-session cleanup, and measurements on named hardware/backend/scenes. Agents may inspect and write code but must not run these executable gates. No old/future server compatibility, official services, store/payment flows, advanced game systems, automatic updater, or multiplatform release is promised by the MVP plan.
