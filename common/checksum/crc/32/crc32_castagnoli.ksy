meta:
  id: crc32_castagnoli
  title: Castagnoli variant of CRC-32
  license: Unlicense
  imports:
    - ../crc_generic
  -initial: 0xffffffff
  -check: 0xe3069283
  -polynomial: 0x1edc6f41
  -reflect_in: true
  -reflect_out: true
doc: Computes Castagnoli variant of 32 of an array.

params:
  - id: array
    type: bytes

instances:
  value:
    value: generic.value

seq:
  - id: generic
    type: crc_generic(32, 0xffffffff, 0xffffffff, true, true, 0x1edc6f41, array)
