meta:
  id: gdata
  file-extension: q
  endian: le
  title: G Data quarantine file parser
  license: CC-BY-SA-4.0
  ks-version: 0.9
doc: |
  Creator: Florian Bausch, ERNW Research GmbH, https://ernw-research.de
  License: CC-BY-SA-4.0 https://creativecommons.org/licenses/by-sa/4.0/
seq:
  - id: magic1
    size: 4
    contents: [0xca, 0xfe, 0xba, 0xbe]
  - id: len_data1
    type: u4
  - id: data1
    size: len_data1
    type: encrypted_data1
    process: util.custom_arc4.custom_arc4([0xA7, 0xBF, 0x73, 0xA0, 0x9F, 0x03, 0xD3, 0x11,
                                           0x85, 0x6F, 0x00, 0x80, 0xAD, 0xA9, 0x6E, 0x9B])
  - id: magic2
    size: 4
    contents: [0xba, 0xad, 0xf0, 0x0d]
  - id: len_data2
    type: u4
  - id: data2
    size: len_data2
    type: encrypted_data2
    process: util.custom_arc4.custom_arc4([0xA7, 0xBF, 0x73, 0xA0, 0x9F, 0x03, 0xD3, 0x11,
                                           0x85, 0x6F, 0x00, 0x80, 0xAD, 0xA9, 0x6E, 0x9B])
  - id: mal_file
    size-eos: true
    process: util.custom_arc4.custom_arc4([0xA7, 0xBF, 0x73, 0xA0, 0x9F, 0x03, 0xD3, 0x11,
                                           0x85, 0x6F, 0x00, 0x80, 0xAD, 0xA9, 0x6E, 0x9B])
types:
  encrypted_data1:
    seq:
      - id: unknown1
        type: u4
      - id: unknown2
        type: u4
      - id: unknown3
        type: u4
      - id: quatime
        type: u4
      - id: unknown5
        type: u4
      - id: malwaretype
        type: utf16le
  encrypted_data2:
    seq:
      - id: unknown1
        type: u4
      - id: unknown2
        type: u4
      - id: filesize
        type: u4
      - id: unknownstring1
        type: utf16le
      - id: unknown4
        type: u4
      - id: unkown5
        type: u4
      - id: time1
        type: winfiletime
      - id: time2
        type: winfiletime
      - id: time3
        type: winfiletime
      - id: unknown6
        type: u4
      - id: filesize2
        type: u4
      - id: path
        type: utf16le
  utf16le:
    seq:
      - id: bom
        size: 3
        contents: [0xFF, 0xFE, 0xFF]
      - id: number_of_chars
        type: u1
      - id: string_content
        type: str
        encoding: utf-16le
        size: number_of_chars * 2
  winfiletime:
    # timestamp: timestamp * (1e-07) --> seconds
    # offset: 11644473600
    seq:
      - id: ts
        type: u8
    instances:
      unixts:
        value: (ts * 1e-07) - 11644473600