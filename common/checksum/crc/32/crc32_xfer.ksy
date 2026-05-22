meta:
  id: crc32_xfer
  title: XFER variant of CRC-32
  license: Unlicense
  imports:
    - ../crc_generic
  -initial: 0x0
  -check: 0xbd0be338
  -polynomial: 0xaf
  -reflect_in: false
  -reflect_out: false
doc: Computes XFER variant of 32 of an array.

params:
  - id: array
    type: bytes

instances:
  value:
    value: generic.value

seq:
  - id: generic
    type: crc_generic(32, 0, 0x0, false, false, 0xaf, array)
