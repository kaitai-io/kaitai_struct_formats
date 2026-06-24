meta:
  id: crc64_microsoft
  title: Microsoft variant of CRC-64
  license: Unlicense
  imports:
    - ../crc_generic
  -initial: 0xffffffffffffffff
  -check: 0x75d4b74f024eceea
  -polynomial: 0x259c84cba6426349
  -reflect_in: true
  -reflect_out: true
doc: Computes Microsoft variant of 64 of an array.

params:
  - id: array
    type: bytes

instances:
  value:
    value: generic.value

seq:
  - id: generic
    type: crc_generic(64, 0xffffffffffffffff, 0x0, true, true, 0x259c84cba6426349, array)
