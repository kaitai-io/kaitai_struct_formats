meta:
  id: tap
  file-extension: tap
  endian: le
  license: CC0-1.0
  title: ZX Spectrum tape file format
doc-ref: https://faqwiki.zxnet.co.uk/wiki/TAP_format
seq:
  - id: block
    type: block
    repeat: eos
enums:
  flag_enum:
    0x00: header
    0xFF: data
  header_type_enum:
    0: program
    1: num_array
    2: char_array
    3: code_file
types:
  block:
    seq:
      - id: length
        contents: [0x13, 0x00]
      - id: flag
        type: u1
        enum: flag_enum
      - id: header
        type: header_block
      - id: data
        size: header.data_length + 4
  header_block:
    seq:
      - id: header_type
        type: u1
        enum: header_type_enum
      - id: filename
        size: 10
        type: str
        encoding: ASCII
      - id: data_length
        type: u2
      - id: param1
        type: u2
      - id: param2
        type: u2
      - id: checksum
        type: u1