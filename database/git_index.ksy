meta:
  id: git_index
  title: Git index
  license: CC0-1.0
  ks-version: 0.9
  endian: be
  bit-endian: be
  encoding: UTF-8
doc-ref: https://github.com/git/git/blob/main/Documentation/technical/index-format.txt
seq:
  - id: header
    type: header
  - id: entries
    type: entry
    repeat: expr
    repeat-expr: header.num_entries
  - id: extensions
    type: extension
    repeat: until
    repeat-until: _io.pos >= _io.size - len_hash
  - id: checksum
    size: len_hash
instances:
  len_hash:
    value: 20   # SHA1, change to 32 for SHA256
types:
  header:
    seq:
      - id: magic
        contents: "DIRC"
      - id: version
        type: u4
        valid:
          any-of: [2]    # only support version 2 now
          #any-of: [2, 3, 4]
      - id: num_entries
        type: u4
  entry:
    seq:
      - id: entry
        type: entry_body
      - id: padding
        #size: (-(_io.pos - _root.header._sizeof) % 8)
        size: padding_needed
    instances:
      padding_needed:
        value: '(_io.pos - _root.header._sizeof) % 8 == 0 ? 8 : (-(_io.pos - _root.header._sizeof) % 8)'
  entry_body:
    seq:
      - id: ctime_seconds
        type: u4
      - id: ctime_nanoseconds
        type: u4
      - id: mtime_seconds
        type: u4
      - id: mtime_nanoseconds
        type: u4
      - id: dev
        type: u4
      - id: inode
        type: u4
      - id: mode
        type: mode
        size: 4
      - id: uid
        type: u4
      - id: gid
        type: u4
      - id: file_size
        type: u4
        doc: file size, truncated to 32 bit
      - id: object_name
        size: _root.len_hash
      - id: name_flag
        type: name_flag
      - id: name
        type: str
        size: name_flag.len_name
  mode:
    seq:
      - id: unused
        type: b16
      - id: object_type
        type: b4
        enum: object_type_mode
        valid:
          any-of:
            - object_type_mode::regular
            - object_type_mode::symbolic_link
            - object_type_mode::gitlink
      - id: unused1
        type: b3
        valid: 0
      - id: permissions
        type: b9
  name_flag:
    seq:
      - id: assume_valid
        type: b1
      - id: extended_flag
        type: b1
      - id: stage
        type: b2
      - id: len_name
        type: b12
  extension:
    seq:
      - id: signature
        type: u4
        enum: git_extensions
        valid:
          any-of:
            - git_extensions::cache_tree
            - git_extensions::resolve_undo
            - git_extensions::split_index
            - git_extensions::untracked_cache
            - git_extensions::file_system_monitor
            - git_extensions::end_of_index_entry
            - git_extensions::index_entry_offset_table
            - git_extensions::sparse_directory_entries
      - id: len_extension_data
        type: u4
      - id: extension_data
        size: len_extension_data
        type:
          switch-on: signature
          cases:
            git_extensions::cache_tree: tree
  tree:
    seq:
      - id: tree_entries
        type: tree_entry
        repeat: eos
  tree_entry:
    seq:
      - id: path_component
        type: strz
      - id: num_entries
        type: str
        terminator: 0x20
      - id: num_subtries
        type: str
        terminator: 0x0a
      - id: object_name
        size: _root.len_hash
enums:
  git_extensions:
    0x54524545: cache_tree   # 'TREE'
    0x52455543: resolve_undo # 'REUC'
    0x6c696e6b: split_index  # 'link'
    0x554e5452: untracked_cache  # 'UNTR'
    0x46534d4e: file_system_monitor  # 'FSMN'
    0x454f4945: end_of_index_entry  # 'EOIE'
    0x49454f54: index_entry_offset_table  # 'IEOT'
    0x73646972: sparse_directory_entries  # 'sdir'
  object_type_mode:
    8: regular
    10: symbolic_link
    14: gitlink
