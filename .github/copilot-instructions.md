# Instructions for AI agents — client engine

## Mandatory rules

- Communicate with the owner in Portuguese. Write new code, identifiers, comments, internal messages, and project documentation in English. Keep project documentation in `docs/`.
- Do not assign a fixed brand or proper name to the project. Use responsibility-based names for directories, files, namespaces, CMake targets, manifests, and executables. Preserve historical paths and external contracts; do not rename the workspace root.
- **Never modify the original game frontend.** Preserve the existing `things/data/`, `things/images/`, `things/qt/`, `things/qt-project.org/`, `things/qtwebchannel/`, `things/spells/`, and `things/message.txt` byte for byte. Do not edit, format, normalize line endings, rename, move, delete, convert, replace, or generate files in those paths.
- Do not evade that rule with modified copies, build patches, runtime replacements, or same-named components that change frontend behavior. Do not convert QML to OTUI. Fix incompatibilities in the new engine, Qt adapters, models, registered types, providers, and external resource mappings. If the contract cannot be preserved, stop the affected implementation and record the blocker.
- **Agents must never configure, generate, compile, link, rebuild, or clean a build.** Do not run CMake, presets, Ninja, MSBuild, Make, or equivalent wrappers for those operations. Do not run a vcpkg installation that may compile dependencies.
- Do not run CTest, compiled tests, the client, the server, or scripts that start builds. Build and executable validation belong to the owner or preconfigured CI. Do not trigger pipelines or delegate prohibited work.
- Write permission does not authorize builds. Writing tests and configuration within a requested scope is allowed; running them is not. Allowed validation includes reading, diff inspection, hashes, editor diagnostics, and static checks that neither generate/build nor execute project code.
- Preserve user changes and `.clang-format`. Do not clean, install, commit, push, or publish without a specific request. Do not read or expose secrets or dumps for convenience.

## Engineering

- The new core uses C++20, Qt 6, CMake, and vcpkg, initially on Windows. Support is **limited to development server version 15.25**; do not add automatic compatibility with earlier or future versions. OTClient is a reference, not the adopted engine.
- Before editing, identify responsibility, contracts, ownership, and dependency direction. New backend code follows Clean Architecture: domain and use cases do not depend on infrastructure, transport, persistence, concrete logging, or presentation. Adapters depend on internal contracts. Compose and inject dependencies at the application boundary.
- Apply Clean Code: single responsibility, descriptive names, cohesive functions, explicit invariants, low coupling, and deterministic tests. Avoid unused abstractions, generic utility classes, and pass-through layers.
- Use **spdlog** for regular logging, encapsulated in infrastructure and configured at composition. Follow the [verified reference format](../docs/coding-standards.md): millisecond timestamp, descriptive logger, level, and `[FunctionName] - Message`. Use `{}` interpolation, never `%d` or `%s` for arguments; spdlog pattern tokens still use `%`. Do not expose spdlog to domain/use cases or create a global logger.
- Each new enum must be an `enum class` in its own header, named for the type and located in the owning module. Keep Qt/QML metadata exceptions isolated and documented without changing the original frontend.
- New adapters must implement the APIs required by the frontend, including legacy names. Modernization does not authorize removing those contracts.
- Follow `.clang-format`, [C++ instructions](instructions/cpp.instructions.md), and [coding standards](../docs/coding-standards.md). Do not format the whole tree or protected content.
- Use deterministic rules, regression tests, explicit errors, sound lifetimes, and thread safety. Do not invent compatibility, performance, or test evidence.
- At completion, report changed files, checks actually performed, limitations, and pending manual validation. Static review is not a build or test run.
- Commit only when specifically requested or after the owner confirms a feature. Use English Conventional Commits, a title of at most 72 characters (prefer at most 50), and a detailed body with lines at most 72 characters. See the [commit policy](instructions/commits.instructions.md).

## References

- [Project plan and milestones](../docs/project-plan-2026-09-17.md)
- [Validation policy](../docs/validation-policy.md)
- [Resource and native contract audit](../docs/backend-resource-audit.md)
- [Origin of these rules](../docs/rules-migration.md)

These are behavioral instructions, not a technical write lock. Do not claim they guarantee cryptographic immutability or tool restrictions.
