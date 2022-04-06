meta:
  id: pef
  title: Preferred Executable Format
  tags:
    - macos
  license: CC0-1.0
  ks-version: 0.9
  encoding: ASCII
  endian: be
doc-ref:
  - https://en.wikipedia.org/wiki/Preferred_Executable_Format
  - https://web.archive.org/web/20020208214155/http://developer.apple.com/techpubs/mac/runtimehtml/RTArch-89.html
seq:
  - id: header
    type: container_header
  - id: section_headers
    type: section_header
    repeat: expr
    repeat-expr: header.num_sections
types:
  container_header:
    seq:
      - id: type_tag1
        contents: "Joy!"
      - id: type_tag2
        contents: "peff"
      - id: architecture
        type: u4
        enum: architectures
      - id: format_version
        type: u4
      - id: date
        type: u4
      - id: old_def_version
        type: u4
      - id: old_imp_version
        type: u4
      - id: current_version
        type: u4
      - id: num_sections
        type: u2
      - id: num_instantiated_sections
        type: u2
      - id: reserved
        size: 4
  section_header:
    seq:
      - id: ofs_name
        type: s4
      - id: default_address
        type: u4
      - id: len_total
        type: u4
      - id: len_unpacked
        type: u4
      - id: len_packed
        type: u4
      - id: ofs_container
        type: u4
      - id: section_kind
        type: u1
        enum: section
      - id: share_kind
        type: u1
        enum: share
      - id: alignment
        type: u1
      - id: reserved
        size: 1
    instances:
      section:
        pos: ofs_container
        size: len_packed
        type:
          switch-on: section_kind
          cases:
            section::loader: loader
        io: _root._io
  loader:
    seq:
      - id: header
        type: loader_header
      - id: imported_library_table
        type: imported_library
        repeat: expr
        repeat-expr: header.num_imported_libraries
      - id: imported_symbol_table
        type: imported_symbol
        repeat: expr
        repeat-expr: header.num_total_imported_symbols
      - id: relocation_headers_table
        type: relocation_header_entry
        repeat: expr
        repeat-expr: header.num_reloc_sections
      - id: export_hashtable
        size: 0
      - id: export_keytable
        size: 0
      - id: exported_symbol_table
        size: 0
  loader_header:
    seq:
      - id: main_section
        type: s4
      - id: ofs_main
        type: u4
      - id: init_section
        type: s4
      - id: ofs_init
        type: u4
      - id: term_section
        type: s4
      - id: ofs_term
        type: u4
      - id: num_imported_libraries
        type: u4
      - id: num_total_imported_symbols
        type: u4
      - id: num_reloc_sections
        type: u4
      - id: ofs_reloc_instructions
        type: u4
      - id: ofs_loader_strings
        type: u4
      - id: ofs_export_hash
        type: u4
      - id: export_hash_table_power
        type: u4
      - id: num_exported_symbols
        type: u4
    instances:
      symbols:
        pos: ofs_loader_strings
        type: strz
        repeat: eos
  imported_library:
    seq:
      - id: ofs_name
        type: u4
      - id: old_imp_version
        type: u4
      - id: current_version
        type: u4
      - id: num_imported_symbols
        type: u4
      - id: first_imported_symbol
        type: u4
      - id: options
        type: u1
      - id: reserved1
        size: 1
      - id: reserved2
        size: 2
    instances:
      name:
        pos: _parent.header.ofs_loader_strings + ofs_name
        type: strz
        io: _parent._io
  imported_symbol:
    seq:
      - id: symbol_class_data
        type: u1
      - id: ofs_name
        type: b24
    instances:
      name:
        pos: _parent.header.ofs_loader_strings + ofs_name
        type: strz
        io: _parent._io
      is_weak:
        value: symbol_class_data & 0x80 == 0x80
      symbol_class:
        value: symbol_class_data & 0xf
        enum: symbol_classes
  relocation_header_entry:
    seq:
      - id: section_index
        type: u2
      - id: reserved
        size: 2
      - id: num_reloc
        type: u4
      - id: ofs_first_reloc
        type: u4
    instances:
      relocations:
        pos: _parent.header.ofs_reloc_instructions + ofs_first_reloc
        type: u2
        repeat: expr
        repeat-expr: num_reloc
        io: _parent._io
enums:
  architectures:
    0x70777063: powerpc
    0x6d36386b: m68k
  section:
    0: code
    1: unpacked_data
    2: pattern_initialized_data
    3: constant
    4: loader
    5: debug
    6: executable_data
    7: exception
    8: traceback
  share:
    1: process_share
    4: global_share
    5: protected_share
  symbol_classes:
    0: code_address
    1: data_address
    2: standard_procedure_pointer
    3: direct_data_area
    4: linker_inserted_glue
