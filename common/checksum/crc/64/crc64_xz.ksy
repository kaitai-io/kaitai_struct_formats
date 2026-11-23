meta:
  id: crc64_xz
  title: XZ variant of CRC-64
  license: Unlicense
  imports:
    - ../crc_generic
  -initial: 0xffffffffffffffff
  -check: 0x995dc9bbdf1939fa
  -polynomial: 0x42f0e1eba9ea3693
  -reflect_in: true
  -reflect_out: true
doc: Computes XZ variant of 64 of an array.

params:
  - id: array
    type: bytes

instances:
  value:
    value: generic.value

seq:
  - id: generic
    type: crc_generic(64, 0xffffffffffffffff, 0xffffffffffffffff, true, true, 0x42f0e1eba9ea3693, array)
