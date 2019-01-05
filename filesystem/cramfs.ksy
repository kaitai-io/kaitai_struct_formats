meta:
  id: cramfs
  xref:
    wikidata: Q747406
  license: MIT
  endian: le
seq:
  - id: super_block
    type: super_block_struct

instances:
  page_size:
    value: 4096

types:
  super_block_struct:
    seq:
      - id: magic
        contents: [0x45, 0x3D, 0xCD, 0x28]
      - id: size
        type: u4
      - id: flags
        type: u4
      - id: future
        type: u4
      - id: signature
        contents: 'Compressed ROMFS'
      - id: fsid
        type: info
      - id: name
        type: str
        size: 16
        encoding: ASCII
      - id: root
        type: inode
    instances:
      # flags
      flag_fsid_v2:
        value: (flags >>  0) & 1
      flag_sorted_dirs:
        value: (flags >>  1) & 1
      flag_holes:
        value: (flags >>  8) & 1
      flag_wrong_signature:
        value: (flags >>  9) & 1
      flag_shifted_root_offset:
        value: (flags >> 10) & 1

  info:
    seq:
      - id: crc
        type: u4
      - id: edition
        type: u4
      - id: blocks
        type: u4
      - id: files
        type: u4

  inode:
    seq:
      - id: mode
        type: u2
      - id: uid
        type: u2
      - id: size_gid
        type: u4
      - id: namelen_offset
        type: u4
      - id: name
        type: str
        size: namelen
        encoding: utf-8
    instances:
      # -- [mode] --
      type:
        value: (mode >> 12) & 0b1111
        enum: file_type
      attr:
        value: (mode >> 9) & 0b0111
      perm_u:
        value: (mode >> 6) & 0b0111
      perm_g:
        value: (mode >> 3) & 0b0111
      perm_o:
        value: mode & 0b0111
      # -- [size_gid] --  
      size:
        value: size_gid & 0xFFFFFF
      gid:
        value: size_gid >> 24
      # -- [namelen_offset] --
      namelen:
        value: (namelen_offset & 0x3F) << 2
      offset:
        value: ((namelen_offset >> 6) & 0x3FFFFFF) << 2
      # -- [type dependent data] --
      as_reg_file:
        io: _root._io
        pos: offset
        type: chunked_data_inode
      as_symlink:
        io: _root._io
        pos: offset
        type: chunked_data_inode
      as_dir:
        io: _root._io
        pos: offset
        size: size
        type: dir_inode
    enums:
      file_type:
        1: fifo
        2: chrdev
        4: dir
        6: blkdev
        8: reg_file
        10: symlink
        12: socket

  chunked_data_inode:
    seq:
      - id: block_end_index
        type: u4
        repeat: expr
        repeat-expr: (_parent.size + _root.page_size - 1) / _root.page_size

      # Correct decoding can't yet be described -- raw data for now.
      - id: raw_blocks
        size-eos: true

      #- id: raw_blocks
      #  size: block_end_index[i] - _io.pos
      #  repeat: expr
      #  repeat-expr: (_parent.size + _root.page_size - 1) / _root.page_size

  dir_inode:
    seq:
      - id: children
        repeat: eos
        type: inode
        if: _io.size > 0
