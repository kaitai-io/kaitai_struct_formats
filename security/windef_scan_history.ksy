meta:
  id: windef_scan_history
  endian: le
  title: Windows Defender scan history file
  license: MIT
  ks-version: 0.9
doc: |
  Creator: Florian Bausch, ERNW Research GmbH, https://ernw-research.de
  Scan History files are created by Windows Defender to store metadata about scans that found malware.
  They contain a list of entries which hold, for example, check sumsums and scan times.
doc-ref: https://github.com/ernw/quarantine-formats/blob/master/docs/Windows_Defender.md
seq:
  - id: entry
    type: entry
    repeat: eos
types:
  entry:
    seq:
      - id: len_content
        type: u4
      - id: element_type
        type: u4
        enum: element_types
        if: 'len_content > 0'
      - id: content
        size: 'len_content > 2 and element_type == element_types::utf16 ? len_content - 2 : len_content'
        type:
          switch-on: element_type
          cases:
            element_types::winfiletime: winfiletime
            element_types::uint4_0: u4
            element_types::uint4_5: u4
            element_types::uint4_6: u4
            element_types::utf16: str_utf16le
            element_types::uint8: u8
            element_types::threat_tracking: threat_tracking
        if: 'len_content > 0'
      - id: padding2
        size: 2
        if: 'len_content > 2 and element_type == element_types::utf16'
      - id: padding
        size: (8 - _io.pos) % 8
    enums:
      element_types:
        0x00: uint4_0
        0x05: uint4_5
        0x06: uint4_6
        0x08: uint8
        0x0a: winfiletime
        0x15: utf16
        0x28: threat_tracking
        0x1e: raw
  str_utf16le:
    seq:
      - id: value
        type: str
        encoding: UTF-16LE
        size-eos: true
  winfiletime:
    seq:
      - id: ts
        type: u8
    instances:
      unixts:
        value: (ts * 1e-07).to_i - 11644473600
        doc: |
          timestamp: timestamp * (1e-07) --> seconds
          offset: 11644473600
  raw:
    seq:
      - id: raw_content
        size-eos: true
  threat_tracking:
    seq:
      - id: len_threat_tracking
        type: u4
      - id: tracking_entry
        type: tracking_entry
        repeat: eos
  tracking_entry:
    seq:
      - id: len_name
        type: u4
      - id: name
        type: str
        encoding: UTF-16LE
        size: 'len_name > 2 ? len_name - 2 : len_name'
      - id: padding
        size: 2
        if: 'len_name > 2'
      - id: tracking_type
        type: u4
        enum: tracking_types
      - id: content
        type:
          switch-on: tracking_type
          cases:
            tracking_types::flags: u4
            tracking_types::utf16: str_utf16le_with_length
            tracking_types::winfiletime: winfiletime
            tracking_types::bool: u1
        doc: The meaning of the flags is not known.
    enums:
      tracking_types:
        0x03: flags
        0x04: winfiletime
        0x05: bool
        0x06: utf16
  str_utf16le_with_length:
    seq:
      - id: len_string
        type: u4
      - id: string
        type: str
        encoding: UTF-16LE
        size: 'len_string > 2 ? len_string - 2 : len_string'
      - id: padding
        size: 2
        if: 'len_string > 2'
