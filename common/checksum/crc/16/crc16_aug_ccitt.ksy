meta:
  id: crc16_aug_ccitt
  title: AUG-CCITT variant of CRC-16
  license: Unlicense
  imports:
    - ../crc_generic
  -initial: 0x1d0f
  -check: 0xe5cc
  -polynomial: 0x1021
  -reflect_in: false
  -reflect_out: false
doc: Computes AUG-CCITT variant of 16 of an array.

params:
  - id: array
    type: bytes

instances:
  value:
    value: generic.value

seq:
  - id: generic
    type: crc_generic(16, 0x1d0f, 0x0, false, false, 0x1021, array)
