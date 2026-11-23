meta:
  id: crc16_dect_r
  title: DECT-R variant of CRC-16
  license: Unlicense
  imports:
    - ../crc_generic
  -initial: 0x0
  -check: 0x7e
  -polynomial: 0x589
  -reflect_in: false
  -reflect_out: false
doc: Computes DECT-R variant of 16 of an array.

params:
  - id: array
    type: bytes

instances:
  value:
    value: generic.value

seq:
  - id: generic
    type: crc_generic(16, 0, 0x1, false, false, 0x589, array)
