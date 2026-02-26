meta:
  id: cpython_frozen_table
  title: CPython frozen table
  application: CPython 3
  license: Unlicense
  endian: le
  encoding: ascii
doc: |
  CPython has facilities to embed serialized python objects bytecode right into cpython binaries (libpython, which mai be linked to python as a static lib).
  These stuff is organized into an array of `_frozen`, the ptr to the table is exported as PyImport_FrozenModules.
  
doc-ref:
  - "https://github.com/python/cpython/blob/master/Include/import.h#L136L140"
  - "https://github.com/python/cpython/blob/master/Python/import.c#L1257#L1278"
  - "https://github.com/python/cpython/blob/master/Lib/ctypes/test/test_values.py#L50"
params:
  - id: pointer_size
    type: u1
    doc: "sizeof(void*), 4 or 8"
  - id: int_size
    type: u1
    doc: "sizeof(int), 4 or 8"
  - id: padding_size
    type: u1
    doc: "4 or 0"
  #- id: parsed_binary # unneeded for now, because KS lacks the feature
  #  type: object
  #  doc: "Object of a parsed binary to be passed to translated_ptr. translated_ptr translates raw offset into offset in a blob"
  - id: table_offset
    type: u8
    doc: "Offset of the table in a file / binary image"
instances:
  table:
    pos: table_offset
    type: entry
    repeat: until
    repeat-until: _.name_ptr.raw_ptr == 0

types:
  ptr_type:
    doc: "Selects the right size of ptr based on platform pointer_size."
    seq:
      - id: raw_ptr
        type:
          switch-on: _root.pointer_size
          cases:
            4: u4
            8: u8
  entry:
    seq:
      - id: name_ptr
        type: ptr_type
      - id: code_ptr
        type: ptr_type
      - id: code_size_and_type
        type:
          switch-on: _root.int_size
          cases:
            4: s4
            8: s8
      - id: padding
        size: _root.padding_size
    instances:
      is_package:
        value: code_size_and_type < 0
      code_size:
        value: "(is_package ? -code_size_and_type : code_size_and_type)"
      #translated_code_ptr:
        #pos: 0
        #type: translated_ptr(_root.parsed_binary, code_ptr).to_i
      #translated_name_ptr:
        #pos: 0
        #type: translated_ptr(_root.parsed_binary, name_ptr).to_i
      #translated:
      #  pos: 0
      #  type: translated(translated_code_ptr, code_size, translated_name_ptr)
  
  translated_entry:
    doc: "Represents a translated table entry"
    params:
      - id: code_offset
        type: u8
        doc: "translated offset of code"
      - id: entry
        type: entry
      - id: name_offset
        type: u8
        doc: "translated offset of name"
    instances:
      code:
        pos: code_offset
        size: entry.code_size
      name:
        pos: name_offset
        type: strz
