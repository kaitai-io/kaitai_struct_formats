meta:
  id: vbn
  file-extension: vbn
  endian: le
  title: Symantec Endpoint Protection quarantine file parser
  license: CC-BY-SA-4.0
  ks-version: 0.9
doc: |
  Creator: Florian Bausch, ERNW Research GmbH, https://ernw-research.de
  License: CC-BY-SA-4.0 https://creativecommons.org/licenses/by-sa/4.0/
seq:
  - id: encrypted_offset
    type: u4
  - id: filename
    type: str
    encoding: utf-8
    terminator: 0x0
  - id: padding1
    size: 0x180 - _io.pos
  - id: padding2
    type: u4
  - id: meta1
    type: str
    encoding: utf-8
    terminator: 0x0
  - id: meta2
    type: str
    encoding: utf-8
    terminator: 0x0
  - id: padding3
    size: 0x980 - _io.pos
  - id: padding4
    type: u4
  - id: unknown1
    type: u4
  - id: unixts1
    type: u4
  - id: timestamp1
    type: winfiletime
  - id: timestamp2
    type: winfiletime
  - id: timestamp3
    type: winfiletime
  - id: unknown2
    type: u4
  - id: padding5
    size: 0xb8c - _io.pos
  - id: threat_location
    type: str
    encoding: utf-8
    terminator: 0x0
  - id: padding6
    size: 0xbbc - _io.pos
  - id: unknown3
    type: u4
  - id: tmp_file_name
    type: str
    encoding: utf-8
    terminator: 0x0
  - id: padding7
    size: 0xd70 - _io.pos
  - id: unixts2
    type: u4
  - id: padding8
    size: encrypted_offset - _io.pos
  - id: enc_data
    type: encrypted_data
    size-eos: true
    process: xor(0x5a)
types:
  encrypted_data:
    seq:
      - id: padding
        size: 8
        contents: [0, 0, 0, 0, 0, 0, 0, 0]
      - id: meta_offset
        type: u8
      - id: meta_length
        type: u8
      - id: content_offset
        type: u8
      - id: content_length
        type: u8
    instances:
      meta_entries:
        pos: meta_offset
        size: meta_length
        type: list_of_entries
      content_entries:
        pos: content_offset
        size: content_length
        type: list_of_entries
  list_of_entries:
    seq:
      - id: entry
        type: entry
        repeat: eos
  entry:
    seq:
      - id: type_of_entry
        type: u1
      - id: content
        type:
          switch-on: type_of_entry
          cases:
            0x09: raw_content
            0x08: utf16le
            0x04: u8
            0x03: u4
            0x06: u4
            0x01: u1
            0x0a: u1
  raw_content:
    seq:
      - id: length
        type: u4
      - id: raw_content
        size: length
  utf16le:
    seq:
      - id: length
        type: u4
      - id: string_content
        type: str
        encoding: utf-16le
        size: 'length > 2 ? length - 2 : length'
      - id: padding
        size: 2
        contents: [0x00, 0x00]
        if: 'length >= 2'
  winfiletime:
    # timestamp: timestamp * (1e-07) --> seconds
    # offset: 11644473600
    seq:
      - id: ts
        type: u8
    instances:
      unixts:
        value: (ts * 1e-07) - 11644473600