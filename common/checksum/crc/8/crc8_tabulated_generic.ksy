meta:
  id: crc8_tabulated_generic
  title: Computes CRC-8 checksum of an array.
  license: Unlicense
  imports:
    - /common/bit_reflector/bit_reflector_u1

doc: |
  Computes CRC-8 of an array.

params:
  - id: initial
    type: u1
  - id: xor_output
    type: u1
  - id: reflect_input
    type: bool
  - id: reflect_output
    type: bool
  - id: table
    type: bytes
  - id: array
    type: bytes

instances:
  reduction:
    pos: 0
    type: iteration(_index)
    repeat: expr
    repeat-expr: array.length
  reflected_output_if_needed:
    pos: 0
    size: 0
    type: bit_reflector_u1(reflect_output, reduction[array.length - 1].res)
  value:
    value: reflected_output_if_needed.value ^ xor_output
types:
  iteration:
    params:
      - id: idx
        type: u1
    instances:
      n:
        pos: 0
        size: 0
        type: bit_reflector_u1(_parent.reflect_input, _parent.array[idx])
      prev:
        value: 'idx == 0 ? _parent.initial : (_parent.reduction[idx - 1].as<iteration>.res).as<u1>'
      res:
        value: _parent.table[(prev ^ n.value) & 0xFF]
