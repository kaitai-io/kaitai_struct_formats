meta:
  id: amlogic_emmc_partitions
  title: Amlogic proprietary eMMC partition table
  license: CC0-1.0
  ks-version: 0.9
  encoding: UTF-8
  endian: le
  bit-endian: le

doc: |
  This is an unnamed and undocumented partition table format implemented by
  the bootloader and kernel that Amlogic provides for their Linux SoCs (Meson
  series at least, and probably others). They appear to use this rather than GPT,
  the industry standard, because their BootROM loads and executes the next stage
  loader from offset 512 (0x200) on the eMMC, which is exactly where the GPT
  header would have to start. So instead of changing their BootROM, Amlogic
  devised this partition table, which lives at an offset of 36MiB (0x240_0000)
  on the eMMC and so doesn't conflict. This parser expects as input just the
  partition table from that offset. The maximum number of partitions in a table
  is 32, which corresponds to a maximum table size of 1304 bytes (0x518).

doc-ref:
  - http://aml-code.amlogic.com/kernel/common.git/tree/include/linux/mmc/emmc_partitions.h?id=18a4a87072ababf76ea08c8539e939b5b8a440ef
  - http://aml-code.amlogic.com/kernel/common.git/tree/drivers/amlogic/mmc/emmc_partitions.c?id=18a4a87072ababf76ea08c8539e939b5b8a440ef

seq:
  - id: magic
    contents: ["MPT", 0]
  - id: version
    size: 12
    type: strz
  - id: num_partitions
    -orig-id: part_num
    type: s4
    valid:
      min: 1
      max: 32
  - id: checksum
    type: u4
    doc: |
      To calculate this, treat the first (and only the first) partition
      descriptor in the table below as an array of unsigned little-endian
      32-bit integers. Sum all those integers mod 2^32, then multiply the
      result by the total number of partitions, also mod 2^32. Amlogic
      likely meant to include all the partition descriptors in the sum,
      but their code as written instead repeatedly loops over the first
      one, once for each partition in the table.
  - id: partitions
    type: partition
    repeat: expr
    repeat-expr: num_partitions

types:
  partition:
    seq:
      - id: name
        size: 16
        type: strz
      - id: size
        type: u8
      - id: offset
        type: u8
        doc: |
          The start of the partition relative to the start of the eMMC, in bytes
      - id: flags
        size: 4
        type: part_flags
      - id: padding
        size: 4

    types:
      part_flags:
        seq:
          - id: is_code
            -orig-id: STORE_CODE
            type: b1
          - id: is_cache
            -orig-id: STORE_CACHE
            type: b1
          - id: is_data
            -orig-id: STORE_DATA
            type: b1
