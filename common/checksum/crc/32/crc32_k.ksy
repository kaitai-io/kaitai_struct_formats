meta:
  id: crc32_k
  title: Koopman variant of CRC-32
  license: Unlicense
  imports:
    - ../crc_generic
  -initial: 0xffffffff
  -check: 0x2d3dd0ae
  -polynomial: 0x741b8cd7
  -reflect_in: true
  -reflect_out: true
doc: Computes Koopman variant of 32 of an array.

params:
  - id: array
    type: bytes

instances:
  value:
    value: generic.value

seq:
  - id: generic
    type: crc_generic(32, 0xffffffff, 0xffffffff, true, true, 0x741b8cd7, array)
