meta:
  id: fletcher
  title: Computes Fletcher checksum of an array.
  license: Unlicense
  imports:
    - ./generalized_fletcher

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
  - id: data
    type: bytes
seq:
  - id: generalized_fletcher
    size: 0
    type: generalized_fletcher(byteness, 0, mask, block_size, data)

instances:
  block_size:
    doc: |
      Nakassis optimization: modular division not on every iteration.
      Maximum amount of iterations without modular division in pessimistic approach can be computed using

      from math import sqrt, floor
      def getMaxIterCountWithoutModulo(operandBitness: int, accumulatorBitness: int) -> int:
          b = (1 << operandBitness) - 1
          maxMask = (1 << accumulatorBitness) - 1
          return floor((b + sqrt(b*b + 8*b*maxMask))/(2*b) - 2)

      Here is the precomputed table:
      8 16 21
      8 32 5802
      16 32 360
      8 64 380368695
      16 64 23726745
      32 64 92680

    value: |
      (
        byteness == 4
      ?
        92680
      :
        (
          byteness == 2
        ?
          23726745
        :
          (
            byteness == 1
          ?
            380368695
          :
            0
          )
        )
      )

  mask:
    value: (1 << (byteness * 8))  - 1

  value:
    value: generalized_fletcher.value
