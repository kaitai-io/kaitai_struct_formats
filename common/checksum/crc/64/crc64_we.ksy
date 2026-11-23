meta:
  id: crc64_we
  title: WE variant of CRC-64
  license: Unlicense
  imports:
    - ../crc_generic
  -initial: 0xffffffffffffffff
  -check: 0x62ec59e3f1a4f00a
  -polynomial: 0x42f0e1eba9ea3693
  -reflect_in: false
  -reflect_out: false
doc: Computes WE variant of 64 of an array.

params:
  - id: array
    type: bytes

instances:
  value:
    value: generic.value

seq:
  - id: generic
    type: crc_generic(64, 0xffffffffffffffff, 0xffffffffffffffff, false, false, 0x42f0e1eba9ea3693, array)
