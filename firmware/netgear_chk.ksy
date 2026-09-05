meta:
  id: netgear_chk
  title: Netgear chk
  license: GPL-2.0-or-later
  endian: be
  encoding: UTF-8
doc-ref:
  - https://lxr.openwrt.org/source/firmware-utils/src/mkchkimg.c
  - https://github.com/onekey-sec/unblob/blob/5d9fd6d8/unblob/handlers/archive/netgear/chk.py
seq:
  - id: header
    type: header
  - id: kernel
    size: header.rest_of_header.len_kernel
  - id: rootfs
    size: header.rest_of_header.len_rootfs
types:
  header:
    seq:
      - id: magic
        contents: [0x2a, 0x23, 0x24, 0x5e]
      - id: len_header
        type: u4
      - id: rest_of_header
        type: rest_of_header
        size: len_header - len_header._sizeof - magic._sizeof
  rest_of_header:
    seq:
      - id: region_code
        type: u1
        enum: region_codes
      - id: reserved
        size: 7
      - id: kernel_checksum
        type: u4
      - id: rootfs_checksum
        type: u4
      - id: len_kernel
        type: u4
      - id: len_rootfs
        type: u4
      - id: image_checksum
        type: u4
      - id: header_checksum
        type: u4
      - id: board_id
        size-eos: true
        type: str
enums:
  region_codes:
    1: worldwide
    2: north_america
