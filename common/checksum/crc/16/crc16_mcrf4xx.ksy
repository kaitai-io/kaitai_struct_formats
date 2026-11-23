meta:
  id: crc16_mcrf4xx
  title: MCRF4XX variant of CRC-16
  license: Unlicense
  imports:
    - ../crc_generic
  -initial: 0xffff
  -check: 0x6f91
  -polynomial: 0x1021
  -reflect_in: true
  -reflect_out: true
doc: Computes MCRF4XX variant of 16 of an array.

params:
  - id: array
    type: bytes

instances:
  value:
    value: generic.value

seq:
  - id: generic
    type: crc_generic(16, 0xffff, 0x0, true, true, 0x1021, array)
