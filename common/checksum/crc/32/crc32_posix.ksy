meta:
  id: crc32_posix
  title: POSIX variant of CRC-32
  license: Unlicense
  imports:
    - ../crc_generic
  -initial: 0x0
  -check: 0x765e7680
  -polynomial: 0x4c11db7
  -reflect_in: false
  -reflect_out: false
doc: Computes POSIX variant of 32 of an array.

params:
  - id: array
    type: bytes

instances:
  value:
    value: generic.value

seq:
  - id: generic
    type: crc_generic(32, 0, 0xffffffff, false, false, 0x4c11db7, array)
