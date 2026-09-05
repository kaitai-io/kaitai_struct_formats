meta:
  id: crc16_genibus
  title: GENIBUS variant of CRC-16
  license: Unlicense
  imports:
    - ../crc_generic
  -initial: 0xffff
  -check: 0xd64e
  -polynomial: 0x1021
  -reflect_in: false
  -reflect_out: false
doc: Computes GENIBUS variant of 16 of an array.

params:
  - id: array
    type: bytes

instances:
  value:
    value: generic.value

seq:
  - id: generic
    type: crc_generic(16, 0xffff, 0xffff, false, false, 0x1021, array)
