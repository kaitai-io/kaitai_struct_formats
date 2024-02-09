meta:
  id: bzip3
  title: Bzip3 header
  file-extension: bz3
  license: LGPL-3.0
  encoding: UTF-8
  endian: le
doc-ref: https://github.com/kspalaiologos/bzip3
seq:
  - id: header
    type: header
  - id: blocks
    type: compressed_data_block
    repeat: until
    repeat-until: _io.eof or _.is_last
types:
  header:
    seq:
      - id: signature
        contents: 'BZ3v1'
      - id: block_size
        type: u4
  compressed_data_block:
    seq:
      - id: len_compressed
        type: u4
      - id: len_uncompressed
        type: u4
        valid:
          max: _root.header.block_size
      - id: data
        size: len_compressed
    instances:
      is_last:
        value: len_uncompressed < _root.header.block_size
