meta:
  id: crc_tabulated_generic
  title: Computes CRC checksum of an array.
  license: Unlicense
  imports:
    - /common/bit_reflector/bit_reflector_u8
    - /common/bit_reflector/bit_reflector_u1

doc: |
  Computes CRC checksum of an array. Uses a precomputed table for substitution.

params:
  - id: bit_length
    type: u1
  - id: initial
    type: u8
  - id: xor_output
    type: u8
  - id: reflect_input
    type: bool
  - id: reflect_output
    type: bool
  - id: table
    type: bytes
  - id: array
    type: bytes

instances:
  mask:
    value: (1 << bit_length) - 1
  highest_bit_mask:
    value: 1 << (bit_length - 1)
  iter_shift:
    value: bit_length - 8
  reduction:
    pos: 0
    type: iteration(_index)
    repeat: expr
    repeat-expr: array.length
  reflected_output_if_needed:
    pos: 0
    size: 0
    type: bit_reflector_generic(reflect_output, reduction[array.length - 1].res)
  value:
    value: reflected_output_if_needed.value^ xor_output
types:
  bit_reflector_generic:
    params:
      - id: needed
        type: bool
      - id: n
        type: u8
    instances:
      r:
        pos: 0
        size: 0
        type: bit_reflector_u8(needed, n)
        if: needed
      value:
        value: "(needed?r.value >> (64 - _root.bit_length):n)"

  iteration:
    params:
      - id: idx
        type: u8
    instances:
      n:
        pos: 0
        size: 0
        type: bit_reflector_u1(_parent.reflect_input, _parent.array[idx])
      prev:
        value: 'idx == 0 ? _parent.initial : (_parent.reduction[idx - 1].as<iteration>.res).as<u8>'
      res:
        value: "_root.table[(prev ^ (n.value << _root.iter_shift)) & _root.mask]"
