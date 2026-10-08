meta:
  id: crc16_nrsc_5
  title: NRSC-5 variant of CRC-16
  license: Unlicense
  imports:
    - ../crc_generic
  -initial: 0xffff
  -check: 0xa066
  -polynomial: 0x80b
  -reflect_in: true
  -reflect_out: true
doc: Computes NRSC-5 variant of 16 of an array.

params:
  - id: array
    type: bytes

instances:
  value:
    value: generic.value

seq:
  - id: generic
    type: crc_generic(16, 0xffff, 0x0, true, true, 0x80b, array)
