meta:
  id: reolink
  title: Reolink firmware update
  license: MIT
  endian: le
  encoding: UTF-8
doc-ref:
  - https://github.com/vmallet/pakler/blob/acbf084b/pakler/__init__.py
seq:
  - id: header
    type:
      switch-on: is_64
      cases:
        true: header64
        false: header32
  - id: sections
    type:
      switch-on: is_64
      cases:
        false: section32
        true: section64
    repeat: expr
    repeat-expr: num_sections
  - id: partitions
    type: partition
    repeat: expr
    repeat-expr: num_sections
instances:
  header_crc32:
    pos: 4
    type: u4
  is_64:
    value: header_crc32 == 0
  num_sections:
    value: header.as<header32>.num_sections
types:
  header32:
    seq:
      - id: magic
        contents: [0x13, 0x59, 0x72, 0x32]
      - id: crc32
        type: u4
      - id: board
        size: 4
    instances:
      first_section:
        io: _root._io
        pos: sizeof<header32>
        type: section32
      num_sections:
        value: (first_section.ofs_section - sizeof<header32>) / (sizeof<section32> + sizeof<partition>)
  header64:
    seq:
      - id: magic
        contents: [0x13, 0x59, 0x72, 0x32, 0x00, 0x00, 0x00, 0x00]
      - id: crc32
        type: u8
      - id: board
        size: 8
    instances:
      first_section:
        io: _root._io
        pos: sizeof<header64>
        type: section64
      num_sections:
        value: (first_section.ofs_section - sizeof<header64>) / (sizeof<section64> + sizeof<partition>)
  section32:
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
  section64:
    seq:
      - id: name
        size: 32
        type: strz
      - id: version
        size: 24
      - id: ofs_section
        type: u8
      - id: len_section
        type: u8
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
      - id: mtd
        size: 32
        type: strz
      - id: start_address
        size: 4
      - id: len_partition
        type: u4
