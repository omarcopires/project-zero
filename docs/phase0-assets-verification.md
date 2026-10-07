# Phase 0 — static asset verification

**Historical inspection, September 17, 2026; updated September 24.** This was a read-only inventory, not decoding, 15.25 compatibility, or graphical validation.

PowerShell enumeration, JSON parsing, path confinement checks, existence tests, numeric range sorting, and SHA-256 hashes produced these results:

| Check | Recorded result |
| --- | --- |
| Files under `assets/` | 6,248; 129,713,352 bytes |
| Extensions | 6,241 `.lzma`, four `.dat`, two `.json`, one `.jpg` |
| Catalog | 5,090 entries: 5,084 sprites and one each of appearances, static data, static map data, full map, map, and proficiencies |
| Paths | No empty, absolute, escaping, or out-of-root path in the examined set |
| References | Every catalog entry referenced an existing file; no duplicate referenced filename |
| Files outside catalog | 1,157 excluding the catalog: 207 minimap, 741 satellite, 209 subarea |
| Sprite ranges | First ID 0, last 301200; no negative/inverted or overlapping ranges; 11 global gaps |

Catalog SHA-256: `6156366d9489d20bf2ec330f2365f3b328e36cbd57cdcdeba01706259e83765b`. The gaps were `2664–3346`, `142046–193959`, `195091–195195`, `195293–195321`, `195381–195386`, `196615–197224`, `197715–197845`, `197903–197908`, `242711–264776`, `268767–269815`, and `273832–274739`. Gaps do not prove missing files; unreferenced files are not automatically disposable.

SHA-256 matched filename suffixes for six auxiliary files but not for the 6,241 compressed `.lzma` files. Hashes were of stored bytes. The suffix may describe decompressed data or another representation, so mismatch does not prove corruption. The local appearance file was 5,017,898 bytes with SHA-256 `063e8d11a76a6f95bd986812808b52db4158a05601e7ea5cf0cb688fa9e36d57`; the inspected server file was 4,862,287 bytes with SHA-256 `aa44a154f30c7ed59acc25f246286396e4043851ef0b54ef3cf3951e46d1ce50`. They are different files, but no semantic comparison was performed.

By September 24, resources lived under `things/assets/`. The project had protobuf schemas in `client/protobuf/`, generated C++ classes, a bounded/path-confined appearance loader, and category indexes. The owner reported 132/132 tests after the loader work. A dedicated real-file read and semantic comparison to server IDs were still absent in that record.

The original search found no `.qm`, `.ts`, `.ttf`, `.otf`, or `.ogg` in the then-inspected workspace, only `images/empty.wav` among searched sounds. Verdana files existed on the inspected Windows machine, which did not establish font metrics or redistribution rights. A translation catalog was added later; see [translation catalog](translation-catalog.md). No asset decompression, build, test execution, HTTP request, TCP connection, or push occurred in this inspection.
