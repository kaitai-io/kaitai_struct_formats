meta:
  id: adler32
  title: Computes Adler32 checksum of an array.
  license: Unlicense
  imports:
    - ./generalized_fletcher

doc: |
  Computes Adler32 checksum of an array.

  assert adler32(b"abcde") == 96993776
  assert adler32(b"abcdef") == 136184406
  assert adler32(b"abcdefgh") == 234881829

params:
  - id: data
    type: bytes
seq:
  - id: generalized_fletcher
    size: 0
    type: generalized_fletcher(2, 1, 65521, 23729280, data)

instances:
  value:
    value: generalized_fletcher.value
