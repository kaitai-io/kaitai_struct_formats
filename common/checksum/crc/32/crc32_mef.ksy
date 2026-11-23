meta:
  id: crc32_mef
  title: MEF variant of CRC-32
  license: Unlicense
  imports:
    - ../crc_generic
  -initial: 0xffffffff
  -check: 0xd2c22f51
  -polynomial: 0x741b8cd7
  -reflect_in: true
  -reflect_out: true
doc: Computes MEF variant of 32 of an array.

params:
  - id: array
    type: bytes

instances:
  value:
    value: generic.value

seq:
  - id: generic
    type: crc_generic(32, 0xffffffff, 0x0, true, true, 0x741b8cd7, array)
