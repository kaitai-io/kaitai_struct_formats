meta:
  id: gdata_quarantine
  file-extension: q
  application: G Data Antivirus
  endian: le
  title: G Data quarantine file
  license: MIT
  ks-version: 0.9
doc: |
  Creator: Florian Bausch, ERNW Research GmbH, https://ernw-research.de
  G Data quarantine files are created by the G Data antivirus software.
  They store suspected malware and its metadata.
  This parser was created by analyzing different quarantine files.
  G Data quarantine files consist of three encrypted parts. The first two parts hold metadata, the third holds the suspected malware.
doc-ref: https://github.com/ernw/quarantine-formats/blob/master/docs/GData.md
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
    doc: The suspected malware file.
types:
  encrypted_data1:
    seq:
      - id: unknown1
        type: u4
      - id: unknown2
        type: u4
      - id: unknown3
        type: u4
      - id: qua_time
        type: u4
        doc: The timestamp of the detection of the suspected malware.
      - id: unknown5
        type: u4
      - id: malware_type
        type: utf16le
        doc: The name/type of the suspected malware.
  encrypted_data2:
    seq:
      - id: unknown1
        type: u4
      - id: unknown2
        type: u4
      - id: filesize
        type: u4
      - id: unknown_string1
        type: utf16le
      - id: unknown4
        type: u4
      - id: unkown5
        type: u4
      - id: mtime
        type: winfiletime
      - id: atime
        type: winfiletime
      - id: ctime
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
      - id: len_string
        type: u1
      - id: string
        type: str
        encoding: utf-16le
        size: len_string * 2
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
