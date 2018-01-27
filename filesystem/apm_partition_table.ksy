meta:
  id: apm_partition_table
  title: APM (Apple Partition Map) partition table
  license: CC0-1.0
  endian: be
  encoding: ascii
doc-ref: Specification taken from https://en.wikipedia.org/wiki/Apple_Partition_Map
instances:
  sector_size:
    value: 0x200
    doc: "APM only supports 0x200 (512) byte sectors."
  partition_lookup:
    io: _root._io
    pos: _root.sector_size
    type: partition_entry
    size: sector_size
    doc: |
      Every partition entry contains the number of partition entries.
      We parse the first entry, to know how many to parse, including the first one.
      No logic is given what to do if other entries have a different number.
  partition_entries:
    io: _root._io
    pos: _root.sector_size
    type: partition_entry
    size: sector_size
    repeat: expr
    repeat-expr: _root.partition_lookup.number_of_partitions
types:
  partition_entry:
    seq:
      - id: magic
        contents: [ 0x50, 0x4d ]
      - id: reserved_1
        size: 0x2
      - id: number_of_partitions
        type: u4
      - id: partition_start
        type: u4
        doc: "First sector"
      - id: partition_size
        type: u4
        doc: "Number of sectors"
      - id: partition_name
        type: strz
        size: 0x20
      - id: partition_type
        type: strz
        size: 0x20  
      - id: data_start
        type: u4
        doc: "First sector"
      - id: data_size
        type: u4
        doc: "Number of sectors"
      - id: partition_status
        type: u4
      - id: boot_code_start
        type: u4
        doc: "First sector"
      - id: boot_code_size
        type: u4
        doc: "Number of bytes"
      - id: boot_loader_address
        type: u4
        doc: "Address of bootloader code"
      - id: reserved_2
        size: 0x4
      - id: boot_code_entry
        type: u4
        doc: "Boot code entry point"
      - id: reserved_3
        size: 0x4
      - id: boot_code_cksum
        type: u4
        doc: "Boot code checksum"
      - id: processor_type
        type: strz
        size: 0x10
      # Skipping the remaining reserved block of 0x178 (376) bytes.

