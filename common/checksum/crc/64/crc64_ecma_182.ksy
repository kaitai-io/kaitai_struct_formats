meta:
  id: crc64_ecma_182
  title: ECMA-182 variant of CRC-64
  license: Unlicense
  imports:
    - ../crc_generic
  -initial: 0x0
  -check: 0x6c40df5f0b497347
  -polynomial: 0x42f0e1eba9ea3693
  -reflect_in: false
  -reflect_out: false
doc: Computes ECMA-182 variant of 64 of an array.

params:
  - id: array
    type: bytes

instances:
  value:
    value: generic.value

seq:
  - id: generic
    type: crc_generic(64, 0, 0x0, false, false, 0x42f0e1eba9ea3693, array)
