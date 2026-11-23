meta:
  id: crc16_dds_110
  title: DDS-110 variant of CRC-16
  license: Unlicense
  imports:
    - ../crc_generic
  -initial: 0x800d
  -check: 0x9ecf
  -polynomial: 0x8005
  -reflect_in: false
  -reflect_out: false
doc: Computes DDS-110 variant of 16 of an array.

params:
  - id: array
    type: bytes

instances:
  value:
    value: generic.value

seq:
  - id: generic
    type: crc_generic(16, 0x800d, 0x0, false, false, 0x8005, array)
