meta:
  id: crc16_modbus
  title: Modbus variant of CRC-16
  license: Unlicense
  imports:
    - ../crc_generic
  -initial: 0xffff
  -check: 0x4b37
  -polynomial: 0x8005
  -reflect_in: true
  -reflect_out: true
doc: Computes Modbus variant of 16 of an array.

params:
  - id: array
    type: bytes

instances:
  value:
    value: generic.value

seq:
  - id: generic
    type: crc_generic(16, 0xffff, 0x0, true, true, 0x8005, array)
