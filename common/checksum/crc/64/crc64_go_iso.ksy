meta:
  id: crc64_go_iso
  title: GO-ISO variant of CRC-64
  license: Unlicense
  imports:
    - ../crc_generic
  -initial: 0xffffffffffffffff
  -check: 0xb90956c775a41001
  -polynomial: 0x1b
  -reflect_in: true
  -reflect_out: true
doc: Computes GO-ISO variant of 64 of an array.

params:
  - id: array
    type: bytes

instances:
  value:
    value: generic.value

seq:
  - id: generic
    type: crc_generic(64, 0xffffffffffffffff, 0xffffffffffffffff, true, true, 0x1b, array)
