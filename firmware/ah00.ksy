meta:
  id: ah00
  license: MIT
  encoding: ascii
  endian: be
doc-ref: |
  - https://reverseengineering.stackexchange.com/questions/4565/format-of-chk-firmware-package-on-wgr614v7
  - https://www.0xf8.org/2009/07/hacking-the-netgear-wg102-access-point/
seq:
  - id: magic
    contents: 'AH00'
  - id: timestamp
    type: u4
  - id: len_data
    type: u4
  - id: md5
    size: 16
  - id: unknown_1
    size: 2
  - id: len_name
    type: u2
  - id: name
    size: len_name
    type: strz
  - id: data
    size: len_data
