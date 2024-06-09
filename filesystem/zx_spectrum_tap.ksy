meta:
  id: zx_spectrum_tap
  title: ZX Spectrum tape file
  file-extension: tap
  xref:
    justsolve: TAP_(ZX_Spectrum)
    pronom: fmt/801
    wikidata: Q34748140
  license: CC0-1.0
  endian: le
doc: |
  TAP files are used by emulators of ZX Spectrum computer (released in
  1982 by Sinclair Research). TAP file stores blocks of data as if
  they are written to magnetic tape, which was used as primary media
  for ZX Spectrum. Contents of this file can be viewed as a very
  simple linear filesystem, storing named files with some basic
  metainformation prepended as a header.
doc-ref: https://sinclair.wiki.zxnet.co.uk/wiki/TAP_format
seq:
  - id: blocks
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
    3: bytes
types:
  block:
    seq:
      - id: len_block
        type: u2
      - id: flag
        type: u1
        enum: flag_enum
      - id: header
        type: header
        if: len_block == 0x13 and flag == flag_enum::header
      - id: data
        size: header.len_data + 4
        if: len_block == 0x13
      - id: headerless_data
        size: len_block - 1
        if: flag == flag_enum::data
  header:
    seq:
      - id: header_type
        type: u1
        enum: header_type_enum
      - id: filename
        size: 10
        pad-right: 0x20
      - id: len_data
        type: u2
      - id: params
        type:
          switch-on: header_type
          cases:
            'header_type_enum::program': program_params
            'header_type_enum::num_array': array_params
            'header_type_enum::char_array': array_params
            'header_type_enum::bytes': bytes_params
      - id: checksum
        type: u1
        doc: Bitwise XOR of all bytes including the flag byte
  program_params:
    seq:
      - id: autostart_line
        type: u2
      - id: len_program
        type: u2
  array_params:
    seq:
      - id: reserved
        type: u1
      - id: var_name
        type: u1
        doc: Variable name (1..26 meaning A$..Z$ +192)
      - id: reserved1
        contents: [0x00, 0x80]
  bytes_params:
    seq:
      - id: start_address
        type: u2
      - id: reserved
        size: 2
