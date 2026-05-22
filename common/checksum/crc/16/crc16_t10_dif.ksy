meta:
  id: crc16_t10_dif
  title: T10-DIF variant of CRC-16
  license: Unlicense
  imports:
    - ../crc_generic
  -initial: 0x0
  -check: 0xd0db
  -polynomial: 0x8bb7
  -reflect_in: false
  -reflect_out: false
doc: Computes T10-DIF variant of 16 of an array.

params:
  - id: array
    type: bytes

instances:
  value:
    value: generic.value

seq:
  - id: generic
    type: crc_generic(16, 0, 0x0, false, false, 0x8bb7, array)
