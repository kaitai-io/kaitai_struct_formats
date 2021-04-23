meta:
  id: windef_scan_history
  endian: le
  title: Windows Defender scan history file parser
  license: CC-BY-SA-4.0
  ks-version: 0.9
doc: |
  Creator: Florian Bausch, ERNW Research GmbH, https://ernw-research.de
  License: CC-BY-SA-4.0 https://creativecommons.org/licenses/by-sa/4.0/
seq:
  - id: entry
    type: entry
    repeat: eos
types:
  entry:
    seq:
      - id: length
        type: u4
      - id: elementtype
        type: u4
        enum: elementtypes
        if: 'length > 0'
      - id: content
        size: 'length > 2 and elementtype == elementtypes::utf16 ? length - 2 : length'
        type:
          switch-on: elementtype
          cases:
            elementtypes::winfiletime: winfiletime
            elementtypes::uint4_0: u4
            elementtypes::uint4_5: u4
            elementtypes::uint4_6: u4
            elementtypes::utf16: str_utf16le
            elementtypes::uint8: u8
            elementtypes::threattracking: threattracking
        if: 'length > 0'
      - id: padding2
        size: 2
        if: 'length > 2 and elementtype == elementtypes::utf16'
      - id: padding
        size: (8 - _io.pos) % 8
    enums:
      elementtypes:
        0x00: uint4_0
        0x05: uint4_5
        0x06: uint4_6
        0x08: uint8
        0x0a: winfiletime
        0x15: utf16
        0x28: threattracking
        0xe1: raw
  str_utf16le:
    seq:
      - id: value
        type: str
        encoding: UTF-16LE
        size-eos: true
  winfiletime:
    # timestamp: timestamp * (1e-07) --> seconds
    # offset: 11644473600
    seq:
      - id: ts
        type: u8
    instances:
      unixts:
        value: (ts * 1e-07).to_i - 11644473600
  raw:
    seq:
      - id: raw_content
        size-eos: true
  threattracking:
    seq:
      - id: length
        type: u4
      - id: trackingentry
        type: trackingentry
        repeat: eos
  trackingentry:
    seq:
      - id: length
        type: u4
      - id: name
        type: str
        encoding: UTF-16LE
        size: 'length > 2 ? length - 2 : length'
      - id: padding
        size: 2
        if: 'length > 2'
      - id: trackingtype
        type: u4
        enum: trackingtypes
      - id: content
        type:
          switch-on: trackingtype
          cases:
            trackingtypes::flags: u4
            trackingtypes::utf16: str_utf16le_with_length
            trackingtypes::winfiletime: winfiletime
            trackingtypes::bool: u1
    enums:
      trackingtypes:
        0x03: flags
        0x04: winfiletime
        0x05: bool
        0x06: utf16
  str_utf16le_with_length:
    seq:
      - id: length
        type: u4
      - id: value
        type: str
        encoding: UTF-16LE
        size: 'length > 2 ? length - 2 : length'
      - id: padding
        size: 2
        if: 'length > 2'
