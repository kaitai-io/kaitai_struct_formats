meta:
  id: crc32_dect_b
  title: BZIP2 variant of CRC-32
  license: Unlicense
  imports:
    - ../crc_generic
  -initial: 0xffffffff
  -check: 0xfc891918
  -polynomial: 0x4c11db7
  -reflect_in: false
  -reflect_out: false
doc: Computes BZIP2 variant of 32 of an array.

params:
  - id: array
    type: bytes

instances:
  value:
    value: generic.value

seq:
  - id: generic
    type: crc_generic(32, 0xffffffff, 0xffffffff, false, false, 0x4c11db7, array)
