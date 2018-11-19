meta:
  id: cdb
  file-extension: cdb
  endian: le
  encoding: ASCII
  license: CC0-1.0
doc-ref: https://cr.yp.to/cdb/cdb.txt
seq:
  - id: pointers
    type: pointer
    repeat: expr
    repeat-expr: 256
  - id: records
    type: record
    repeat: until
    repeat-until: _io.pos == pointers[0].pointer_position
  - id: hash_tables
    type: hash_table(_index)
    repeat: expr
    repeat-expr: 256
types:
  pointer:
    seq:
      - id: pointer_position
        type: u4le
      - id: pointer_length
        type: u4le
  record:
    seq:
      - id: record_key_length
        type: u4le
      - id: record_value_length
        type: u4le
      - id: record_key
        type: str
        size: record_key_length
      - id: record_value
        type: str
        size: record_value_length
  hash_table:
    params:
      - id: idx
        type: u4
    seq:
      - id: hash_slots
        type: hash_slot
        repeat: expr
        repeat-expr: _root.pointers[idx].pointer_length
  hash_slot:
    seq:
      - id: slot_key
        type: u4le
      - id: slot_length
        type: u4le
