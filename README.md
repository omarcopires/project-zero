# Client engine

An in-progress C++20 and Qt 6 desktop client for a **15.25 development server**. The project builds a new engine around an existing QML frontend. Its current goal is to connect authentication, world entry, asset loading, and basic map presentation while keeping the original frontend resources intact. Status below reflects source inspection on October 7, 2026.

## Current status

The repository contains a Windows CMake/vcpkg build, protocol and asset libraries, a headless diagnostics program, a Qt Quick client host, and automated tests. The implementation includes HTTP login, character selection, the 15.25 world handshake, initial world response and map description decoding, and a first static map renderer. The original login and character selection screens are connected to the new services.

**This is not a complete playable client.** The map currently draws limited static appearances. Neighboring floors, animation, lighting, movement, chat, inventory, most panels, and audio playback are incomplete or unavailable. Two-factor challenges stop with an explicit unsupported state. Asset ID compatibility with a particular server installation still needs confirmation. Historical phase reports in `docs/` describe earlier milestones and are not current test results.

The latest integration note reports that compilation, the 158 tests, and an end-to-end server flow were still pending external validation for those changes. This README is based on source and documentation inspection; no build or executable test was run while preparing it.

## Repository layout

| Path | Purpose |
| --- | --- |
| `client/src/` | Engine, protocol, transport, assets, session, Qt presentation, and diagnostics code |
| `client/tests/` | Unit and Qt integration tests |
| `client/protobuf/` | Appearance data schemas |
| `client/translations/en.json` | Extracted English translation catalog |
| `client/config/local.example.ini` | Local configuration template |
| `cmake/`, `CMakeLists.txt`, `CMakePresets.json`, `vcpkg.json` | Windows build and dependency definitions |
| `things/` | Original frontend and resource trees; treat them as read-only |
| `docs/` | Architecture, protocol contracts, validation policy, history, and known limitations |
| `.github/` | AI instructions and historical phase prompts |

## Requirements and build

The checked-in preset targets **Windows x64**, CMake **3.30+**, Ninja, MSVC (`cl`), C++20, and vcpkg manifest mode. Set `VCPKG_ROOT` to a vcpkg checkout before configuring. Dependencies are declared in [`vcpkg.json`](vcpkg.json), including Qt 6, protobuf, OpenSSL, spdlog, fmt, zlib, liblzma, and GoogleTest. The preset uses the `x64-windows` triplet. A working server and matching assets are needed for a meaningful login and world session.

```powershell
cmake --preset windows-x64
cmake --build --preset windows-x64
ctest --preset windows-x64
```

These are instructions for maintainers; they have not been executed for this documentation update. CMake's intermediate build directory is `out/build/windows-x64`. The `client_app` target places its runtime executable at the repository root. After a successful build, run `client_app.exe` from that root so the example relative asset path can resolve, with `client.ini` beside the executable or `CLIENT_CONFIG_FILE` set.

## Local configuration

Copy `client/config/local.example.ini` to `client.ini` next to the built client, or point `CLIENT_CONFIG_FILE` to another file. The example uses a loopback HTTP login service and world port 7172. Set `network/login_service_url` for the target login service. Set **both** `network/world_host` and `network/world_port` to override the world endpoint returned by login, or leave both empty to use that response. Set `assets/directory` to the catalog and sprite directory; `CLIENT_ASSETS_DIRECTORY` takes precedence. `network/asset_hash_identifier` is optional and is never guessed by the client. Do not commit credentials or personal configuration.

The appearance catalog requires `catalog-content.json`, appearance metadata, and referenced CIP sprite sheets. The checked-in `things/assets` directory is the example default. See [login integration](docs/game-login-integration.md), [appearance provider](docs/appearance-image-provider.md), and [asset verification](docs/phase0-assets-verification.md).

## Architecture and boundaries

The project separates deterministic protocol and application rules from network, logging, and Qt presentation adapters. TCP and HTTP transport, modern framing, authentication, world handshake, map decoding, asset loading, and QML compatibility are distinct modules. The Qt host supplies the models and named APIs expected by the original QML. New code must preserve the original resource trees under `things/`; see the [coding standards](docs/coding-standards.md) and [AI instructions](.github/copilot-instructions.md).

## Documentation

- [Current UI and map rendering limitations](docs/world-map-rendering.md)
- [Authentication and world-entry integration](docs/game-login-integration.md)
- [15.25 world handshake contract](docs/phase2-world-handshake-contract.md)
- [Validation policy](docs/validation-policy.md)
- [Project plan and historical milestones](docs/project-plan-2026-09-17.md)
- [Translation catalog](docs/translation-catalog.md)

Historical phase reports were condensed into English while retaining their principal contracts, decisions, evidence, and limitations. The pre-translation text remains available in Git history for deeper audit detail.

The repository has no license file at the time of this update. Public visibility alone does not grant reuse rights; add a license before inviting redistribution or external contributions.
