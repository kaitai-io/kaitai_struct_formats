meta:
  id: vmware_vmdk
  endian: le
  title: VMWare Virtual Disk
  file-extension:
    - vmdk
  xref:
    wikidata: Q2658179
  license: CC0-1.0
doc-ref: 'https://github.com/libyal/libvmdk/blob/master/documentation/VMWare%20Virtual%20Disk%20Format%20(VMDK).asciidoc#41-file-header'
seq:
  - id: magic
    contents: "KDMV"
  - id: version
    type: s4
  - id: flags
    type: header_flags
  - id: size_max
    type: s8
    doc: Maximum number of sectors in a given image file (capacity)
  - id: size_grain
    type: s8
  - id: start_descriptor
    type: s8
    doc: Embedded descriptor file start sector number (0 if not available)
  - id: size_descriptor
    type: s8
    doc: Number of sectors that embedded descriptor file occupies
  - id: num_grain_table_entries
    type: s4
    doc: Number of grains table entries
  - id: start_secondary_grain
    type: s8
    doc: Secondary (backup) grain directory start sector number
  - id: start_primary_grain
    type: s8
    doc: Primary grain directory start sector number
  - id: size_metadata
    type: s8
  - id: is_dirty
    type: u1
  - id: stuff
    size: 4
  - id: compression_method
    type: u2
    enum: compression_methods
enums:
  compression_methods:
    0: none
    1: deflate
instances:
  len_sector:
    value: 0x200
  descriptor:
    pos: start_descriptor * _root.len_sector
    size: size_descriptor * _root.len_sector
  grain_primary:
    pos: start_primary_grain * _root.len_sector
    size: size_grain * _root.len_sector
  grain_secondary:
    pos: start_secondary_grain * _root.len_sector
    size: size_grain * _root.len_sector
types:
  header_flags:
    doc-ref: 'https://github.com/libyal/libvmdk/blob/master/documentation/VMWare%20Virtual%20Disk%20Format%20(VMDK).asciidoc#411-flags'
    seq:
      - id: reserved1
        type: b5
      - id: zeroed_grain_table_entry
        # 0x00000004
        type: b1
      - id: use_secondary_grain_dir
        # 0x00000002
        type: b1
      - id: valid_new_line_detection_test
        # 0x00000001
        type: b1
      - id: reserved2
        type: u1
      - id: reserved3
        type: b6
      - id: has_metadata
        # 0x00020000
        type: b1
      - id: has_compressed_grain
        # 0x00010000
        type: b1
      - id: reserved4
        type: u1
