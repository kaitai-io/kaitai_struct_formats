meta:
  id: lz4
  title: LZ4
  license: CC0-1.0
  endian: le
  encoding: ASCII
doc-ref: https://github.com/lz4/lz4/blob/dev/doc/lz4_Frame_format.md
doc: |
  This specification describes a single LZ4 frame.

  The original LZ4 frame format specification has the following notice:

  Copyright (c) 2013-2020 Yann Collet

  Permission is granted to copy and distribute this document for any purpose and
  without charge, including translations into other languages and incorporation
  into compilations, provided that the copyright notice and this notice are preserved,
  and that any substantive changes or deletions from the original are clearly
  marked. Distribution of this document is unlimited.
seq:
  - id: magic
    type: u4
    valid: 0x184d2204
  - id: frame_descriptor
    type: frame_descriptor
  - id: blocks
    type: block
    repeat: until
    repeat-until: _.is_endmark
  - id: content_checksum
    type: u4
    if: frame_descriptor.flag.content_checksum
types:
  frame_descriptor:
    seq:
      - id: flag
        type: flag
      - id: bd
        type: bd
      - id: content_size
        type: u8
        if: flag.content_size
      - id: dictionary_id
        type: u4
        if: flag.dictionary_id
      - id: header_checksum
        type: u1
    types:
      bd:
        seq:
          - id: reserved
            type: b1
            valid: false
          - id: block_maxsize
            type: b3
            valid:
              any-of: [4, 5, 6, 7]
          - id: reserved2
            type: b4
            valid: 0
      flag:
        seq:
          - id: version
            type: b2
          - id: block_independence
            type: b1
          - id: block_checksum
            type: b1
          - id: content_size
            type: b1
          - id: content_checksum
            type: b1
          - id: reserved
            type: b1
            valid: false
          - id: dictionary_id
            type: b1
  block:
    meta:
      bit-endian: le
    seq:
      - id: len_block
        type: b31
      - id: uncompressed
        type: b1
      - id: data
        size: len_block
      - id: checksum
        type: u4
        if: _root.frame_descriptor.flag.block_checksum and not is_endmark
    instances:
      is_endmark:
        value: not uncompressed and len_block == 0
