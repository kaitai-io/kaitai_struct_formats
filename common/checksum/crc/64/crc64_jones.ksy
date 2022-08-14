meta:
  id: crc64_jones
  title: Jones variant of CRC-64
  license: Unlicense
  imports:
    - ../crc_generic
  -initial: 0x0
  -check: 0xe9c6d914c4b8d9ca
  -polynomial: 0xad93d23594c935a9
  -reflect_in: true
  -reflect_out: true
doc: Computes Jones variant of 64 of an array.

params:
  - id: array
    type: bytes

instances:
  value:
    value: generic.value

seq:
  - id: generic
    type: crc_generic(64, 0, 0x0, true, true, 0xad93d23594c935a9, array)
