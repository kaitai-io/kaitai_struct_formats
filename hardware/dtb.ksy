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
    - serialization
  license: CC0-1.0
  ks-version: 0.9
  encoding: ASCII
  endian: be
doc: |
  Also referred to as Devicetree Blob (DTB). It is a flat binary encoding
  of data (primarily devicetree data, although other data is possible as well).
  The data is internally stored as a tree of named nodes and properties. Nodes
  contain properties and child nodes, while properties are name-value pairs.

  The Devicetree Blobs (`.dtb` files) are compiled from the Devicetree Source
  files (`.dts`) through the Devicetree compiler (DTC).

  On Linux systems that support this, the blobs can be accessed in
  `/sys/firmware/fdt`:

  * <https://www.kernel.org/doc/Documentation/ABI/testing/sysfs-firmware-ofw>

  The encoding of strings used in the `strings_block` and `structure_block` is
  actually a subset of ASCII:

  <https://devicetree-specification.readthedocs.io/en/v0.3/devicetree-basics.html#node-names>

  Example files:

  * <https://github.com/qemu/qemu/tree/master/pc-bios>
doc-ref:
  - https://devicetree-specification.readthedocs.io/en/v0.3/flattened-format.html
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
  - id: min_compatible_version
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
    type: memory_block
  structure_block:
    pos: ofs_structure_block
    size: len_structure_block
    type: fdt_block
  strings_block:
    pos: ofs_strings_block
    size: len_strings_block
    type: strings
types:
  memory_block:
    seq:
      - id: entries
        type: memory_block_entry
        repeat: eos
  memory_block_entry:
    seq:
      - id: address
        type: u8
        doc: physical address of a reserved memory region
      - id: size
        type: u8
        doc: size of a reserved memory region
  fdt_block:
    seq:
      - id: nodes
        type: fdt_node
        repeat: until
        repeat-until: _.type == fdt::end
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
  fdt_begin_node:
    -webide-representation: '{name}'
    seq:
      - id: name
        type: strz
      - id: padding
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
      - id: padding
        size: (- _io.pos) % 4
    instances:
      name:
        io: _root.strings_block._io
        pos: ofs_name
        type: strz
        -webide-parse-mode: eager
  strings:
    seq:
      - id: strings
        type: strz
        repeat: eos
enums:
  fdt:
    0x00000001: begin_node
    0x00000002: end_node
    0x00000003: prop
    0x00000004: nop
    0x00000009: end
