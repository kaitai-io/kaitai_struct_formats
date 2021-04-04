meta:
  id: lzh
  application: LHA (AKA LHarc) by Yoshizaki Haruyasu
  file-extension: lzh
  xref:
    justsolve: LHA
    pronom: fmt/626
    wikidata: Q368782
  license: CC0-1.0
  imports:
    - /common/dos_datetime
  endian: le
doc: |
  LHA (LHarc, LZH) is a file format used by a popular freeware
  eponymous archiver, created in 1988 by Haruyasu Yoshizaki. Over the
  years, many ports and implementations were developed, sporting many
  extensions to original 1988 LZH.

  File format is pretty simple and essentially consists of a stream of
  records.
seq:
  - id: entries
    type: record
    repeat: eos
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
        size: 4
        type: dos_datetime
        doc: Original file date/time
      - id: attr
        type: u1
        doc: File or directory attribute
      - id: lha_level
        type: u1
