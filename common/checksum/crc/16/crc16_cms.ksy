meta:
  id: crc16_cms
  title: CMS variant of CRC-16
  license: Unlicense
  imports:
    - ../crc_generic
  -initial: 0xffff
  -check: 0xaee7
  -polynomial: 0x8005
  -reflect_in: false
  -reflect_out: false
doc: Computes CMS variant of 16 of an array.

params:
  - id: array
    type: bytes

instances:
  value:
    value: generic.value

seq:
  - id: generic
    type: crc_generic(16, 0xffff, 0x0, false, false, 0x8005, array)
