meta:
  id: bit_reflector_u8
  title: Changes order of bits within a quad word
  license: Unlicense
  imports:
    ./bit_reflector_u4

doc: |
  Changes order of bits within a double word.

params:
  - id: needed
    type: bool
  - id: n
    type: u8
instances:
  value:
    value: |
      (needed
      ?
      (bit_reflector_0.value << 32) | (bit_reflector_1.value)
      :
      n
      )
  bit_reflector_0:
    pos: 0
    size: 0
    type: bit_reflector_u4(needed, n & 0xFFFFFFFF)
    if: needed
  bit_reflector_1:
    pos: 0
    size: 0
    type: bit_reflector_u4(needed, n >> 32)
    if: needed
