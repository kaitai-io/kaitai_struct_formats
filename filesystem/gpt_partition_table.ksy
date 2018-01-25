meta:
  id: gpt_partition_table
  endian: le
  # spec from https://en.wikipedia.org/wiki/GUID_Partition_Table
  # For now we only allow for 512 byte sectors.
  # For 4096 byte sectors, change 0x200 to 0x1000 in instances.primary.pos, instances.backup.pos and types.partition_header.instances.entries.pos 
instances:
  primary:
    io: _root._io
    pos: 0x200
    type: partition_header
  backup:
    io: _root._io
    pos: _io.size - 0x200
    type: partition_header
types:
  partition_entry:
    seq:
      - id: type_guid
        size: 0x10
      - id: guid
        size: 0x10
      - id: first_lba
        type: u8
      - id: last_lba
        type: u8
      - id: attributes
        type: u8
      - id: name
        type: str
        encoding: UTF-16LE
        size: 0x48
  partition_header:
    seq:
      - id: signature
        contents: [0x45, 0x46, 0x49, 0x20, 0x50, 0x41, 0x52, 0x54]
      - id: revision
        type: u4
      - id: header_size
        type: u4
      - id: crc32_header
        type: u4
      - id: reserved
        type: u4
      - id: current_lba
        type: u8
      - id: backup_lba
        type: u8
      - id: first_usable_lba
        type: u8
      - id: last_usable_lba
        type: u8
      - id: disk_guid
        size: 0x10
      - id: entries_start
        type: u8
      - id: entries_count
        type: u4
      - id: entries_size
        type: u4
      - id: crc32_array
        type: u4
      # We don't parse the trailing zeroed space
    instances:
      entries:
        io: _root._io
        pos: entries_start * 0x200
        size: entries_size
        type: partition_entry
        repeat: expr
        repeat-expr: entries_count

