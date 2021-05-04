meta:
  id: symantec_quarantine_meta
  file-extension: vbn
  endian: le
  title: Symantec Endpoint Protection quarantine metadata file
  license: MIT
  ks-version: 0.9
doc: |
  Creator: Florian Bausch, ERNW Research GmbH, https://ernw-research.de
  The Symantec quarantine files are created by Symantec Endpoint Protection and store suspected malware and its metadata.
  The parser was created by analyzing different quarantine files.
  The quarantine files consist of an unencrypted metadata part and a data part. Both hold metadata of the suspected malware.
doc-ref: https://github.com/ernw/quarantine-formats/blob/master/docs/Symantec_Endpoint_Protection.md
seq:
  - id: ofs_data
    type: u4
  - id: filename
    type: strz
    encoding: utf-8
    size: 0x180
  - id: meta
    type: str
    encoding: utf-8
    size: 0x800
    doc: |
      The string can contain null bytes at arbitrary locations, therefore no strz.
      Therefore, the null bytes have to be stripped manually.
instances:
  data:
    pos: ofs_data
    type: list_of_entries
    size-eos: true
types:
  list_of_entries:
    seq:
      - id: entry
        type: entry
        repeat: eos
  entry:
    seq:
      - id: type_of_entry
        type: u1
        enum: content_type
      - id: content
        type:
          switch-on: type_of_entry
          cases:
            content_type::raw_stream: raw_content
            content_type::utf16_string: utf16le
            content_type::int_8byte: u8
            content_type::int_4byte1: u4
            content_type::int_4byte2: u4
            content_type::int_1byte1: u1
            content_type::int_1byte2: u1
    enums:
      content_type:
        0x09: raw_stream
        0x08: utf16_string
        0x04: int_8byte
        0x03: int_4byte1
        0x06: int_4byte2
        0x01: int_1byte1
        0x0a: int_1byte2
  raw_content:
    seq:
      - id: len_raw_content
        type: u4
      - id: raw_content
        size: len_raw_content
  utf16le:
    seq:
      - id: len_string
        type: u4
      - id: string
        type: str
        encoding: utf-16le
        size: 'len_string > 2 ? len_string - 2 : len_string'
      - id: padding
        size: 2
        contents: [0x00, 0x00]
        if: 'len_string >= 2'
  winfiletime:
    seq:
      - id: ts
        type: u8
    instances:
      unixts:
        value: (ts * 1e-07) - 11644473600
        doc: |
          timestamp: timestamp * (1e-07) --> seconds
          offset: 11644473600
