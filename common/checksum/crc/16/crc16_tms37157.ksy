meta:
  id: crc16_tms37157
  title: TMS37157 variant of CRC-16
  license: Unlicense
  imports:
    - ../crc_generic
  -initial: 0x89ec
  -check: 0x26b1
  -polynomial: 0x1021
  -reflect_in: true
  -reflect_out: true
doc: Computes TMS37157 variant of 16 of an array.

params:
  - id: array
    type: bytes

instances:
  value:
    value: generic.value

seq:
  - id: generic
    type: crc_generic(16, 0x89ec, 0x0, true, true, 0x1021, array)
