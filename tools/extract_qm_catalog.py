#!/usr/bin/env python3
"""Extract released Qt QM catalog entries to a readable JSON file."""

from __future__ import annotations

import argparse
import hashlib
import json
import struct
import sys
from pathlib import Path
from typing import Any


QM_MAGIC = bytes.fromhex("3cb86418caef9c95cd211cbf60a1bddd")

SECTION_HASHES = 0x42
SECTION_MESSAGES = 0x69
SECTION_LANGUAGE = 0xA7

TAG_END = 1
TAG_SOURCE_TEXT_16 = 2
TAG_TRANSLATION = 3
TAG_CONTEXT_16 = 4
TAG_OBSOLETE_1 = 5
TAG_SOURCE_TEXT = 6
TAG_CONTEXT = 7
TAG_COMMENT = 8


class QmFormatError(ValueError):
    """Raised when the input is not a complete, supported Qt QM catalog."""


def read_u32(data: bytes, offset: int, limit: int) -> tuple[int, int]:
    if offset + 4 > limit:
        raise QmFormatError("unexpected end of file while reading a 32-bit value")
    return struct.unpack_from(">I", data, offset)[0], offset + 4


def decode_qm_bytes(value: bytes) -> str:
    try:
        return value.decode("utf-8")
    except UnicodeDecodeError:
        return value.decode("latin-1")


def read_length_prefixed(data: bytes, offset: int, limit: int, encoding: str) -> tuple[str, int]:
    length, offset = read_u32(data, offset, limit)
    end = offset + length
    if end > limit:
        raise QmFormatError("message field extends beyond the QM message block")
    raw_value = data[offset:end]
    if encoding == "utf-16-be":
        if length % 2:
            raise QmFormatError("UTF-16 message field has an odd byte length")
        return raw_value.decode(encoding), end
    return decode_qm_bytes(raw_value), end


def parse_sections(data: bytes) -> dict[int, bytes]:
    if len(data) < len(QM_MAGIC) or data[: len(QM_MAGIC)] != QM_MAGIC:
        raise QmFormatError("missing Qt QM magic header")

    sections: dict[int, bytes] = {}
    offset = len(QM_MAGIC)
    while offset < len(data):
        if offset + 5 > len(data):
            if not any(data[offset:]):
                break
            raise QmFormatError("incomplete QM section header")

        section_tag = data[offset]
        section_size, body_offset = read_u32(data, offset + 1, len(data))
        if section_tag == 0 and section_size == 0:
            break
        end = body_offset + section_size
        if end > len(data):
            raise QmFormatError(f"QM section 0x{section_tag:02x} exceeds file size")
        if section_tag in sections:
            raise QmFormatError(f"duplicate QM section 0x{section_tag:02x}")
        sections[section_tag] = data[body_offset:end]
        offset = end

    if SECTION_HASHES not in sections or SECTION_MESSAGES not in sections:
        raise QmFormatError("QM catalog is missing its hash or message section")
    return sections


def parse_message(
    message_data: bytes,
    offset: int,
    inherited: dict[str, str],
) -> dict[str, Any]:
    if offset >= len(message_data):
        raise QmFormatError("QM message offset is outside the message block")

    fields = dict(inherited)
    translations: list[str] = []
    cursor = offset
    terminated = False

    while cursor < len(message_data):
        tag = message_data[cursor]
        cursor += 1

        if tag == TAG_END:
            terminated = True
            break
        if tag == TAG_OBSOLETE_1:
            _, cursor = read_u32(message_data, cursor, len(message_data))
            continue
        if tag == TAG_TRANSLATION:
            translation, cursor = read_length_prefixed(
                message_data, cursor, len(message_data), "utf-16-be"
            )
            translations.append(translation)
            continue
        if tag == TAG_SOURCE_TEXT_16:
            fields["source"], cursor = read_length_prefixed(
                message_data, cursor, len(message_data), "utf-16-be"
            )
            continue
        if tag == TAG_CONTEXT_16:
            fields["context"], cursor = read_length_prefixed(
                message_data, cursor, len(message_data), "utf-16-be"
            )
            continue
        if tag == TAG_SOURCE_TEXT:
            fields["source"], cursor = read_length_prefixed(
                message_data, cursor, len(message_data), "bytes"
            )
            continue
        if tag == TAG_CONTEXT:
            fields["context"], cursor = read_length_prefixed(
                message_data, cursor, len(message_data), "bytes"
            )
            continue
        if tag == TAG_COMMENT:
            fields["comment"], cursor = read_length_prefixed(
                message_data, cursor, len(message_data), "bytes"
            )
            continue
        raise QmFormatError(f"unsupported QM message tag {tag} at offset {cursor - 1}")

    if not terminated:
        raise QmFormatError("QM message has no end tag")
    if not translations:
        raise QmFormatError("QM message has no released translation")
    if not fields.get("source"):
        raise QmFormatError("QM message has no source text or translation ID")

    return {
        "context": fields.get("context", ""),
        "source": fields["source"],
        "comment": fields.get("comment", ""),
        "translations": translations,
    }


def extract_catalog(input_path: Path) -> dict[str, Any]:
    data = input_path.read_bytes()
    sections = parse_sections(data)
    hashes = sections[SECTION_HASHES]
    messages = sections[SECTION_MESSAGES]

    if not hashes or len(hashes) % 8:
        raise QmFormatError("QM hash section length is not a sequence of 8-byte entries")

    language = sections.get(SECTION_LANGUAGE, b"").decode("utf-8", errors="replace")
    if not language:
        language = input_path.stem.rsplit("_", 1)[-1].split(".")[-1]

    inherited = {"context": "", "source": "", "comment": ""}
    extracted_messages: list[dict[str, Any]] = []
    for entry_offset in range(0, len(hashes), 8):
        message_offset = struct.unpack_from(">I", hashes, entry_offset + 4)[0]
        message = parse_message(messages, message_offset, inherited)
        inherited = {
            "context": message["context"],
            "source": message["source"],
            "comment": message["comment"],
        }
        extracted_messages.append(message)

    extracted_messages.sort(
        key=lambda message: (
            message["context"],
            message["source"],
            message["comment"],
            message["translations"],
        )
    )

    return {
        "format": "qt-qm-catalog-extraction-v1",
        "language": language,
        "sourceFile": input_path.name,
        "sourceSha256": hashlib.sha256(data).hexdigest(),
        "messageCount": len(extracted_messages),
        "messages": extracted_messages,
    }


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("input", type=Path, help="path to the compiled Qt .qm catalog")
    parser.add_argument("output", type=Path, help="destination JSON catalog")
    args = parser.parse_args()

    try:
        if args.input.resolve() == args.output.resolve():
            raise QmFormatError("output path must not overwrite the source QM catalog")
        catalog = extract_catalog(args.input)
        args.output.parent.mkdir(parents=True, exist_ok=True)
        args.output.write_text(
            json.dumps(catalog, ensure_ascii=False, indent=2) + "\n",
            encoding="utf-8",
            newline="\n",
        )
    except (OSError, QmFormatError, UnicodeError) as error:
        print(f"error: {error}", file=sys.stderr)
        return 1

    id_like_count = sum(not message["context"] for message in catalog["messages"])
    print(
        f"Extracted {catalog['messageCount']} messages "
        f"({id_like_count} with empty context) for {catalog['language']}; "
        f"SHA-256 {catalog['sourceSha256']} -> {args.output}"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
