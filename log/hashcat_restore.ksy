meta:
  id: hashcat_restore
  title: Hashcat Restore file
  file-extension: restore
  license: CC0-1.0
  endian: le
doc-ref: https://hashcat.net/wiki/doku.php?id=restore
seq:
  - id: version
    type: u4
  - id: cwd
    type: strz
    size: 256
    encoding: UTF-8
  - id: dicts_pos
    type: u4
  - id: masks_pos
    type: u4
  - id: padding
    size: 4
  - id: current_restore_point
    type: u8
  - id: argc
    type: u4
  - id: padding2
    size: 12
  - id: argv
    type: strz
    encoding: UTF-8
    terminator: 0x0A
    repeat: expr
    repeat-expr: argc
