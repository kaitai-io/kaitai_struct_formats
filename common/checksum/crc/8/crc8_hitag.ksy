meta:
  id: crc8_hitag
  title: HITAG variant of CRC-8
  license: Unlicense
  imports:
    - ../crc_generic
  -initial: 0xff
  -check: 0xb4
  -polynomial: 0x1d
  -reflect_in: false
  -reflect_out: false
doc: Computes HITAG variant of 8 of an array.

params:
  - id: array
    type: bytes

instances:
  value:
    value: generic.value

seq:
  - id: generic
    type: crc_generic(8, 0xff, 0x0, false, false, 0x1d, array)
