meta:
  id: fpkg
  title: D-Link FPKG
  license: MIT
  encoding: ascii
  endian: be
doc-ref: https://github.com/onekey-sec/unblob/blob/91941f3d9a6f8d0af1e80b2712ece93499037a96/python/unblob/handlers/archive/dlink/fpkg.py
seq:
  - id: header
    type: header
  - id: files
    type: file_header
    repeat: eos
types:
  header:
    seq:
      - id: magic
        contents: 'FPKG'
      - id: unknown_1
        size: 4
      - id: len_header
        type: u4
      - id: rest_of_header
        type: rest_of_header
        size: len_header - magic._sizeof - unknown_1._sizeof - len_header._sizeof
    types:
      rest_of_header:
        seq:
          - id: unknown_2
            size: 4
          - id: len_name
            type: u4
          - id: name
            type: strz
            size: len_name
  file_header:
    seq:
      - id: len_header
        type: u4
      - id: rest_of_header
        size: len_header - len_header._sizeof
        type: rest_of_header
      - id: data
        size: rest_of_header.len_file
    types:
      rest_of_header:
        seq:
          - id: file_type
            type: u2
            enum: filetypes
          - id: unknown_1
            size: 2
          - id: len_file
            type: u4
          - id: name
            type: strz
enums:
  filetypes:
    0x100: regular
    0x102: checksum
    0x103: signature
