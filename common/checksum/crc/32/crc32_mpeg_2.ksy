meta:
  id: crc32_mpeg_2
  title: MPEG-2 variant of CRC-32
  license: Unlicense
  imports:
    - ../crc_generic
  -initial: 0xffffffff
  -check: 0x376e6e7
  -polynomial: 0x4c11db7
  -reflect_in: false
  -reflect_out: false
doc: Computes MPEG-2 variant of 32 of an array.

params:
  - id: array
    type: bytes

instances:
  value:
    value: generic.value

seq:
  - id: generic
    type: crc_generic(32, 0xffffffff, 0x0, false, false, 0x4c11db7, array)
