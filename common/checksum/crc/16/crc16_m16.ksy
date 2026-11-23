meta:
  id: crc16_m16
  title: M17 variant of CRC-16
  license: Unlicense
  imports:
    - ../crc_generic
  -initial: 0xffff
  -check: 0x772b
  -polynomial: 0x5935
  -reflect_in: false
  -reflect_out: false
doc: Computes M17 variant of 16 of an array.

params:
  - id: array
    type: bytes

instances:
  value:
    value: generic.value

seq:
  - id: generic
    type: crc_generic(16, 0xffff, 0x0, false, false, 0x5935, array)
