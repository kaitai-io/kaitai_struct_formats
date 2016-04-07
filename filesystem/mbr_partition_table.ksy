meta:
  id: mbr_partition_table
  endian: le
seq:
  - id: bootstrap_code
    size: 0x1be
  - id: partitions
    type: partition_entry
    repeat: expr
    repeat-expr: 4
  - id: boot_signature
    contents: [0x55, 0xaa]
types:
  partition_entry:
    seq:
      - id: status
        type: u1
      - id: chs_start
        type: chs
      - id: partition_type
        type: u1
      - id: chs_end
        type: chs
      - id: lba_start
        type: u4
      - id: num_sectors
        type: u4
  chs:
    seq:
      - id: head
        type: u1
      - id: b2
        type: u1
      - id: b3
        type: u1
    instances:
      sector:
        value: 'b2 & 0b111111'
      cylinder:
        value: 'b3 + ((b2 & 0b11000000) << 2)'
