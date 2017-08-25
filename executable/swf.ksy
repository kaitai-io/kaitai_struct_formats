meta:
  id: swf
  endian: le
seq:
  - id: junk
    size: 4
  - id: file_size
    type: u4
  - id: body
    size-eos: true
    process: zlib
    type: swf_body
types:
  swf_body:
    seq:
      - id: rect
        type: rect
      - id: frame_rate
        type: u2
      - id: frame_count
        type: u2
      - id: tags
        type: tag
        repeat: eos
  rect:
    seq:
      - id: b1
        type: u1
      - id: skip
        size: num_bytes
    instances:
      num_bits:
        value: b1 >> 3
      num_bytes:
        value: ((num_bits * 4 - 3) + 7) / 8
  tag:
    seq:
      - id: record_header
        type: record_header
      - id: tag_body
        size: record_header.len
        type:
          switch-on: record_header.tag_type
          cases:
            tag_type::abc_tag: abc_tag_body
  abc_tag_body:
    seq:
      - id: flags
        type: u4
      - id: name
        type: strz
        encoding: ASCII
      - id: abcdata
        size-eos: true
  record_header:
    seq:
      - id: tag_code_and_length
        type: u2
      - id: big_len
        type: s4
        if: small_len == 0x3f
    instances:
      tag_type:
        value: 'tag_code_and_length >> 6'
        enum: tag_type
      small_len:
        value: 'tag_code_and_length & 0b111111'
      len:
        value: 'small_len == 0x3f ? big_len : small_len'
enums:
  tag_type:
    69: file_attributes
    82: abc_tag
