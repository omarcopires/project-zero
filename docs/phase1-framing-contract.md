# Phase 1 — 15.25 outer-frame contract

**Static reference inspection, September 22, 2026.** Reference client revision `d4ae7cf2dc058d82bc375faf44c6eecc3dd9fa84`; server revision `abd950f2b6999b4790b09178bfb5f8a4b1272740`. No network capture or execution established this record.

The server's `CurrentModern` profile prefixes each frame with an unsigned 16-bit little-endian block count. The body size is **`blockCount * 8 + 4` bytes**, not the raw field value. The four extra bytes belong to the body and are used by the modern sequence/checksum layer. Outer framing handles `[blockCount:u16 LE][body]` and does not interpret sequence, compression, padding, or XTEA.

Directional limits differ. Server-to-client messages are capped at 65,500 body bytes (`blockCount = 8187`). Client-to-server input is capped at 4,096 bytes by the server, so the largest representable body in that direction is 4,092 bytes (`blockCount = 511`). Promote the field to `size_t` before multiplication and reject over-limit input before copying or allocating.

Fewer than two bytes require more header data. A complete header with partial body reports required length without consuming input. Empty EOF closes cleanly; EOF with partial header/body is truncated. A complete frame returns a zero-copy body view and consumed length, allowing concatenated frames. Encoding accepts only bodies at least four bytes, with `(bodySize - 4) % 8 == 0`, within the server input limit. Sequence, compression, XTEA, and the initial-login transition belong to later protocol layers.
