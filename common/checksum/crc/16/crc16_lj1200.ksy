meta:
  id: crc16_lj1200
  title: LJ1200 variant of CRC-16
  license: Unlicense
  imports:
    - ../crc_generic
  -initial: 0x0
  -check: 0xbdf4
  -polynomial: 0x6f63
  -reflect_in: false
  -reflect_out: false
doc: Computes LJ1200 variant of 16 of an array.

params:
  - id: array
    type: bytes

instances:
  value:
    value: generic.value

seq:
  - id: generic
    type: crc_generic(16, 0, 0x0, false, false, 0x6f63, array)
