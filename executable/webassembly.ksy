meta:
  id: webassembly
  title: Binary format for WebAssembly modules
  file-extension: wasm
  tags: 
    - webassembly
    - schema
  license: MIT
  ks-version: 0.9
  imports:
    - /common/vlq_base128_le
  endian: le

doc: |
  This document describes the binary format of a WebAssembly module 
  following the version 1.0 of the core WebAssembly standard.

  Repository: https://github.com/henrythasler/wasm-kaitai-struct

  * Naming of entities follows the official specification.
  * All integers are encoded using the LEB128 variable-length integer encoding (see vlq_base128_le.ksy).
  * The schema follows the KSY Style Guide
  * Requires ks-version 0.9+ because of attribute value validation
  * types appear in the order in which they are required

doc-ref: |
  * https://www.w3.org/TR/wasm-core-1/

seq:
  - id: magic
    contents: [0x00, "asm"]
    doc: Magic number identifying the file as a WebAssembly module
    doc-ref: https://www.w3.org/TR/wasm-core-1/#binary-magic
  - id: version
    type: u4
    doc: Version of the WebAssembly binary format
    doc-ref: https://www.w3.org/TR/wasm-core-1/#binary-version
  - id: sections
    type: section
    repeat: eos
    doc: A WebAssembly module is a set of sections
    doc-ref: https://www.w3.org/TR/wasm-core-1/#binary-module

