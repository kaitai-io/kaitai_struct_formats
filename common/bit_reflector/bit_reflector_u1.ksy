meta:
  id: bit_reflector_u1
  title: Changes order of bits within a byte
  license: Unlicense
doc: |
  Changes order of bits within a byte.

params:
  - id: needed
    type: bool
  - id: n
    type: u1
instances:
  value:
    value: |
      (needed
      ?
      (((n >> 0) & 1) << 7) | (((n >> 1) & 1) << 6) | (((n >> 2) & 1) << 5) | (((n >> 3) & 1) << 4) | (((n >> 4) & 1) << 3) | (((n >> 5) & 1) << 2) | (((n >> 6) & 1) << 1) | (((n >> 7) & 1) << 0)
      :
      n
      )
