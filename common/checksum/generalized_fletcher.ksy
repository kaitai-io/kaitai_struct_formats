meta:
  id: generalized_fletcher
  title: Computes Fletcher (and variants like Adler32) checksum of an array.
  license: Unlicense

doc: |
  Computes Fletcher checksum of an array.

  assert fletcher16(b"abcde") == 0xC8F0
  assert fletcher16(b"abcdef") == 0x2057
  assert fletcher16(b"abcdefgh") == 0x0627

  assert fletcher32(b"abcde") == 0xF04FC729
  assert fletcher32(b"abcdef") == 0x56502D2A
  assert fletcher32(b"abcdefgh") == 0xEBE19591

  assert fletcher64(b"abcde") == 0xC8C6C527646362C6
  assert fletcher64(b"abcdef") == 0xC8C72B276463C8C6

params:
  - id: byteness
    type: u1
  - id: c0_init
    type: u1
  - id: modulus
    type: u8
  - id: block_size
    type: u8
    doc: |
      Nakassis optimization: modular division not on every iteration.
      Maximum amount of iterations without modular division in pessimistic approach can be computed using

      from math import sqrt, floor

      def getMaxIterCountWithoutModulo(b: int = 0xFFFFFFFF, a: int = 0, accumulatorBitness: int) -> int:
        b = 65521
        maxMask = (1 << accumulatorBitness) - 1
        return floor((-2*a + b + sqrt(4*a**2 - 4*a*b + b**2 + 8*b*maxMask))/(2*b) - 2)
  - id: data
    type: bytes

instances:
  bitness:
    value: byteness * 8
  mask:
    value: (1 << bitness)  - 1
  full_blocks:
    value: data.size / block_size
  first_block_size:
    value: data.size % block_size
  reduction:
    pos: 0
    size: 0
    type: fletcher_inner(_index)
    repeat: expr
    repeat-expr: 1 + full_blocks

  value:
    value: reduction[reduction.size - 1].c1_inner << bitness | reduction[reduction.size - 1].c0_inner

types:
  fletcher_inner:
    params:
      - id: idx
        type: u8
    instances:
      prev:
        value: _parent.reduction[idx - 1].as<fletcher_inner>
        if: idx != 0
      count:
        value: (idx == 0?_root.first_block_size:_root.block_size)
      base_offset:
        value: (idx == 0?0:prev.base_offset.as<u8> + prev.count.as<u8>).as<u8>
      reduction:
        pos: 0
        size: 0
        type: iteration(_index)
        repeat: expr
        repeat-expr: count
      init_c0:
        value: "(idx == 0 ? _root.c0_init : prev.c0_inner).as<u8>"
      init_c1:
        value: "(idx == 0 ? 0 : prev.c1_inner).as<u8>"
      c0_inner:
        value: "(count != 0 ? (reduction[reduction.size - 1].c0_iter % _root.mask) : init_c0).as<u8>"
      c1_inner:
        value: "(count != 0 ? (reduction[reduction.size - 1].c1_iter % _root.mask) : init_c1).as<u8>"
    types:
      iteration:
        params:
          - id: idx
            type: u8
        instances:
          prev_c0_iter:
            value: 'idx == 0 ? _parent.init_c0 : (_parent.reduction[idx - 1].as<iteration>.c0_iter).as<u8>'
          prev_c1_iter:
            value: 'idx == 0 ? _parent.init_c1 : (_parent.reduction[idx - 1].as<iteration>.c1_iter).as<u8>'
          c0_iter:
            value: prev_c0_iter + _parent._parent.data[_parent.base_offset + idx]
          c1_iter:
            value: prev_c1_iter + c0_iter
