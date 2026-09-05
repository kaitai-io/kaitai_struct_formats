meta:
  id: selinux_policy_package
  title: SELinux policy package
  file-extension: pp
  license: CC0-1.0
  encoding: ASCII
  endian: le
doc: |
  This format is used to store together various policies files as sections.
  This format has no specification. The source of truth is the code of its library.
doc-ref: https://github.com/SELinuxProject/selinux/blob/820f019ed9e3b9a9e3e62ae378f99282990976a2/libsepol/src/module.c
seq:
  - id: magic
    contents: [0x8f, 0xff, 0x7c, 0xf9]
  - id: version  # module_package_read_offsets
    type: u4
  - id: num_sections
    -orig-id: nsec
    type: u4
  - id: sections
    type: section
    repeat: expr
    repeat-expr: num_sections

types:
  section:
    seq:
      - id: ofs_section
        -orig-id: off
        type: u4
    instances:
      section_magic:
        io: _root._io
        pos: ofs_section
        type: u4
        enum: section_magics

enums:
  section_magics:
    0xf97c_ff90:
      id: file_context
      -orig-id: fc
    0xf97c_ff8d: module
    0x097c_ff91: user
    0x097c_ff92: user_extra
    0x097c_ff93: netfilter
