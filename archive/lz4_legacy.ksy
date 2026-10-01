meta:
  id: lz4_legacy
  title: LZ4 legacy format
  license: CC0-1.0
  endian: le
  encoding: ASCII
doc-ref: https://github.com/lz4/lz4/blob/master/doc/lz4_Frame_format.md#legacy-frame
seq:
  - id: magic
    type: u4
    valid: 0x184c2102
  - id: blocks
    type: block
    repeat: until
    repeat-until: _io.eof or _.is_magic
    # This is ugly, as it eats some extra bytes, so an external
    # program processing this could should take this into account
types:
  block:
    seq:
      - id: len_data
        type: u4
      - id: data
        size: len_data
        if: not is_magic
    instances:
      is_magic:
        value: len_data == 0x184c2102
