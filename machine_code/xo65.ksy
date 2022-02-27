meta:
  id: xo65
  title: xo65 object file
  license: CC0-1.0
  encoding: ascii
  endian: le
doc: xo65 is an object format used by the cc65 compiler <https://cc65.github.io/>

  Test files can be found in the binary packages of the cc65 package, for
  example in Debian <https://packages.debian.org/sid/cc65>
doc-ref: https://github.com/cc65/cc65/blob/4185caf85/src/common/objdefs.h
seq:
  - id: object_header
    type: object_header
types:
  object_header:
    seq:
      - id: magic
        contents: [0x55, 0x7a, 0x6e, 0x61]
      - id: version
        type: u2
      - id: flags
        type: u2
      - id: ofs_options
        type: u4
        doc: offset to option table
      - id: len_options
        type: u4
      - id: ofs_file_table
        type: u4
      - id: len_file_table
        type: u4
      - id: ofs_segment_table
        type: u4
      - id: len_segment_table
        type: u4
      - id: ofs_import_list
        type: u4
      - id: len_import_list
        type: u4
      - id: ofs_export_list
        type: u4
      - id: len_export_list
        type: u4
      - id: ofs_debug_symbols_list
        type: u4
      - id: len_debug_symbols_list
        type: u4
      - id: ofs_line_infos
        type: u4
      - id: len_line_infos
        type: u4
      - id: ofs_string_pool
        type: u4
      - id: len_string_pool
        type: u4
      - id: ofs_assertion_table
        type: u4
      - id: len_assertion_table
        type: u4
      - id: ofs_scope_table
        type: u4
      - id: len_scope_table
        type: u4
      - id: ofs_span_table
        type: u4
      - id: len_span_table
        type: u4
    instances:
      options:
        pos: ofs_options
        size: len_options
      file_table:
        pos: ofs_file_table
        size: len_file_table
      segment_table:
        pos: ofs_segment_table
        size: len_segment_table
      import_list:
        pos: ofs_import_list
        size: len_import_list
      export_list:
        pos: ofs_export_list
        size: len_export_list
      debug_symbols_list:
        pos: ofs_debug_symbols_list
        size: len_debug_symbols_list
      line_infos:
        pos: ofs_line_infos
        size: len_line_infos
      string_pool:
        pos: ofs_string_pool
        size: len_string_pool
        type: string_pool
      assertion_table:
        pos: ofs_assertion_table
        size: len_assertion_table
      scope_table:
        pos: ofs_scope_table
        size: len_scope_table
      span_table:
        pos: ofs_span_table
        size: len_span_table
  string_pool:
    seq:
      - id: num_strings
        type: u2
      - id: entries
        type: string_pool_entry
        repeat: expr
        repeat-expr: num_strings - 1
  string_pool_entry:
    seq:
      - id: len_string
        type: u1
      - id: string
        size: len_string
        type: str
