meta:
  id: crc_gen_table
  title: Computes CRC-8 table for a polynomial.
  license: Unlicense

doc: |
  Computes CRC table for a polynomial.

params:
  - id: bit_length
    type: u1
  - id: polynomial
    type: u8

instances:
  mask:
    value: (1 << bit_length) - 1
  highest_bit_mask:
    value: 1 << (bit_length - 1)

  table:
    pos: 0
    type: transform(_index)
    repeat: expr
    repeat-expr: 1 << bit_length

types:
  transform:
    params:
      - id: input
        type: u8
    instances:
      reduction:
        pos: 0
        type: iteration(_index)
        repeat: expr
        repeat-expr: 8
      value:
        value: reduction[reduction.size - 1].res & _root.mask
    types:
      iteration:
        params:
          - id: idx
            type: u8
        instances:
          prev:
            value: 'idx == 0 ? _parent.input : (_parent.reduction[idx - 1].as<iteration>.res).as<u8>'
          shifted:
            value: prev << 1
          res:
            value: "(prev & _root.highest_bit_mask != 0 ? (shifted ^ _root.polynomial) : shifted).as<u8>"
