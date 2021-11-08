meta:
  id: lzop
  title: lzop
  file-extension: lzo
  license: GPL-2.0-or-later
  encoding: UTF-8
  endian: be
doc: |
  lzop is a compression/decompression program using the LZO library, similar
  as gzip using zlib.
doc-ref: https://www.lzop.org/
seq:
  - id: magic
    contents: [0x89, 0x4c, 0x5a, 0x4f, 0x00, 0x0d, 0x0a, 0x1a, 0x0a]
  - id: version
    type: u2
  - id: library_version
    type: u2
  - id: version_needed
    type: u2
    valid:
      min: 0x940
  - id: method
    type: u1
    enum: lzop_method
    valid:
      any-of:
        - lzop_method::lzo1x_1
        - lzop_method::lzo1x_1_15
        - lzop_method::lzo1x_999
        - lzop_method::zlib
    # other values are possible as well, but are not used in practice
  - id: level
    type: u1
    valid:
      max: 9
  - id: flags
    type: u4
  - id: filter
    type: u4
    if: flags & 0x800 != 0
  - id: mode
    type: u4
  - id: mtime
    type: u8
  - id: len_name
    type: u1
  - id: name
    size: len_name
    type: str
    encoding: UTF-8
  - id: checksum
    type: u4
    doc: CRC-32 or Adler-32
  - id: blocks
    type: block
    repeat: until
    repeat-until: _.len_decompressed == 0
instances:
  lzop_version:
    value: version & 0xf0
types:
  block:
    seq:
      - id: len_decompressed
        type: u4
      - id: block_type
        type:
          switch-on: len_decompressed
          cases:
            0: terminator
            _: regular_block
  terminator: {}
  regular_block:
    seq:
      - id: len_compressed
        type: u4
      - id: uncompressed_checksum
        type: u4
        if: _root.flags & 0x01 != 0 or _root.flags & 0x100 != 0
        doc: CRC-32 or Adler-32
      - id: compressed_checksum
        type: u4
        if: _root.flags & 0x02 != 0 or _root.flags & 0x200 != 0
        doc: CRC-32 or Adler-32
      - id: data
        size: len_compressed
enums:
  lzop_method:
    1: lzo1x_1
    2: lzo1x_1_15
    3: lzo1x_999
    128: zlib
