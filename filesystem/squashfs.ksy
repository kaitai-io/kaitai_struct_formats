meta:
  id: squashfs
  title: SquashFS
  file-extension:
    - squashfs
    - snap
    - sqfs
  endian: le
  bit-endian: be
  license: CC0-1.0
  xref:
    wikidata: Q389314
doc: |
  SquashFS is a compressed filesystem in a file, that can be read-only
  accessed from low memory devices. It is popular for booting LiveCDs and
  packing self-contained binaries. SquashFS format is used by Ubuntu .snap
  packages. SquashFS is natively supported by Linux Kernel.
doc-ref: https://github.com/AgentD/squashfs-tools-ng/blob/master/doc/format.txt
seq:
  - id: superblock
    type: superblock
enums:
  compressor:
    1: zlib
    2: lzma
    3: lzo
    4: xz
    5: lz4
    6: zstd
  inode_type:
    1: basic_directory
    2: basic_file
    3: basic_symlink
    4: basic_block_device
    5: basic_character_device
    6: basic_named_pipe
    7: basic_socket
    8: extended_directory
    9: extended_file
    10: extended_symlink
    11: extended_block_device
    12: extended_character_device
    13: extended_named_pipe
    14: extended_socket
instances:
  id_table:
    io: _root._io
    pos: superblock.id_table_start
    type: metablock_reference_list((superblock.bytes_used-superblock.id_table_start)/8)
  xattr_id_table:
    if: superblock.xattr_id_table_start != 18446744073709551615
    io: _root._io
    pos: superblock.xattr_id_table_start
    type: metablock_list
  inode_table:
    io: _root._io
    pos: superblock.inode_table_start
    type: inode_table
    size: (superblock.directory_table_start-superblock.inode_table_start)
  directory_table:
    io: _root._io
    pos: superblock.directory_table_start
    type: directory_table
    size: (superblock.fragment_table_start-superblock.directory_table_start)
  fragment_table:
    io: _root._io
    pos: superblock.fragment_table_start
    # ceil(frag_count*8/16384)
    type: "metablock_reference_list(((superblock.frag_count%512 >0) ? 1 : 0) + superblock.frag_count/512)"
  export_table:
    io: _root._io
    pos: superblock.export_table_start
    # ceil(inode_count*8/8192)
    type: "metablock_reference_list(((superblock.inode_count%1024 >0) ? 1 : 0) + superblock.inode_count/1024)"
  fragments:
    io: _root.fragment_table.data._io
    type: fragments
