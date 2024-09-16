meta:
  id: crc16_riello
  title: RIELLO variant of CRC-16
  license: Unlicense
  imports:
    - ../crc_generic
  -initial: 0xb2aa
  -check: 0x63d0
  -polynomial: 0x1021
  -reflect_in: true
  -reflect_out: true
doc: Computes RIELLO variant of 16 of an array.

params:
  - id: array
    type: bytes

instances:
  value:
    value: generic.value

seq:
  - id: generic
    type: crc_generic(16, 0xb2aa, 0x0, true, true, 0x1021, array)
