meta:
  id: bit_reflector_u2
  title: Changes order of bits within a word
  license: Unlicense
  imports:
    ./bit_reflector_u1

doc: |
  Changes order of bits within a word.

params:
  - id: needed
    type: bool
  - id: n
    type: u2
instances:
  value:
    value: |
      (needed
      ?
      (bit_reflector_0.value << 8) | (bit_reflector_1.value)
      :
      n
      )
  bit_reflector_0:
    pos: 0
    size: 0
    type: bit_reflector_u1(needed, n & 0xFF)
    if: needed
  bit_reflector_1:
    pos: 0
    size: 0
    type: bit_reflector_u1(needed, n >> 8)
    if: needed
