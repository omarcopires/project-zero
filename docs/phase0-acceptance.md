# Phase 0 — documentation closeout with qualifications

**Historical record, September 17, 2026.** The owner requested closure of the documentation phase after confirming the laboratory setup. This was **not** technical acceptance of the toolchain, assets, or new client. Later phases and current implementation are described in the [README](../README.md).

The owner reported that the maintained reference client compiled and could select a character, log in, and play on the 15.25 development server. Authentication used email/password through `http://127.0.0.1:8080/api/v1/webservice`; the world endpoint was `localhost:7172`. TCP login port 7171 was also mentioned and must not be confused with the HTTP API. These were owner reports, not agent-executed checks or cryptographic proof about the binaries.

At closeout, `assets/` held 6,248 files (129,713,352 bytes), including 6,241 `.lzma` files. All 5,090 catalog entries referenced existing files, with 11 gaps in the sprite ID ranges. The local appearance file differed in size and hash from the server copy; semantic ID correspondence remained unproven. See [asset verification](phase0-assets-verification.md).

The documented toolchain selection was C++20, Qt 6.11.1 through vcpkg, MSVC 14.51.36231, CMake 4.3.1-msvc1, Ninja, and dynamic `x64-windows`. Selection did not establish compatibility or reproducibility. The initial QML inventory covered login, character selection, and some transitive dependencies, not the whole frontend. Two-factor challenges had to stop explicitly until supported.

Technical gates carried into later increments: owner/CI build and ABI validation; exact 15.25 wire contracts before implementation; semantic asset/server ID comparison; translations, fonts, sounds, Qt plugins, aliases, and controller contracts before visual integration; and a compatible solution for the affected chat path. Closing this phase did not waive any gate or authorize agents to build.

The original review used read-only QML and catalog inspection, hashes, and local toolchain inventory. It did not decompress resources, load QML, connect to the server, build, run tests, commit, or push. Protected frontend paths and `.clang-format` had an empty tracked diff at that review point.
