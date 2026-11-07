meta:
  id: winhelp
  title: Microsoft WinHelp
  file-extension: hlp
  tags:
    - dos
  license: CC0-1.0
  ks-version: 0.9
  encoding: ASCII
  endian: le
doc-ref: http://www.oocities.org/mwinterhoff/helpfile.htm
seq:
  - id: magic
    contents: [0x3f, 0x5f, 0x03, 0x00]
  - id: ofs_internal_directory
    type: u4
  - id: ofs_first_free_block
    type: s4
  - id: len_file
    type: u4
instances:
  internal_directory:
    pos: ofs_internal_directory
    type: internal_directory
types:
  internal_directory:
    seq:
      - id: header
        type: file_header
      - id: contents
        type: b_tree
        size: header.len_used_space
      - id: free_space
        size: header.len_reserved_space - header._sizeof - header.len_used_space
  file_header:
    seq:
      - id: len_reserved_space
        type: u4
      - id: len_used_space
        type: u4
      - id: file_flags
        type: u1
  b_tree:
    seq:
      - id: magic
        contents: [0x3b, 0x29]
      - id: flags
        type: u2
      - id: page_size
        type: u2
      - id: structure
        type: strz
        size: 16
      - id: zero
        type: u2
        valid: 0
      - id: page_splits
        type: u2
      - id: root_page
        type: u2
      - id: negative_one
        type: s2
        valid: -1
      - id: num_pages
        type: u2
      - id: num_levels
        type: u2
      - id: num_entries
        type: u4
      - id: pages
        size: page_size
        repeat: expr
        repeat-expr: num_pages - 1
      - id: leaf_page
        type: leaf_page
        size: page_size
  leaf_page:
    seq:
      - id: num_unused
        type: u2
      - id: num_entries
        type: u2
      - id: previous_leaf_page
        type: s2
      - id: next_leaf_page
        type: s2
      - id: entries
        type: leaf_entry
        repeat: expr
        repeat-expr: num_entries
  leaf_entry:
    seq:
      - id: filename
        type: strz
      - id: ofs_fileheader
        type: u4
    instances:
      file:
        pos: ofs_fileheader
        io: _root._io
        type: file_data(filename)
  file_data:
    params:
      - id: filename
        type: str
    seq:
      - id: header
        type: file_header
      - id: body
        size: header.len_used_space
        type:
          switch-on: filename
          cases:
            '"|CTXOMAP"': ctxomap
            '"|FONT"': font
            '"|SYSTEM"': system
      - id: free_space
        size: header.len_reserved_space - header.len_used_space - header._sizeof
  ctxomap:
    seq:
      - id: num_entries
        type: u2
      - id: entries
        type: ctxo_map_entry
        repeat: expr
        repeat-expr: num_entries
    types:
      ctxo_map_entry:
        seq:
          - id: map_id
            type: u4
          - id: ofs_topic
            type: u4
  font:
    seq:
      - id: num_face_names
        type: u2
      - id: num_descriptors
        type: u2
      - id: ofs_facenames
        type: u2
      - id: ofs_descriptors
        type: u2
      - id: num_styles
        type: u2
        if: ofs_facenames >= 12
      - id: ofs_styles
        type: u2
        if: ofs_facenames >= 12
      - id: num_char_map_tables
        type: u2
        if: ofs_facenames >= 16
      - id: ofs_char_map_tables
        type: u2
        if: ofs_facenames >= 16
  system:
    seq:
      - id: magic
        contents: [0x6c, 0x03]
      - id: minor
        type: u2
        enum: format_version
        valid:
          any-of:
            - format_version::windows_31
      - id: major
        type: u2
        valid: 1
      - id: date
        type: u4
      - id: flags
        type: u2
      - id: system_records
        type: system_record
        repeat: eos
    types:
      system_record:
        seq:
          - id: record_type
            type: u2
            enum: system_record_types
          - id: len_data
            type: u2
          - id: data
            size: len_data
            type:
              switch-on: record_type
              cases:
                system_record_types::title: strz
                system_record_types::copyright: strz
                system_record_types::config: strz
                system_record_types::window: window
      window:
        seq:
          - id: flags
            type: u2
          - id: window_type
            #type: str
            size: 10
          - id: name
            #type: str
            size: 9
          - id: caption
            #type: str
            size: 51
          - id: x_coordinate
            type: u2
          - id: y_coordinate
            type: u2
          - id: width
            type: u2
          - id: height
            type: u2
          - id: maximize
            type: u2
enums:
  format_version:
    15: windows_30
    21: windows_31
    27: media_view
    33: windows_95
  system_record_types:
    1: title
    2: copyright
    3: contents
    4: config
    5: icon
    6: window
