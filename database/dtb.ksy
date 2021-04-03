meta:
  id: dtb
  title: Flattened Devicetree Format
  file-extension: dtb
  license: CC0-1.0
  endian: be
doc: |
  Also referred to as Devicetree Blob (DTB). It is a flat
  binary encoding of data (primarily devicetree data, although
  other data is possible as well).
doc-ref:
  - https://github.com/devicetree-org/devicetree-specification/releases/tag/v0.3
  - https://github.com/devicetree-org/devicetree-specification/blob/ba2aa679679fc4fedf67130f18a6f0ecc4cf0382/source/flattened-format.rst
  - https://elinux.org/images/f/f4/Elc2013_Fernandes.pdf
seq:
  - id: magic
    contents: [0xd0, 0x0d, 0xfe, 0xed]
  - id: total_size
    type: u4
  - id: structure_block_offset
    type: u4
  - id: strings_block_offset
    type: u4
  - id: memory_reservation_block_offset
    type: u4
  - id: version
    type: u4
  - id: last_compatible_version
    type: u4
    valid:
      max: version
  - id: boot_cpuid_phys
    type: u4
  - id: size_dt_strings
    type: u4
  - id: size_dt_struct
    type: u4
instances:
  memory_reservation_block:
    pos: memory_reservation_block_offset
    size: structure_block_offset - memory_reservation_block_offset
  structure_block:
    pos: structure_block_offset
    size: strings_block_offset - structure_block_offset
    type: fdt_block
  strings_block:
    pos: strings_block_offset
    size: size_dt_strings
    type: strings
types:
  strings:
    seq:
      - id: strings
        type: strz
        encoding: ASCII
        repeat: eos
  fdt_node:
    seq:
      - id: token_type
        type: u4
        enum: fdt
      - id: fdt_node_body
        type:
          switch-on: token_type
          cases:
            fdt::begin_node: fdt_begin_node
            fdt::prop: fdt_prop
  fdt_block:
    seq:
      - id: fdt_nodes
        type: fdt_node
        repeat: until
        repeat-until: _.token_type == fdt::end
  fdt_begin_node:
    seq:
      - id: name
        type: strz
        encoding: ASCII
      - id: boundary_padding
        size: (- _io.pos) % 4
  fdt_prop:
    seq:
      - id: length
        type: u4
      - id: name_offset
        type: u4
      - id: property
        size: length
      - id: boundary_padding
        size: (- _io.pos) % 4
enums:
  fdt:
    0x00000001: begin_node
    0x00000002: end_node
    0x00000003: prop
    0x00000004: nop
    0x00000009: end
