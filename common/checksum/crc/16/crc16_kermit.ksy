meta:
  id: crc16_kermit
  title: Kermit variant of CRC-16
  license: Unlicense
  imports:
    - ../crc_generic
  -initial: 0x0
  -check: 0x2189
  -polynomial: 0x1021
  -reflect_in: true
  -reflect_out: true
doc: Computes Kermit variant of 16 of an array.

params:
  - id: array
    type: bytes

instances:
  value:
    value: generic.value

seq:
  - id: generic
    type: crc_generic(16, 0, 0x0, true, true, 0x1021, array)
