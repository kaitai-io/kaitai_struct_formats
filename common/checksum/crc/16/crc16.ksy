meta:
  id: crc16
  title: CRC-16
  license: Unlicense
  imports:
    - ../crc_generic
  -initial: 0x0
  -check: 0x31c3
  -polynomial: 0x1021
  -reflect_in: false
  -reflect_out: false
doc: Computes CRC-16 of an array.

params:
  - id: array
    type: bytes

instances:
  value:
    value: generic.value

seq:
  - id: generic
    type: crc_generic(16, 0, 0x0, false, false, 0x1021, array)
