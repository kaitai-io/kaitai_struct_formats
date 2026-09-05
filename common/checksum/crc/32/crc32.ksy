meta:
  id: crc32
  title: CRC-32
  license: Unlicense
  imports:
    - ../crc_generic
  -initial: 0xffffffff
  -check: 0xcbf43926
  -polynomial: 0x4c11db7
  -reflect_in: true
  -reflect_out: true
doc: Computes CRC-32 of an array.

params:
  - id: array
    type: bytes

instances:
  value:
    value: generic.value

seq:
  - id: generic
    type: crc_generic(32, 0xffffffff, 0xffffffff, true, true, 0x4c11db7, array)
