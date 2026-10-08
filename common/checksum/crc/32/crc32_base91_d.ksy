meta:
  id: crc32_base91_d
  title: BASE91-D variant of CRC-32
  license: Unlicense
  imports:
    - ../crc_generic
  -initial: 0xffffffff
  -check: 0x87315576
  -polynomial: 0xa833982b
  -reflect_in: true
  -reflect_out: true
doc: Computes BASE91-D variant of 32 of an array.

params:
  - id: array
    type: bytes

instances:
  value:
    value: generic.value

seq:
  - id: generic
    type: crc_generic(32, 0xffffffff, 0xffffffff, true, true, 0xa833982b, array)
