meta:
  id: crc16_opensafety_a
  title: OPENSAFETY-A variant of CRC-16
  license: Unlicense
  imports:
    - ../crc_generic
  -initial: 0x0
  -check: 0x5d38
  -polynomial: 0x5935
  -reflect_in: false
  -reflect_out: false
doc: Computes OPENSAFETY-A variant of 16 of an array.

params:
  - id: array
    type: bytes

instances:
  value:
    value: generic.value

seq:
  - id: generic
    type: crc_generic(16, 0, 0x0, false, false, 0x5935, array)
