meta:
  id: crc32_jamcrc
  title: JAMCRC variant of CRC-32
  license: Unlicense
  imports:
    - ../crc_generic
  -initial: 0xffffffff
  -check: 0x340bc6d9
  -polynomial: 0x4c11db7
  -reflect_in: true
  -reflect_out: true
doc: Computes JAMCRC variant of 32 of an array.

params:
  - id: array
    type: bytes

instances:
  value:
    value: generic.value

seq:
  - id: generic
    type: crc_generic(32, 0xffffffff, 0x0, true, true, 0x4c11db7, array)
