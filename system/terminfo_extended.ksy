meta:
  id: terminfo_extended
  title: terminfo extended storage
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
  - id: padding
    size: 1
    if: _io.pos % 2 == 1
  - id: extended_storage
    type: extended_storage
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
  extended_storage:
    seq:
      - id: num_boolean_capabilities
        type: u2
      - id: num_numeric_capabilities
        type: u2
      - id: num_string_capabilities
        type: u2
      - id: num_items_extended_string_table
        type: u2
      - id: len_extended_string_table
        type: u2
      - id: booleans
        type: flag
        repeat: expr
        repeat-expr: num_boolean_capabilities
      - id: padding
        size: 1
        if: num_boolean_capabilities % 2 == 1
      - id: numbers
        type: u2
        repeat: expr
        repeat-expr: num_numeric_capabilities
      - id: string_capabilities
        type: u2
        repeat: expr
        repeat-expr: num_string_capabilities
      - id: needed
        type: u2
        repeat: expr
        repeat-expr: need
      - id: extended_string_table
        type: extended_string_table
        size: len_extended_string_table
    instances:
      need:
        value: num_boolean_capabilities + num_numeric_capabilities + num_string_capabilities
  extended_string_table:
    seq:
      - id: strings
        terminator: 0x00
        repeat: eos
