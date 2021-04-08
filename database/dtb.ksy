meta:
  id: dtb
  title: Flattened Devicetree Format
  file-extension: dtb
  application:
    - Linux
    - Das U-Boot
  xref:
    wikidata: Q16960371
  tags:
    - linux
  license: CC0-1.0
  ks-version: 0.9
  encoding: ASCII
  endian: be
doc: |
  Also referred to as Devicetree Blob (DTB). It is a flat
  binary encoding of data (primarily devicetree data, although
  other data is possible as well).

  On Linux systems that support this the blobs can be accessed in
  `/sys/firmware/fdt`:

  - <https://www.kernel.org/doc/Documentation/ABI/testing/sysfs-firmware-ofw>

  The encoding of strings used in the strings block and struct block is
  actually a subset of ASCII:

  <https://github.com/devicetree-org/devicetree-specification/blob/v0.3/source/devicetree-basics.rst>

  Example files:

  - <https://github.com/qemu/qemu/tree/master/pc-bios>
doc-ref:
  - https://github.com/devicetree-org/devicetree-specification/releases/tag/v0.3
  - https://github.com/devicetree-org/devicetree-specification/blob/ba2aa67/source/flattened-format.rst
  - https://elinux.org/images/f/f4/Elc2013_Fernandes.pdf
seq:
  - id: magic
    -orig-id: magic
    contents: [0xd0, 0x0d, 0xfe, 0xed]
  - id: total_size
    -orig-id: totalsize
    type: u4
  - id: ofs_structure_block
    -orig-id: off_dt_struct
    type: u4
  - id: ofs_strings_block
    -orig-id: off_dt_strings
    type: u4
  - id: ofs_memory_reservation_block
    -orig-id: off_mem_rsvmap
    type: u4
  - id: version
    type: u4
  - id: last_compatible_version
    -orig-id: last_comp_version
    type: u4
    valid:
      max: version
  - id: boot_cpuid_phys
    -orig-id: boot_cpuid_phys
    type: u4
  - id: len_strings_block
    -orig-id: size_dt_strings
    type: u4
  - id: len_structure_block
    -orig-id: size_dt_struct
    type: u4
instances:
  memory_reservation_block:
    pos: ofs_memory_reservation_block
    size: ofs_structure_block - ofs_memory_reservation_block
  structure_block:
    pos: ofs_structure_block
    size: len_structure_block
    type: fdt_block
  strings_block:
    pos: ofs_strings_block
    size: len_strings_block
    type: strings
types:
  strings:
    seq:
      - id: strings
        type: strz
        repeat: eos
  fdt_node:
    -webide-representation: '{type} {body}'
    seq:
      - id: type
        type: u4
        enum: fdt
      - id: body
        type:
          switch-on: type
          cases:
            fdt::begin_node: fdt_begin_node
            fdt::prop: fdt_prop
  fdt_block:
    seq:
      - id: fdt_nodes
        type: fdt_node
        repeat: until
        repeat-until: _.type == fdt::end
  fdt_begin_node:
    seq:
      - id: name
        type: strz
      - id: boundary_padding
        size: (- _io.pos) % 4
  fdt_prop:
    -webide-representation: '{name}'
    seq:
      - id: len_property
        -orig-id: len
        type: u4
      - id: ofs_name
        -orig-id: nameoff
        type: u4
      - id: property
        size: len_property
      - id: boundary_padding
        size: (- _io.pos) % 4
    instances:
      name:
        io: _root.strings_block._io
        pos: ofs_name
        type: strz
        -webide-parse-mode: eager
enums:
  fdt:
    0x00000001: begin_node
    0x00000002: end_node
    0x00000003: prop
    0x00000004: nop
    0x00000009: end
