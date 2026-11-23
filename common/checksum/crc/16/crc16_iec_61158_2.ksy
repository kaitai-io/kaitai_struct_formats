meta:
  id: crc16_iec_61158_2
  title: PROFIBUS, IEC-61158-2 variant of CRC-16
  license: Unlicense
  imports:
    - ../crc_generic
  -initial: 0xffff
  -check: 0xa819
  -polynomial: 0x1dcf
  -reflect_in: false
  -reflect_out: false
doc: Computes PROFIBUS, IEC-61158-2 variant of 16 of an array.

params:
  - id: array
    type: bytes

instances:
  value:
    value: generic.value

seq:
  - id: generic
    type: crc_generic(16, 0xffff, 0xffff, false, false, 0x1dcf, array)
