meta:
  id: qua
  file-extension: qua
  endian: le
  title: Avira Antivirus quarantine file parser
  license: CC-BY-SA-4.0
  ks-version: 0.9
doc: |
  Creator: Florian Bausch, ERNW Research GmbH, https://ernw-research.de
  License: CC-BY-SA-4.0 https://creativecommons.org/licenses/by-sa/4.0/
seq:
  - id: magic
    size: 16
    contents: ["AntiVir Qua", 0x00, 0x00, 0x00, 0x00, 0x00]
  - id: malicious_offset
    type: u4
  - id: len_filename
    type: u4
  - id: len_addl_info
    type: u4
  - id: unknown1
    size: 0x20
  - id: qua_time
    type: u4
  - id: unknown2
    size: 0x5c
  - id: mal_type
    type: str
    terminator: 0
    encoding: UTF-8
    size: 0x40
  - id: filename
    type: str
    encoding: UTF-16LE
    size: 'len_filename < 2 ? len_filename : len_filename - 2'
  - id: padding1
    size: 2
    contents: [0x00, 0x00]
    if: 'len_filename >= 2'
  - id: addl_info
    type: str
    encoding: UTF-16LE
    size: 'len_addl_info < 2 ? len_addl_info : len_addl_info - 2'
  - id: padding2
    size: 2
    contents: [0x00, 0x00]
    if: 'len_addl_info >= 2'
  - id: mal_file
    process: xor(0xaa)
    size-eos: true
