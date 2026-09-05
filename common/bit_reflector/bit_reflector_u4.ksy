meta:
  id: bit_reflector_u4
  title: Changes order of bits within a double word
  license: Unlicense
  imports:
    ./bit_reflector_u2

doc: |
  Changes order of bits within a double word.

params:
  - id: needed
    type: bool
  - id: n
    type: u4
instances:
  value:
    value: |
      (needed
      ?
      (bit_reflector_0.value << 16) | (bit_reflector_1.value)
      :
      n
      )
  bit_reflector_0:
    pos: 0
    size: 0
    type: bit_reflector_u2(needed, n & 0xFFFF)
    if: needed
  bit_reflector_1:
    pos: 0
    size: 0
    type: bit_reflector_u2(needed, n >> 16)
    if: needed
