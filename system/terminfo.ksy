meta:
  id: terminfo
  title: terminfo
  license: CC0-1.0
  encoding: ASCII
  endian: le
doc: |
  terminfo files, format described in the Linux man page for terminfo files
  man 5 term
seq:
  - id: magic
    size: 2
    contents: [0x1a, 0x01]
  - id: len_names_section
    type: u2
    valid:
      min: 1
      max: 128
    doc: the size, in bytes, of the names section
  - id: len_boolean_section
    type: u2
    doc: the number of bytes in the boolean section
  - id: num_numbers_section
    type: u2
    doc: the number of short integers in the numbers section
  - id: num_strings_offsets
    type: u2
    doc: the number of offsets (short integers) in the strings section
  - id: len_string_table
    type: u2
    doc: the size, in bytes, of the string table
  - id: names_section
    type: names_section
    size: len_names_section
  - id: boolean_section
    type: boolean_section
    size: len_boolean_section
  - id: boolean_padding
    size: 1
    if: (len_names_section + len_boolean_section) % 2 == 1
  - id: numbers_section
    type: numbers_section
    size: num_numbers_section * 2
  - id: strings_section
    type: strings_section
    size: num_strings_offsets * 2
  - id: string_table
    type: string_table
    size: len_string_table
types:
  names_section:
    seq:
      - id: names
        type: strz
  boolean_section:
    seq:
      - id: flags
        type: flag
        repeat: eos
  flag:
    seq:
      - id: flag
        type: u1
        valid:
          any-of: [0, 1]
  numbers_section:
    seq:
      - id: number
        type: u2
        repeat: eos
  strings_section:
    seq:
      - id: string_offset
        type: u2
        repeat: eos
  string_table:
    seq:
      - id: strings
        terminator: 0x00
        repeat: eos
