meta:
  id: pvz_main_pak
  application: Plants vs. Zombies
  file-extension: pak
  endian: le
  license: CC0-1.0
  encoding: ASCII
doc-ref: https://plantsvszombies.fandom.com/wiki/Modify_Plants_vs._Zombies
doc: |
  Before parse, use 0xF7 to xor decrypt.
  After file_entry, the following is file contents without any gap.

  https://github.com/Freed-Wu/pvz.nvim provides tools to (de)serialize it.
seq:
  - id: magic
    type: u8
    valid: 0xBAC04AC0
  - id: files
    type: file_entry
    repeat: until
    repeat-until: _.mark != 0x00
types:
  file_entry:
    seq:
      - id: mark
        type: u1
      - id: len_name
        type: u1
        if: mark == 0x00
      - id: name
        type: str
        size: len_name
        if: mark == 0x00
      - id: size
        type: u4
        if: mark == 0x00
      - id: timestamp
        type: u8
        if: mark == 0x00
