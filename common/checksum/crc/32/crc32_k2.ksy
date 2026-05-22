meta:
  id: crc32_k2
  title: Koopman 2 variant of CRC-32
  license: Unlicense
  imports:
    - ../crc_generic
  -initial: 0x0
  -check: 0x6425c10
  -polynomial: 0x32583499
  -reflect_in: true
  -reflect_out: true
doc: Computes Koopman 2 variant of 32 of an array.

params:
  - id: array
    type: bytes

instances:
  value:
    value: generic.value

seq:
  - id: generic
    type: crc_generic(32, 0, 0x0, true, true, 0x32583499, array)