types:
  section:
    doc: A specific section as part of a module
    doc-ref: https://www.w3.org/TR/wasm-core-1/#binary-section
    seq:
      - id: id
        type: u1
        enum: section_id
        doc: Section identifier
      - id: len_content
        type: vlq_base128_le
        doc: Length of the section content in bytes
      - id: content
        size: len_content.value
        type: 
          switch-on: id
          cases:
            'section_id::custom': custom_section
            'section_id::type': type_section
            'section_id::import': import_section
            'section_id::function': function_section
            'section_id::table': table_section
            'section_id::memory': memory_section
            'section_id::global': global_section
            'section_id::export': export_section
            'section_id::start': start_section
            'section_id::element': element_section
            'section_id::code': code_section
            'section_id::data': data_section
        doc: Section content

  custom_section:
    doc: (id 0) - Custom section whose content is application-specific and not defined by the WebAssembly specification.
    doc-ref: https://www.w3.org/TR/wasm-core-1/#binary-customsec
    seq:
      - id: name
        type: name
      - id: data
        size-eos: true
        doc: Custom section data; out of scope for this schema

  name:
    doc: UTF-8 encoded character sequence
    doc-ref: https://www.w3.org/TR/wasm-core-1/#binary-name
    seq:
      - id: length
        type: vlq_base128_le
      - id: value
        size: length.value
        type: str
        encoding: UTF-8

  type_section:
    doc: (id 1) - A vector of function types
    doc-ref: https://www.w3.org/TR/wasm-core-1/#binary-typesec
    seq:
      - id: num_functypes
        type: vlq_base128_le
      - id: functypes
        type: functype
        repeat: eos

  functype:
    doc: Byte `0x60` followed by a vector of parameters and results
    doc-ref: https://www.w3.org/TR/wasm-core-1/#binary-functype
    seq:
      - id: functype
        type: u1
        enum: types
        valid:
          eq: types::function
      - id: parameters
        type: vec_valtype
      - id: results
        type: vec_valtype

  vec_valtype:
    seq:
      - id: num_types
        type: vlq_base128_le
      - id: valtype
        type: u1
        enum: valtype
        repeat: expr
        repeat-expr: num_types.value
        doc: Value Types
        doc-ref: https://www.w3.org/TR/wasm-core-1/#binary-valtype
  
  import_section:
    doc: (id 2) - Imported components
    doc-ref: https://www.w3.org/TR/wasm-core-1/#binary-importsec
    seq:
      - id: num_imports
        type: vlq_base128_le
      - id: imports
        type: import
        repeat: eos
  
  import:
    doc: An element of the import section
    seq:
      - id: module
        type: name
      - id: name
        type: name
      - id: import_type
        type: u1
        enum: import_types
      - id: importdesc
        type: 
          switch-on: import_type
          cases:
            'import_types::func': vlq_base128_le
            'import_types::table': table
            'import_types::mem': memory
            'import_types::global': global
  
  table:
    seq:
      - id: elemtype
        type: u1
        enum: types
        valid:
          eq: types::element
      - id: limits
        type: limits

  limits:
    seq:
      - id: flags
        type: u1
        valid:
          any-of: [0x00, 0x01]
      - id: min
        type: vlq_base128_le
      - id: max
        type: vlq_base128_le
        if: flags == 0x01

  memory:
    seq:
      - id: limits
        type: limits

  global:
    seq:
      - id: valtype
        type: u1
        enum: valtype
      - id: is_mutable
        type: u1
        doc: the `is_` prefix avoids conflicts with the C++ keyword `mutable` in generated code

  function_section:
    doc: (id 3) - Vector of type indices (see `Type Section`) for all functions in the `Code Section`
    doc-ref: https://www.w3.org/TR/wasm-core-1/#binary-funcsec
    seq:
      - id: num_typeidx
        type: vlq_base128_le
      - id: typeidx
        type: vlq_base128_le
        repeat: eos

  table_section:
    doc: (id 4) Vector of tables
    doc-ref: https://www.w3.org/TR/wasm-core-1/#binary-tablesec
    seq:
      - id: num_tables
        type: vlq_base128_le
      - id: tables
        type: table
        repeat: eos

  memory_section:
    doc: (id 5) Vector of memories
    doc-ref: https://www.w3.org/TR/wasm-core-1/#binary-memsec
    seq:
      - id: num_memories
        type: vlq_base128_le
      - id: memories
        type: memory
        repeat: eos

  global_section:
    doc: (id 6) Vector of globals
    doc-ref: https://www.w3.org/TR/wasm-core-1/#binary-memsec
    seq:
      - id: num_globals
        type: vlq_base128_le
      - id: globals
        type: global
        repeat: eos

  export_section:
    doc: (id 7) - Exported entities
    doc-ref: https://www.w3.org/TR/wasm-core-1/#binary-exportsec
    seq:
      - id: num_exports
        type: vlq_base128_le
      - id: exports
        type: export
        repeat: eos

  export:
    seq:
      - id: name
        type: name
      - id: exportdesc
        type: u1
        enum: export_types
      - id: idx
        type: vlq_base128_le    

  start_section:
    doc: (id 8) - Start-function or -component of the module
    doc-ref: https://www.w3.org/TR/wasm-core-1/#binary-startsec
    seq:
      - id: start
        type: vlq_base128_le
        doc: function index of the start-function

  element_section:
    doc: (id 9) - Vector of element sections
    doc-ref: https://www.w3.org/TR/wasm-core-1/#binary-elemsec
    seq:
      - id: num_elements
        type: vlq_base128_le
      - id: elements
        type: element
        repeat: eos

  element:
    seq:
      - id: tableidx
        type: vlq_base128_le
      - id: offset_expr
        terminator: 0x0b
        doc: The offset is given by a constant expression that DOES NOT include an end marker
        doc-ref: https://www.w3.org/TR/wasm-core-1/#valid-constant
      - id: num_init
        type: vlq_base128_le
      - id: init_vec
        type: vlq_base128_le
        repeat: expr
        repeat-expr: num_init.value

  code_section:
    doc: (id 10) A vector of code entries
    doc-ref: https://www.w3.org/TR/wasm-core-1/#binary-codesec
    seq:
      - id: num_entries
        type: vlq_base128_le
      - id: entries
        type: code
        repeat: eos

  code:
    seq:
      - id: len_func
        type: vlq_base128_le
      - id: func
        size: len_func.value
        type: func

  func:
    seq:
      - id: num_locals
        type: vlq_base128_le
      - id: locals
        type: local
        repeat: expr
        repeat-expr: num_locals.value
      - id: expr
        size-eos: true

  local:
    seq:
      - id: num_valtype
        type: vlq_base128_le
      - id: valtype
        type: u1
        enum: valtype

  data_section:
    doc: (11) - Vector of data segments
    doc-ref: https://www.w3.org/TR/wasm-core-1/#binary-datasec
    seq:
      - id: num_data
        type: vlq_base128_le
      - id: data_segments
        type: data_segment
        repeat: eos

  data_segment:
    seq:
      - id: data_memidx
        type: vlq_base128_le
      - id: offset_expr
        terminator: 0x0b
        doc: The offset is given by a constant expression that DOES NOT include an end marker
        doc-ref: https://www.w3.org/TR/wasm-core-1/#valid-constant
      - id: num_init
        type: vlq_base128_le
      - id: init_vec
        size: num_init.value

enums:
  section_id:
    0: custom
    1: type
    2: import
    3: function
    4: table
    5: memory
    6: global
    7: export
    8: start
    9: element
    10: code
    11: data

  valtype:
    0x7f: i32
    0x7E: i64
    0x7D: f32
    0x7C: f64

  types:
    0x60: function
    0x70: element

  export_types:
    0x00: func
    0x01: table
    0x02: mem
    0x03: global

  import_types:
    0x00: func
    0x01: table
    0x02: mem
    0x03: global
