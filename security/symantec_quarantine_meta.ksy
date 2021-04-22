meta:
  id: vbnmeta
  file-extension: vbn
  endian: le
  title: Symantec Endpoint Protection quarantine metadata file parser
  license: CC-BY-SA-4.0
  ks-version: 0.9
doc: |
  Creator: Florian Bausch, ERNW Research GmbH, https://ernw-research.de
  License: CC-BY-SA-4.0 https://creativecommons.org/licenses/by-sa/4.0/
seq:
  - id: data_offset
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
  - id: padding6
    size: data_offset - _io.pos
  - id: data
    type: data
    size-eos: true
types:
  data:
    seq:
      - id: meta_entries
        size-eos: true
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