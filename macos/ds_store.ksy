meta:
  id: ds_store
  title: macOS '.DS_Store' format
  license: CC-BY-SA-4.0
  ks-version: 0.8
  encoding: UTF-8
  endian: be
doc: |
  Apple macOS '.DS_Store' file format.
doc-ref: |
  https://en.wikipedia.org/wiki/.DS_Store
  https://metacpan.org/pod/distribution/Mac-Finder-DSStore/DSStoreFormat.pod
  https://0day.work/parsing-the-ds_store-file-format
seq:
  - id: alignment_header
    contents: [0x00, 0x00, 0x00, 0x01]
  - id: buddy_allocator_header
    type: buddy_allocator_header
instances:
  buddy_allocator_body:
    pos: buddy_allocator_header.ofs_bookkeeping_info_block + 4
    size: buddy_allocator_header.len_bookkeeping_info_block
    type: buddy_allocator_body
types:
  buddy_allocator_header:
    seq:
      - id: magic
        contents: ["Bud1"]
        doc: Magic number 'Bud1'
      - id: ofs_bookkeeping_info_block
        type: u4
      - id: len_bookkeeping_info_block
        type: u4
      - id: copy_ofs_bookkeeping_info_block
        type: u4
        doc: Needs to match 'offset_bookkeeping_info_block'
      - size: 16
        doc: Unused block
  buddy_allocator_body:
    seq:
      - id: num_blocks
        type: u4
        doc: Number of blocks in the allocated-blocks list
      - size: 4
        doc: Unknown field
      - id: block_addresses
        type: u4
        repeat: expr
        repeat-expr: 256
        doc: Addresses of the different blocks
      - id: num_directories
        type: u4
        doc: Indicates the number of directory entries
      - id: directory_entries
        type: directory_entry
        repeat: expr
        repeat-expr: num_directories
        doc: Each directory is an independent B-tree
      - id: free_lists
        type: free_list
        repeat: expr
        repeat-expr: 32
    instances:
      directories:
        io: _root._io
        type: master_block_ref(_index)
        repeat: expr
        repeat-expr: num_directories
        doc: Master blocks of the different B-trees
  directory_entry:
    seq:
      - id: len_name
        type: u1
      - id: name
        size: len_name
        type: str
      - id: block_id
        type: u4
  free_list:
    seq:
      - id: counter
        type: u4
      - id: offsets
        type: u4
        repeat: expr
        repeat-expr: counter
  master_block_ref:
    params:
      - id: idx
        type: u8
    instances:
      master_block:
        pos: (_parent.block_addresses[_parent.directory_entries[idx].block_id] >> 0x05 << 0x05) + 4
        size: 1 << _parent.block_addresses[_parent.directory_entries[idx].block_id] & 0x1f
        type: master_block
  master_block:
    seq:
      - id: block_id
        type: u4
        doc: Block number of the B-tree's root node
      - id: num_internal_nodes
        type: u4
        doc: Number of internal node levels
      - id: num_records
        type: u4
        doc: Number of records in the tree
      - id: num_nodes
        type: u4
        doc: Number of nodes in the tree
      - type: u4
        doc: Unknown field
    instances:
      root_block:
        io: _root._io
        pos: (_root.buddy_allocator_body.block_addresses[block_id] >> 0x05 << 0x05) + 4
        type: block
  block:
    seq:
      - id: mode
        type: u4
        doc: If mode is 0, this is a leaf node, otherwise it is an internal node
      - id: counter
        type: u4
        doc: Number of records or number of block id + record pairs
      - id: data
        type: block_data(mode)
        repeat: expr
        repeat-expr: counter
    instances:
      rightmost_block:
        io: _root._io
        pos: (_root.buddy_allocator_body.block_addresses[mode] >> 0x05 << 0x05) + 4
        type: block
        if: mode > 0
        doc: Rightmost child block pointer
  record:
    seq:
      - id: filename
        type: ustr
      - id: structure_type
        type: four_char_code
        doc: Description of the entry's property
      - id: data_type
        size: 4
        type: str
        doc: Data type of the value
      - id: value
        type:
          switch-on: data_type
          cases:
            '"long"': u4
            '"shor"': u4
            '"bool"': u1
            '"blob"': record_blob
            '"type"': four_char_code
            '"ustr"': ustr
            '"comp"': u8
            '"dutc"': u8
  block_data:
    params:
      - id: mode
        type: u4
    seq:
      - id: block_id
        type: u4
        if: mode > 0
      - id: record
        type: record
    instances:
      block:
        io: _root._io
        pos: (_root.buddy_allocator_body.block_addresses[block_id] >> 0x05 << 0x05) + 4
        type: block
        if: mode > 0
  record_blob:
    seq:
      - id: length
        type: u4
      - id: value
        size: length
  ustr:
    seq:
      - id: length
        type: u4
      - id: value
        size: 2 * length
        type: str
        encoding: UTF-16BE
  four_char_code:
    seq:
      - id: value
        size: 4
        type: str
