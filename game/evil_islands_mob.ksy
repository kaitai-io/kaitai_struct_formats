meta:
  id: evil_islands_mob
  title: Evil Islands, MOB file (map entities)
  application: Evil Islands
  file-extension: mob
  license: MIT
  endian: le
doc: Map entities tree
doc-ref: https://github.com/aspadm/EIrepack/wiki/mob
seq:
  - id: root_node
    type: node
    doc: Root node
types:
  node:
    doc: Entity node
    seq:
      - id: type_id
        type: u4
        doc: Children type ID
      - id: size
        type: u4
        doc: Node full size
      - id: data
        type: node_data
        size: size - 8
        doc: Stored data
  node_data:
    doc: Node data
    seq:
      - id: value
        type:
          switch-on: _parent.type_id
          cases:
            0xA000: node
            0x00001E00: node
            0x00001E01: node
            0x00001E02: node
            0x00001E03: node
            0x00001E0B: node
            0x00001E0E: node
            0x0000A000: node
            0x0000AA01: node
            0x0000ABD0: node
            0x0000B000: node
            0x0000B001: node
            0x0000CC01: node
            0x0000DD01: node
            0x0000E000: node
            0x0000E001: node
            0x0000F000: node
            0x0000FF00: node
            0x0000FF01: node
            0x0000FF02: node
            0xBBAB0000: node
            0xBBAC0000: node
            0xBBBB0000: node
            0xBBBC0000: node
            0xBBBD0000: node
            0xBBBE0000: node
            0xBBBF0000: node
            0xDDDDDDD1: node
            _: u1
        repeat: eos
