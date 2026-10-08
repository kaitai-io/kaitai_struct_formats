meta:
  id: crc16_x_25
  title: X-25 variant of CRC-16
  license: Unlicense
  imports:
    - ../crc_generic
  -initial: 0xffff
  -check: 0x906e
  -polynomial: 0x1021
  -reflect_in: true
  -reflect_out: true
doc: Computes X-25 variant of 16 of an array.

params:
  - id: array
    type: bytes

instances:
  value:
    value: generic.value

seq:
  - id: generic
    type: crc_generic(16, 0xffff, 0xffff, true, true, 0x1021, array)
