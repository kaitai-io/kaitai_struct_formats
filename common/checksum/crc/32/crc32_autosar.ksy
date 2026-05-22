meta:
  id: crc32_autosar
  title: AUTOSAR variant of CRC-32
  license: Unlicense
  imports:
    - ../crc_generic
  -initial: 0xffffffff
  -check: 0x1697d06a
  -polynomial: 0xf4acfb13
  -reflect_in: true
  -reflect_out: true
doc: Computes AUTOSAR variant of 32 of an array.

params:
  - id: array
    type: bytes

instances:
  value:
    value: generic.value

seq:
  - id: generic
    type: crc_generic(32, 0xffffffff, 0xffffffff, true, true, 0xf4acfb13, array)
