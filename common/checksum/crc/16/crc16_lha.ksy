meta:
  id: crc16_lha
  title: ARC variant of CRC-16
  license: Unlicense
  imports:
    - ../crc_generic
  -initial: 0x0
  -check: 0xbb3d
  -polynomial: 0x8005
  -reflect_in: true
  -reflect_out: true
doc: Computes ARC variant of 16 of an array.

params:
  - id: array
    type: bytes

instances:
  value:
    value: generic.value

seq:
  - id: generic
    type: crc_generic(16, 0, 0x0, true, true, 0x8005, array)