types:
  flags:
    seq:
      # bit count starts from the largest, byte count form the smallest
      - id: nfs_export_table            # 0x0080
        type: b1
      - id: data_deduplicated           # 0x0040
        type: b1
      - id: fragments_always_generated  # 0x0020
        type: b1
      - id: fragments_not_used          # 0x0010
        type: b1
      - id: fragments_uncompresed       # 0x0008
        type: b1
      - type: b1                        # 0x0004 bit is unused
      - id: data_blocks_uncompresed     # 0x0002
        type: b1
      - id: inodes_uncompresed          # 0x0001
        type: b1
      # bits 0x0100 are below, starting from the largest
      - type: b4                        # bits 11110000 are unused
      - id: id_table_uncompresed        # 0x0800
        type: b1
      - id: compressor_options_present  # 0x0400
        type: b1
      - id: xattrs_absent               # 0x0200
        type: b1
      - id: xattrs_uncompressed         # 0x0100
        type: b1
  superblock:
    seq:
      - id: magic
        contents: 'hsqs'
      - id: inode_count
        type: u4
      - id: mod_time
        type: u4
        doc: Unix times of last modification.
      - id: block_size
        type: u4
        doc: |
          The size of a data block in bytes. Must be a power of two between
          4096 (4k) and 1048576 (1 MiB).
      - id: frag_count
        type: u4
        doc: The number of entries in the fragment table.
      - id: compressor
        type: u2
        enum: compressor
        doc: Compressor used for both data and meta data blocks.
      - id: block_log
        type: u2
        doc: |
          The log2 of the block size. If the two fields do not agree, the
          archive is considered corrupted.
      - id: flags
        type: flags
      - id: id_count
        type: u2
        doc: The number of entries in the ID lookup table.
      - id: version_major
        type: u2
        valid:
          eq: 4
      - id: version_minor
        type: u2
        valid:
          eq: 0
      - id: root_inode_ref
        type: inode_reference
        doc: A reference to the inode of the root directory.
      - id: bytes_used
        type: u8
        doc: |
          The number of bytes used by the archive. Because SquashFS
          archives must be padded to a multiple of the underlying device
          block size, this can be less than the actual file size.
      - id: id_table_start
        type: u8
      - id: xattr_id_table_start
        type: u8
      - id: inode_table_start
        type: u8
      - id: directory_table_start
        type: u8
      - id: fragment_table_start
        type: u8
      - id: export_table_start
        type: u8
  inode_reference:
    instances:
      inode_block_start:
        value: (raw >> 16) & 0xFFFFFFFF
      block_offset:
        value: raw & 0xFFFF
      inode_table:
        io: _root._io
        pos: _root.superblock.inode_table_start + inode_block_start
        type: inode_table_entry(block_offset)
        size: (_root.superblock.directory_table_start-_root.superblock.inode_table_start-inode_block_start)
    seq:
      - id: raw
        type: u8
  inode_table_entry:
    params:
      - id: offset
        type: u2
    instances:
      inode_header:
        io: inodes._io
        pos: offset
        type: inode_header
    seq:
      - id: metablock_list
        type: metablock_list
      - id: inodes
        # we want to concatenate the data of all metablocks, so we fake a 0-sized entry here. the decode method will be called with an empty array, but the constructor has the needed netablocks
        size: 0
        process: concat(metablock_list)
        type: block_content
  inode_table:
    seq:
      - id: metablock_list
        type: metablock_list
      - id: inodes
        # we want to concatenate the data of all metablocks, so we fake a 0-sized entry here. the decode method will be called with an empty array, but the constructor has the needed netablocks
        size: 0
        process: concat(metablock_list)
        type: inode_headers
  directory_table:
    seq:
      - id: metablock_list
        type: metablock_list
      - id: directory
        # we want to concatenate the data of all metablocks, so we fake a 0-sized entry here. the decode method will be called with an empty array, but the constructor has the needed netablocks
        size: 0
        process: concat(metablock_list)
        type: block_content
  metablock_list:
    seq:
      - id: metablock
        type: metablock
        repeat: eos
  metablock_reference_list:
    params:
      - id: count
        type: u8
    seq:
      - id: metablock_reference
        type: metablock_reference(_index)
        repeat: expr
        repeat-expr: count
      - id: data
        # we want to concatenate the data of all metablocks, so we fake a 0-sized entry here. the decode method will be called with an empty array, but the constructor has the needed netablocks
        size: 0
        process: concat(metablock_reference)
        type: block_content
  metablock_reference:
    params:
      - id: index
        type: u4
    instances:
      metablock:
        io: _root._io
        pos: position
        type: metablock
    seq:
      - id: position
        type: u8
  metablock:
    instances:
      compression:
        value: (compression_and_len&0x8000)==0
      size:
        value: compression_and_len&0x7FFF
    seq:
      - id: compression_and_len
        type: u2
      - id: data
        size: size
        type: uncompressed_data(compression, 8192, false)
  uncompressed_data:
    params:
      - id: compression
        type: b1
      - id: max_size
        type: u4
      - id: padded
        type: b1
    seq:
      - id: data
        size-eos: true
        process: decompress(compression, _root.superblock.compressor, max_size, padded)
  block_content:
    seq:
      - id: dummy
        size: 0
  directory:
    seq:
      - id: directory_header
        type: directory_header
        repeat: eos
  directory_header:
    seq:
      - id: count
        type: u4
      - id: start
        type: u4
      - id: inode_number
        type: s4
      - id: directory_entry
        type: directory_entry
        # sanity check
        if: count < 256
        repeat: expr
        repeat-expr: count + 1
  directory_entry:
    seq:
      - id: offset
        type: u2
      - id: inode_offset
        type: s2
      - id: type
        type: u2
      - id: name_size
        type: u2
      - id: name
        type: str
        size: name_size + 1
        encoding: 'ASCII'
  inode_headers:
    seq:
      - id: inode_header
        type: inode_header
        repeat: expr
        repeat-expr: _root.superblock.inode_count
  inode_header:
    seq:
      - id: type
        type: u2
        enum: inode_type
      - id: permissions
        type: u2
      - id: uid
        type: u2
      - id: gid
        type: u2
      - id: mtime
        type: u4
      - id: inode_number
        type: u4
      - id: header
        type:
          switch-on: type
          cases:
            'inode_type::basic_directory': inode_header_basic_directory
            'inode_type::extended_directory': inode_header_extended_directory
            'inode_type::basic_file': inode_header_basic_file
  inode_header_basic_directory:
    instances:
      directory_table:
        io: _root._io
        pos: _root.superblock.directory_table_start + dir_block_start
        type: directory_table
        size: (_root.superblock.fragment_table_start - _root.superblock.directory_table_start - dir_block_start)
      dir:
        io: directory_table.directory._io
        pos: block_offset
        size: file_size - 3
        type: directory
    seq:
      - id: dir_block_start
        type: u4
      - id: hard_link_count
        type: u4
      - id: file_size
        type: u2
      - id: block_offset
        type: u2
      - id: parent_inode_number
        type: u4
  inode_header_extended_directory:
    instances:
      directory_table:
        io: _root._io
        pos: _root.superblock.directory_table_start + dir_block_start
        type: directory_table
        size: (_root.superblock.fragment_table_start - _root.superblock.directory_table_start - dir_block_start)
      dir:
        io: directory_table.directory._io
        pos: block_offset
        size: file_size - 3
        type: directory
    seq:
      - id: hard_link_count
        type: u4
      - id: file_size
        type: u4
      - id: dir_block_start
        type: u4
      - id: parent_inode_number
        type: u4
      - id: index_count
        type: u2
      - id: block_offset
        type: u2
      - id: xattr_idx
        type: u4
      - id: index
        type: directory_index
        repeat: expr
        repeat-expr: index_count
  directory_index:
    seq:
      - id: index
        type: u4
      - id: start
        type: u4
      - id: name_size
        type: u4
      - id: name
        type: str
        size: name_size + 1
        encoding: 'ASCII'
  inode_header_basic_file:
    instances:
      fragment:
        value: _root.fragments.fragments[frag_index]
        if: frag_index!=0xFFFFFFFF
    seq:
      - id: blocks_start
        type: u4
      - id: frag_index
        type: u4
      - id: block_offset
        type: u4
      - id: file_size
        type: u4
      - id: block_sizes
        type: u4
        repeat: expr
        repeat-expr: "file_size / _root.superblock.block_size + (frag_index==0xFFFFFFFF ? 1 : 0)"
      - id: blocks
        size: 0
        type: data_block(_index==0?blocks_start:blocks[_index-1].start+blocks[_index-1].size, block_sizes[_index], _index!=block_sizes.size-1)
        repeat: expr
        repeat-expr: block_sizes.size
  data_block:
    params:
      - id: start
        type: u4
      - id: compression_and_len
        type: u4
      - id: padded
        type: b1
    instances:
      compression:
        value: (compression_and_len&0x1000000)==0
      size:
        value: compression_and_len&0xFFFFFF
      data:
        io: _root._io
        pos: start
        size: size
        type: uncompressed_data(compression, _root.superblock.block_size, padded)
  fragments:
    seq:
      - id: fragments
        type: fragment
        repeat: expr
        repeat-expr: _root.superblock.frag_count
  fragment:
    seq:
      - id: start
        type: u8
      - id: compression_and_len
        type: u4
      - id: unused
        type: u4
      - id: block
        size: 0
        type: data_block(start, compression_and_len, false)
