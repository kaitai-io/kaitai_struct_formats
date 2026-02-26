meta:
  id: snappy
  title: snappy framing format
  license: CC0-1.0
  ks-version: 0.9
  encoding: utf-8
  endian: le
doc-ref: https://github.com/google/snappy/blob/master/framing_format.txt
doc: |
  snappy's framing2 format
  
  Test files can be created with snzip: <https://github.com/kubo/snzip>
seq:
  - id: chunks
    type: chunk
    repeat: until
    repeat-until: _io.eof or not _.is_valid
    # This is ugly, as it eats one extra byte, so an external
    # program processing this could should take this into account
types:
  chunk:
    seq:
      - id: identifier
        type: u1
        enum: chunk_types
      - id: body
        type: chunk_body
        if: is_valid
    instances:
        # more values are actually allowed but in practice
        # these aren't encountered
        is_valid:
          value: identifier == chunk_types::compressed or
            identifier == chunk_types::uncompressed or
            identifier == chunk_types::padding or
            identifier == chunk_types::stream_identifier
  chunk_body:
    seq:
      - id: len_chunk
        type: int3
      - id: data
        size: len_chunk.value
  int3:
    seq:
      - id: lower
        type: u2
      - id: higher
        type: u1
    instances:
      value:
        value: higher * 65536 + lower
enums:
  chunk_types:
    0x00: compressed
    0x01: uncompressed
    0xfe: padding
    0xff: stream_identifier
