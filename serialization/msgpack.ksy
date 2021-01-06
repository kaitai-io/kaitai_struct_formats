meta:
  id: msgpack
  title: MessagePack (msgpack) serialization format
  xref:
    wikidata: Q6821738
  license: CC0-1.0
  endian: be
doc: |
  MessagePack (msgpack) is a system to serialize arbitrary structured
  data into a compact binary stream.
doc-ref: https://github.com/msgpack/msgpack/blob/master/spec.md
seq:
  - id: b1
    type: u1
    doc: |
      First byte is msgpack message is either a piece of data by
      itself or determines types of further, more complex data
      structures.
  # ========================================================================
  - id: int_extra
    type:
      switch-on: b1
      cases:
        0xcc: u1
        0xcd: u2
        0xce: u4
        0xcf: u8
        0xd0: s1
        0xd1: s2
        0xd2: s4
        0xd3: s8
  # ========================================================================
  - id: float_32_value
    type: f4
    if: is_float_32
  - id: float_64_value
    type: f8
    if: is_float_64
  # ========================================================================
  - id: str_len_8
    type: u1
    if: is_str_8
  - id: str_len_16
    type: u2
    if: is_str_16
  - id: str_len_32
    type: u4
    if: is_str_32
  - id: str_value
    type: str
    encoding: UTF-8
    size: str_len
    if: is_str
  # ========================================================================
  - id: num_array_elements_16
    type: u2
    if: is_array_16
  - id: num_array_elements_32
    type: u4
    if: is_array_32
  - id: array_elements
    type: msgpack
    repeat: expr
    repeat-expr: num_array_elements
    if: is_array
  # ========================================================================
  - id: num_map_elements_16
    type: u2
    if: is_map_16
  - id: num_map_elements_32
    type: u4
    if: is_map_32
  - id: map_elements
    type: map_tuple
    repeat: expr
    repeat-expr: num_map_elements
    if: is_map
instances:
#  value:
#    value: >-
#      is_bool ? bool_value :
#      is_int ? int_value :
#      is_array ? array_elements :
#      0
  is_nil:
    value: b1 == 0xc0
    doc-ref: 'https://github.com/msgpack/msgpack/blob/master/spec.md#formats-nil'
  # ========================================================================
  is_bool:
    value: b1 == 0xc2 or b1 == 0xc3
  bool_value:
    value: b1 == 0xc3
    if: is_bool
    doc-ref: 'https://github.com/msgpack/msgpack/blob/master/spec.md#formats-bool'
  # ========================================================================
  is_pos_int7:
    value: b1 & 0b1000_0000 == 0
  pos_int7_value:
    value: b1
    if: is_pos_int7
  is_neg_int5:
    value: b1 & 0b111_00000 == 0b111_00000
  neg_int5_value:
    value: -(b1 & 0b000_11111)
    if: is_neg_int5
  is_int:
    value: is_pos_int7 or is_neg_int5
  int_value:
    value: >-
      is_pos_int7 ? pos_int7_value :
      is_neg_int5 ? neg_int5_value :
      0x1337
    if: is_int
  # ========================================================================
  is_float_32:
    value: b1 == 0xca
    doc-ref: 'https://github.com/msgpack/msgpack/blob/master/spec.md#formats-float'
  is_float_64:
    value: b1 == 0xcb
    doc-ref: 'https://github.com/msgpack/msgpack/blob/master/spec.md#formats-float'
  is_float:
    value: is_float_32 or is_float_64
  float_value:
    value: >-
      is_float_32 ? float_32_value : float_64_value
    if: is_float
  # ========================================================================
  is_fix_str:
    value: b1 & 0b111_00000 == 0b101_00000
    doc-ref: 'https://github.com/msgpack/msgpack/blob/master/spec.md#formats-str'
  is_str_8:
    value: b1 == 0xd9
    doc-ref: 'https://github.com/msgpack/msgpack/blob/master/spec.md#formats-str'
  is_str_16:
    value: b1 == 0xda
    doc-ref: 'https://github.com/msgpack/msgpack/blob/master/spec.md#formats-str'
  is_str_32:
    value: b1 == 0xdb
    doc-ref: 'https://github.com/msgpack/msgpack/blob/master/spec.md#formats-str'
  is_str:
    value: is_fix_str or is_str_8 or is_str_16 or is_str_32
  str_len:
    value: >-
      is_fix_str ? (b1 & 0b000_11111) :
      is_str_8 ? str_len_8 :
      is_str_16 ? str_len_16 :
      str_len_32
    if: is_str
  # ========================================================================
  is_array:
    value: is_fix_array or is_array_16 or is_array_32
    doc-ref: 'https://github.com/msgpack/msgpack/blob/master/spec.md#formats-array'
  is_fix_array:
    value: b1 & 0b1111_0000 == 0b1001_0000
    doc-ref: 'https://github.com/msgpack/msgpack/blob/master/spec.md#formats-array'
  is_array_16:
    value: b1 == 0xdc
    doc-ref: 'https://github.com/msgpack/msgpack/blob/master/spec.md#formats-array'
  is_array_32:
    value: b1 == 0xdd
    doc-ref: 'https://github.com/msgpack/msgpack/blob/master/spec.md#formats-array'
  num_array_elements:
    value: >-
      is_fix_array ? b1 & 0b0000_1111 :
      is_array_16 ? num_array_elements_16 :
      num_array_elements_32
    if: is_array
    doc-ref: 'https://github.com/msgpack/msgpack/blob/master/spec.md#formats-array'
  # ========================================================================
  is_map:
    value: is_fix_map or is_map_16 or is_map_32
    doc-ref: 'https://github.com/msgpack/msgpack/blob/master/spec.md#formats-map'
  is_fix_map:
    value: b1 & 0b1111_0000 == 0b1000_0000
    doc-ref: 'https://github.com/msgpack/msgpack/blob/master/spec.md#formats-map'
  is_map_16:
    value: b1 == 0xde
    doc-ref: 'https://github.com/msgpack/msgpack/blob/master/spec.md#formats-map'
  is_map_32:
    value: b1 == 0xdf
    doc-ref: 'https://github.com/msgpack/msgpack/blob/master/spec.md#formats-map'
  num_map_elements:
    value: >-
      is_fix_map ? b1 & 0b0000_1111 :
      is_map_16 ? num_map_elements_16 :
      num_map_elements_32
    if: is_map
    doc-ref: 'https://github.com/msgpack/msgpack/blob/master/spec.md#formats-map'
types:
  map_tuple:
    seq:
      - id: key
        type: msgpack
      - id: value
        type: msgpack
