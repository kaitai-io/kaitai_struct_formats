meta:
  id: android_super
  title: Android Dynamic Partitions metadata
  application: Android
  file-extension: img
  tags:
    - android
    - filesystem
  license: CC0-1.0
  ks-version: 0.9
  bit-endian: le
  endian: le

doc: |
  The metadata stored by Android at the beginning of a "super" partition, which
  is what it calls a disk partition that holds one or more Dynamic Partitions.
  Dynamic Partitions do more or less the same thing that LVM does on Linux,
  allowing Android to map ranges of non-contiguous extents to a single logical
  device. This metadata holds that mapping.

doc-ref:
  - https://source.android.com/devices/tech/ota/dynamic_partitions
  - https://android.googlesource.com/platform/system/core/+/refs/tags/android-11.0.0_r8/fs_mgr/liblp/include/liblp/metadata_format.h

instances:
  root:
    pos: 0x1000
    type: root

types:
  root:
    seq:
      - id: primary_geometry
        size: 0x1000
        type: geometry

      - id: backup_geometry
        type: geometry
        size: 0x1000

      - id: primary_metadata
        size: primary_geometry.metadata_max_size
        type: metadata
        repeat: expr
        repeat-expr: primary_geometry.metadata_slot_count

      - id: backup_metadata
        # These attributes are intentionally taken from primary_geometry, even
        # for backup_metadata. The first non-corrupt geometry specifier dictates
        # the layout of both primary and backup metadata.
        size: primary_geometry.metadata_max_size
        type: metadata
        repeat: expr
        repeat-expr: primary_geometry.metadata_slot_count

  geometry:
    seq:
      - id: magic
        contents: 'gDla'
      - id: struct_size
        type: u4
      - id: checksum
        size: 32
        doc: |
          SHA-256 hash of struct_size bytes from beginning of geometry,
          calculated as if checksum were zeroed out
      - id: metadata_max_size
        type: u4
      - id: metadata_slot_count
        type: u4
      - id: logical_block_size
        type: u4

  metadata:
    seq:
      - id: magic
        contents: '0PLA'
      - id: major_version
        type: u2
      - id: minor_version
        type: u2
      - id: header_size
        type: u4
      - id: header_checksum
        size: 32
        doc: |
          SHA-256 hash of header_size bytes from beginning of metadata,
          calculated as if header_checksum were zeroed out
      - id: tables_size
        type: u4
      - id: tables_checksum
        size: 32
        doc: SHA-256 hash of tables_size bytes from end of header
      - id: partitions
        type: table_descriptor(table_kind::partitions)
      - id: extents
        type: table_descriptor(table_kind::extents)
      - id: groups
        type: table_descriptor(table_kind::groups)
      - id: block_devices
        type: table_descriptor(table_kind::block_devices)

    enums:
      table_kind:
        0: partitions
        1: extents
        2: groups
        3: block_devices

    types:
      table_descriptor:
        params:
          - id: kind
            type: u1
            enum: table_kind
            -affected-by: 135

        seq:
          - id: offset
            type: u4
          - id: num_entries
            type: u4
          - id: entry_size
            type: u4

        instances:
          table:
            pos: _parent.header_size + offset
            size: entry_size
            type:
              switch-on: kind
              cases:
                'table_kind::partitions': partition
                'table_kind::extents': extent
                'table_kind::groups': group
                'table_kind::block_devices': block_device
            repeat: expr
            repeat-expr: num_entries

      partition:
        seq:
          - id: name
            size: 36
            type: strz
            encoding: UTF-8
          - id: attr_readonly
            type: b1
          - id: attr_slot_suffixed
            type: b1
          - id: attr_updated
            type: b1
          - id: attr_disabled
            type: b1
          - id: attrs_reserved
            type: b28
          - id: first_extent_index
            type: u4
          - id: num_extents
            type: u4
          - id: group_index
            type: u4

      extent:
        seq:
          - id: num_sectors
            type: u8
          - id: target_type
            type: u4
            enum: target_type
          - id: target_data
            type: u8
          - id: target_source
            type: u4

        enums:
          target_type:
            0: linear
            1: zero

      group:
        seq:
          - id: name
            size: 36
            type: strz
            encoding: UTF-8
          - id: flag_slot_suffixed
            type: b1
          - id: flags_reserved
            type: b31
          - id: maximum_size
            type: u8

      block_device:
        seq:
          - id: first_logical_sector
            type: u8
          - id: alignment
            type: u4
          - id: alignment_offset
            type: u4
          - id: size
            type: u8
          - id: partition_name
            size: 36
            type: strz
            encoding: UTF-8
          - id: flag_slot_suffixed
            type: b1
          - id: flags_reserved
            type: b31
