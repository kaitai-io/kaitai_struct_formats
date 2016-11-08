meta:
  id: lzh
  endian: le
  application: LHA (AKA LHarc) by Yoshizaki Haruyasu
  file-extension: lzh
seq:
  - id: entries
    type: record
    repeat: eos
#    repeat-expr: 10
types:
  record:
    seq:
      - id: header_len
        type: u1
      - id: file_record
        type: file_record
        if: header_len > 0
  file_record:
    seq:
      - id: header
        size: _parent.header_len - 1
        type: header
      - id: file_uncompr_crc16
        type: u2
        if: header.header1.lha_level == 0
      - id: body
        size: header.header1.file_size_compr
  header:
    seq:
      - id: header1
        type: header1
        doc: >
          Level-neutral header, same for all LHA levels. Subsequent
          fields order and meaning varies, based on LHA level
          specified in this header.
      - id: filename_len
        type: u1
        if: header1.lha_level == 0
      - id: filename
        type: str
        size: filename_len
        encoding: ASCII
        if: header1.lha_level == 0
      - id: file_uncompr_crc16
        type: u2
        if: header1.lha_level == 2
      - id: os
        type: u1
        if: header1.lha_level == 2
      - id: ext_header_size
        type: u2
        if: header1.lha_level == 2
  header1:
    seq:
      - id: header_checksum
        type: u1
      - id: method_id
        type: str
        size: 5
        encoding: ASCII
      - id: file_size_compr
        type: u4
        doc: Compressed file size
      - id: file_size_uncompr
        type: u4
        doc: Uncompressed file size
      - id: file_timestamp
        type: u4
        doc: Original file date/time
      - id: attr
        type: u1
        doc: File or directory attribute
      - id: lha_level
        type: u1
