meta:
  id: macos_ds_store
  endian: be
  ks-version: 0.8
  license: CC-BY-SA-4.0
doc-ref: |
  https://metacpan.org/pod/distribution/Mac-Finder-DSStore/DSStoreFormat.pod
  https://0day.work/parsing-the-ds_store-file-format
seq:
  - id: alignment
    contents: [0x00, 0x00, 0x00, 0x01]
  - id: buddy_allocator_header
    type: buddy_allocator_header
instances:
  buddy_allocator_body:
    type: buddy_allocator_body
    pos: buddy_allocator_header.offset_bookkeeping_info_block + 4
    size: buddy_allocator_header.size_bookkeeping_info_block
types:
  buddy_allocator_header:
    seq:
      - id: magic
        contents: [0x42, 0x75, 0x64, 0x31]
      - id: offset_bookkeeping_info_block
        type: u4
      - id: size_bookkeeping_info_block
        type: u4
      - id: copy_offset_bookkeeping_info_block
        type: u4
      - id: unused_block
        size: 16
  buddy_allocator_body:
    seq:
      - id: block_count
        type: u4
      - id: unknown_field
        size: 4
      - id: block_addresses
        type: u4
        repeat: expr
        repeat-expr: 256
      - id: directory_count
        type: u4
      - id: directory_entries
        type: directory_entry
        repeat: expr
        repeat-expr: directory_count
      - id: free_lists
        type: free_list
        repeat: expr
        repeat-expr: 32
    instances:
      directories:
        io: _root._io
        type: master_block
        repeat: expr
        repeat-expr: directory_count
        pos: (block_addresses[directory_entries[0].block_id] >> 0x05 << 0x05) + 4
        size: 1 << block_addresses[directory_entries[0].block_id] & 0x1f
  directory_entry:
    seq:
      - id: name_len
        type: u1
      - id: name
        type: str
        encoding: UTF-8
        size: name_len
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
  master_block:
    seq:
      - id: block_id
        type: u4
      - id: num_internal_nodes
        type: u4
      - id: num_records
        type: u4
      - id: num_nodes
        type: u4
      - id: unknown
        type: u4
    instances:
      block:
        io: _root._io
        type: block
        pos: (_root.buddy_allocator_body.block_addresses[block_id] >> 0x05 << 0x05) + 4
  block:
    seq:
      - id: mode
        type: u4
      - id: count
        type: u4
      - id: data
        type: block_data(mode)
        repeat: expr
        repeat-expr: count
    instances:
      block:
        io: _root._io
        type: block
        if: mode > 0
        pos: (_root.buddy_allocator_body.block_addresses[mode] >> 0x05 << 0x05) + 4
  record:
    seq:
      - id: filename
        type: ustr
      - id: structure_type
        type: four_char_code
      - id: data_type
        type: str
        encoding: UTF-8
        size: 4
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
        type: block
        if: mode > 0
        pos: (_root.buddy_allocator_body.block_addresses[block_id] >> 0x05 << 0x05) + 4
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
        type: str
        encoding: UTF-16BE
        size: 2 * length
  four_char_code:
    seq:
      - id: value
        type: str
        encoding: UTF-8
        size: 4
