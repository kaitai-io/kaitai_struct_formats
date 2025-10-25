meta:
  id: crc16_cdma2000
  title: CDMA2000 variant of CRC-16
  license: Unlicense
  imports:
    - ../crc_generic
  -initial: 0xffff
  -check: 0x4c06
  -polynomial: 0xc867
  -reflect_in: false
  -reflect_out: false
doc: Computes CDMA2000 variant of 16 of an array.

params:
  - id: array
    type: bytes

instances:
  value:
    value: generic.value

seq:
  - id: generic
    type: crc_generic(16, 0xffff, 0x0, false, false, 0xc867, array)
