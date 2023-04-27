meta:
  id: reolink
  title: Reolink firmware update
  license: GPL-3.0-only
  endian: le
  encoding: UTF-8
doc-ref:
  - https://github.com/hn/reolink-camera/blob/master/unpack-novatek-firmware.pl
seq:
  - id: header
    type: header
  - id: sections
    type: section
    repeat: expr
    repeat-expr: num_sections
  - id: partitions
    type: partition
    repeat: expr
    repeat-expr: num_sections
instances:
  first_section:
    pos: header._sizeof
    type: section
  num_sections:
    value: (first_section.ofs_section - header._sizeof) / (sizeof<section> + sizeof<partition>)
types:
  header:
    seq:
      - id: magic
        contents: [0x13, 0x59, 0x72, 0x32]
      - id: crc32
        size: 4
      - id: board
        size: 4
  section:
    seq:
      - id: name
        size: 32
        type: strz
      - id: version
        size: 24
      - id: ofs_section
        type: u4
      - id: len_section
        type: u4
    instances:
      section:
        io: _root._io
        pos: ofs_section
        size: len_section
  partition:
    seq:
      - id: name
        size: 32
        type: strz
      - id: ofs_partition
        type: u4
      - id: destination
        size: 32
        type: strz
      - id: unknown
        size: 4
      - id: len_partition
        type: u4
