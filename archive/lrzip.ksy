meta:
  id: lrzip
  title: lrzip 0.6
  file-extension: lrz
  license: CC0-1.0
  endian: le
doc-ref: https://github.com/ckolivas/lrzip/blob/master/doc/magic.header.txt
seq:
  - id: header
    type: header
    size: 24
  - id: rchunks
    type: rchunk
    repeat: until
    repeat-until: _.last_chunk
    if: not header.is_encrypted
types:
  header:
    seq:
      - id: signature
        contents: ['LRZI']
      - id: version
        type: version
      - id: len_file_or_salt
        type: u8
      - id: unused_1
        size: 2
      - id: lzma_properties
        type: lzma_properties
      - id: md5sum_flag
        type: u1
      - id: encryption_flag
        type: u1
      - id: unused_2
        size: 1
    instances:
      has_md5:
        value: md5sum_flag & 0x01 == 1
      is_encrypted:
        value: encryption_flag & 0x01 == 1
  lzma_properties:
    seq:
      - id: lc
        type: u1
      - id: lp
        type: u1
      - id: pb
        type: u1
      - id: fb
        type: u1
      - id: len_dictionary
        type: u1
  version:
    seq:
      - id: major
        type: u1
        valid: 0
      - id: minor
        type: u1
        valid: 6
  rchunk:
    seq:
      - id: byte_width
        type: u1
        valid:
          min: 1
          max: 4
      - id: eof_flag
        type: u1
      - id: len_uncompressed
        type:
          switch-on: byte_width
          cases:
            1: u1
            2: u2
            3: b24le
            4: u4
            8: u8
      - id: stream_0
        type: stream_header_data(byte_width, _io.pos)
      - id: stream_1
        type: stream_header_data(byte_width, _io.pos - stream_0.size)
        # oh, what an ugly hack...
    instances:
      last_chunk:
        value: eof_flag == 1
  stream_header_data:
    params:
      - id: byte_width
        type: u1
      - id: start_position
        type: u4
    seq:
      - id: compressed_data_type
        type: u1
        enum: compression
        valid:
          any-of:
            - compression::no_compression
            - compression::bzip2
            - compression::lzo
            - compression::lzma
            - compression::gzip
            - compression::zpaq
      - id: len_data
        type:
          switch-on: byte_width
          cases:
            1: u1
            2: u2
            3: b24le
            4: u4
            8: u8
      - id: len_uncompressed_data
        type:
          switch-on: byte_width
          cases:
            1: u1
            2: u2
            3: b24le
            4: u4
            8: u8
      - id: next_block_head
        type:
          switch-on: byte_width
          cases:
            1: u1
            2: u2
            3: b24le
            4: u4
            8: u8
      - id: data
        size: len_data
    instances:
      size:
        value: 1 + 3 * byte_width
      next:
        pos: next_block_head + start_position
        io: _root._io
        type: stream_header_data(byte_width, start_position)
        if: next_block_head != 0
enums:
  compression:
    3: no_compression
    4: bzip2
    5: lzo
    6: lzma
    7: gzip
    8: zpaq
