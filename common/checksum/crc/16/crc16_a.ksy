meta:
  id: crc16_a
  title: A variant of CRC-16
  license: Unlicense
  imports:
    - ../crc_generic
  -initial: 0xc6c6
  -check: 0xbf05
  -polynomial: 0x1021
  -reflect_in: true
  -reflect_out: true
doc: Computes A variant of 16 of an array.

params:
  - id: array
    type: bytes

instances:
  value:
    value: generic.value

seq:
  - id: generic
    type: crc_generic(16, 0xc6c6, 0x0, true, true, 0x1021, array)
