meta:
  id: crc16_ibm3740
  title: IBM-3740 variant of CRC-16
  license: Unlicense
  imports:
    - ../crc_generic
  -initial: 0xffff
  -check: 0x29b1
  -polynomial: 0x1021
  -reflect_in: false
  -reflect_out: false
doc: Computes IBM-3740 variant of 16 of an array.

params:
  - id: array
    type: bytes

instances:
  value:
    value: generic.value

seq:
  - id: generic
    type: crc_generic(16, 0xffff, 0x0, false, false, 0x1021, array)
