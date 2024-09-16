meta:
  id: crc32_cd_rom_edc
  title: CD-ROM-EDC variant of CRC-32
  license: Unlicense
  imports:
    - ../crc_generic
  -initial: 0x0
  -check: 0x6ec2edc4
  -polynomial: 0x8001801b
  -reflect_in: true
  -reflect_out: true
doc: Computes CD-ROM-EDC variant of 32 of an array.

params:
  - id: array
    type: bytes

instances:
  value:
    value: generic.value

seq:
  - id: generic
    type: crc_generic(32, 0, 0x0, true, true, 0x8001801b, array)
