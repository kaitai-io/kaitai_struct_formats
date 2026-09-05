meta:
  id: crc16_gsm
  title: GSM variant of CRC-16
  license: Unlicense
  imports:
    - ../crc_generic
  -initial: 0x0
  -check: 0xce3c
  -polynomial: 0x1021
  -reflect_in: false
  -reflect_out: false
doc: Computes GSM variant of 16 of an array.

params:
  - id: array
    type: bytes

instances:
  value:
    value: generic.value

seq:
  - id: generic
    type: crc_generic(16, 0, 0xffff, false, false, 0x1021, array)
