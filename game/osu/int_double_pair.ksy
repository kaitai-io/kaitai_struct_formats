meta:
  id: int_double_pair
  endian: le
seq:
  - id: int_indicator
    contents: [ 0x08 ]
  - id: integer_value
    type: u4
  - id: double_indicator
    contents: [ 0x0d ]
  - id: double_value
    type: f8