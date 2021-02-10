meta:
  id: samsung_pit
  title: Samsung Partition Information Table
  license: CC0-1.0
  file-extension: pit
  endian: le
  imports:
    - /common/samsung_signature

doc: |
  Reversed format of partition information table used in
  samsung decices.

doc-ref: https://gitlab.com/BenjaminDobell/Heimdall/-/tree/master/libpit/source

seq:
  - id: magic
    contents: [ 0x76, 0x98, 0x34, 0x12 ]
  - id: num_entries
    type: u4
  - id: port
    type: str
    size: 4
    encoding: ASCII
  - id: format
    type: str
    size: 4
    encoding: ASCII
  - id: chip
    type: str
    size: 8
    encoding: ASCII
  - id: unknown4
    type: u4
  - id: partitions
    type: partition
    repeat: expr
    repeat-expr: num_entries
  - id: signature
    type: samsung_signature
    if: not _io.eof

types:
  attributes:
    seq:
      - id: value
        type: u4
    instances:
      read:
        value: true
      write:
        value: (value & 1) == 0x1
      stl:
        value: (value & (1 << 1)) == 0x2
  update_attributes:
    seq:
      - id: value
        type: u4
    instances:
      fota:
        value: (value & 1) == 0x1
      secure:
        value: (value & (1 << 1)) == 0x2
  partition:
    seq:
      - id: binary_type
        type: u4
        enum: binary_type
      - id: device_type
        type: u4
        enum: device_type
      - id: identifier
        type: u4
      - id: attributes
        type: attributes
      - id: update_attributes
        type: update_attributes
      - id: len_or_ofs_block
        type: u4
        doc: partition len or partition offset from a disk beginning
      - id: num_blocks
        type: u4
        doc: partition size in blocks
      - id: ofs_file
        type: u4
        doc: obsolete
      - id: len_file
        type: u4
        doc: obsolete
      - id: partition_name
        type: strz
        size: 32
        encoding: ASCII
      - id: flash_filename
        type: strz
        size: 32
        encoding: ASCII
      - id: fota_filename
        type: strz
        size: 32
        encoding: ASCII

enums:
  binary_type:
    0: ap
    1: cp
  device_type:
    0: onenand
    1: filefat
    2: mmc
    3: all
