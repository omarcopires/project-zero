# Validation policy

Automated tests are part of the project, but their existence does not authorize agents to build or execute project code. This policy applies to subagents, terminals, wrappers, tasks, and pipelines triggered by an agent.

| Operation | Agent | Owner or preconfigured CI |
| --- | --- | --- |
| Read nonsensitive source and documentation | Allowed | Allowed |
| Write requested code, tests, and configuration outside protected originals | Allowed | Allowed |
| Inspect diffs, whitespace, hashes, and editor diagnostics | Allowed | Allowed |
| Perform static checks without generating/building or executing project code | Allowed | Allowed |
| Configure, generate, compile, link, rebuild, or clean | Prohibited | External responsibility |
| Install dependencies through vcpkg when compilation may occur | Prohibited | External responsibility |
| Run CTest, compiled tests, client, or server | Prohibited, even with existing binaries | Controlled environment |
| Trigger a pipeline to bypass these restrictions | Prohibited | Owner or established automation |
| Format or alter the original frontend | Prohibited | Outside this project |

Do not use CMake, presets, Ninja, MSBuild, Make, equivalent wrappers, or project scripts to bypass this policy. Generic requests to validate and the presence of build artifacts do not suspend it.

Static review should preserve user changes, inspect the relevant diff, verify documentation links and syntax, and use inventory/SHA-256 comparisons where useful. Hashes describe only the compared interval; they are not write protection. Never format `things/data/`, `things/images/`, `things/qt/`, `things/qt-project.org/`, `things/qtwebchannel/`, `things/spells/`, or `things/message.txt`. Preserve `.clang-format`. Source inspection alone cannot prove QML, protocol, ABI, or performance compatibility.

Tests should separate deterministic unit rules, Qt signals/models/lifecycles, controlled 15.25 server integration with disposable data, end-to-end visual checks, and reproducible performance measurements. Do not use an active development database for destructive integration tests. CTest orchestrates the configured suites; agents may write requested CI configuration but must not trigger it.

At task completion, list changed files, checks actually performed, uncertainties, and executable validation pending for the owner/CI. Do not invent test counts or claim a build from static review.
