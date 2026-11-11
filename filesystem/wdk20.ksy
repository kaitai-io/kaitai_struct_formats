meta:
  id: wdk20
  license: MIT
  encoding: ASCII
  endian: be
doc-ref: https://github.com/rampageX/firmware-mod-kit/blob/40dd7e74efbca0f7c35b1324d2b9414fab91206a/src/firmware-tools/unwdk.py
seq:
  - id: header
    type: fs_header
  - id: inodes
    type: inodes
    size: header.len_inodes - header._sizeof
  - id: lzma_blobs
    type: dummy
    size: header.len_data
types:
  dummy: {}
  fs_header:
    seq:
      - id: checksum
        size: 8
      - id: unknown_1
        type: u2
      - id: num_files
        type: u2
      - id: len_data
        type: u4
      - id: len_inodes
        type: u2
      - id: version
        size: 8
        type: strz
  inodes:
    seq:
      - id: inodes
        type: |
          inode(_index != 0 ? inodes[_index-1].ofs_end : 0)
        repeat: expr
        repeat-expr: _root.header.num_files
  inode:
    -webide-representation: '{name}'
    params:
      - id: ofs_start
        type: u4
    seq:
      - id: unknown
        size: 1
      - id: len_inode
        type: u1
      - id: len_data
        type: u2
      - id: name
        type: strz
      - id: padding
        size: 1
        if: _io.pos % 2 == 1
    instances:
      ofs_end:
        value: 'ofs_start + len_data'
      data:
        io: _root.lzma_blobs._io
        pos: ofs_start
        size: len_data
