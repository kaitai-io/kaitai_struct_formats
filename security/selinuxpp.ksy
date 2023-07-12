meta:
  id: selinux
  title: SELinux file policy package binary
  file-extension: pp
  license: CC0-1.0
  encoding: ASCII
  endian: le
doc-ref: |
  https://github.com/SELinuxProject/selinux/blob/master/libsepol/src/module.c
seq:
  - id: magic
    contents: [0x8f, 0xff, 0x7c, 0xf9]
  - id: version  # module_package_read_offsets
    type: u4
  - id: sections_count
    -orig-id: nsec
    type: u4
  - id: section
    type: section
    repeat: expr
    repeat-expr: sections_count

types:
  section:
    seq:
    - id: offset
      -orig-id: off
      type: u4
    instances:
      section_magic:
        type: u4
        enum: section_magics
        io: _root._io
        pos: offset

enums:
  section_magics:
    0xf97cff90: file_context # -orig-id: fc
    0xf97cff8d: module
    0x097cff91: user
    0x097cff92: user_extra
    0x097cff93: netfilter
