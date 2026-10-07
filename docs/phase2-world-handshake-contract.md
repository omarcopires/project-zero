# Phase 2 — 15.25 world handshake and initial map contract

**Historical implementation record, September 23–28, 2026.** Reference client revision `d4ae7cf2dc058d82bc375faf44c6eecc3dd9fa84`; server revision `f42413eff8d59b04087b52d1b793a4c685de5a82`. The implementation has advanced since the first increments described here; the [README](../README.md) describes current scope.

## Challenge and login

The server sends a 12-byte unencrypted modern-frame body before login: four-byte little-endian Adler-32 over the following eight bytes, marker `0x01`, opcode `0x1F`, little-endian 32-bit timestamp, random byte, and trailer `0x71`. The decoder requires exact length and validates checksum, marker, opcode, and trailer.

The subsequent login uses protocol ID `0x000A`, OS field, version `1525` in the required numeric fields and derived text, optional asset identifier, and preview state. The 128-byte RSA plaintext block begins with zero, then four little-endian XTEA key words, disabled GM flag, length-prefixed session key and character, challenge timestamp/random byte, empty optional extension, and zero padding. Raw RSA uses the OpenTibia 1024-bit public modulus and exponent 65537 through OpenSSL, without private key or padding. Wrong block size, invalid key, or message outside the modulus fail. The login packet includes Adler-32 and a final zero pad for modern alignment; an unset asset identifier is encoded as an empty string rather than an invented hash.

## Encrypted session

XTEA processes independent eight-byte blocks with four 32-bit key words and 32 rounds. The outgoing session adds sequence `1..0x7FFFFFFF`, a leading padding-size byte, trailing padding, and XTEA encryption; the sequence stays outside the encrypted region. Incoming frames require the expected sequence, decrypt only the XTEA region, and validate/remove padding. The high sequence bit signals compression. Compressed payloads are independent raw DEFLATE streams with a 65,500-byte output cap; empty, truncated, trailing, or over-limit streams fail explicitly.

`WorldSessionService` connects with bounded TCP transport, accumulates fragmented frames, checks the challenge, sends login, and accepts encrypted frames starting at sequence 1. It publishes decrypted payload only after the first valid response. Key and session material are supplied, never logged. Error categories distinguish transport, framing, challenge, encoding, send, and session failures.

## Initial responses and map

The initial decoder recognizes pending login (`0x0A`), world entry (`0x0F`), update required (`0x11`), error (`0x14`), warning (`0x15`), queue (`0x16`), login success (`0x17`), logout (`0x18`), bug-report configuration (`0x1A`), character stats (`0xA0`), Exiva restrictions (`0xCA`), resource balance (`0xEE`), and time (`0xEF`). It consumes known auxiliary messages before world entry, retaining raw payload as needed. Queue can remain `Waiting` after TCP closure and allow a later attempt. The Canary 15.25 server may put resource/stats/other updates before `0x17`, even in the same encrypted frame; the service locates a complete success packet without treating earlier bytes as authentication errors. Map opcode `0x64` yields center x/y/floor and leaves tile data for the map decoder.

Tile-list terminators are little-endian words starting at `0xFF00`; the low byte is a run of empty positions, so `0xFFFF` means 255. The initial map codec traverses an 18×14 grid in profile floor order, consumes objects/creatures using appearance catalog IDs and flags, retains basic IDs/attributes, and returns consumed length so following payload remains available. Unsupported extensions fail explicitly. The catalog indexes object, outfit, effect, and missile groups from protobuf metadata. Asset/server ID correspondence remains a separate validation gate.

Historical owner reports increased through 82, 86, 93, 98, 103, 107, 115, 119, 124, 132, and 136 passing tests as each increment was added. Those reports apply only to their revisions and synthetic/local fixtures; they do not by themselves prove complete real-world entry or current build health.
