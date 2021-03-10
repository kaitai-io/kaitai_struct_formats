meta:
  id: android_dto
  title: Android DTB/DTBO Partition
  license: CC0-1.0
  file-extension: img
  endian: be

doc: |
  Format for Android DTB/DTBO partitions. It's kind of archive with
  dtb/dtbo files. Used only when there is a separate unique partition
  (dtb, dtbo) on an android device to organize device tree files.
  The format consists of a header with info about size and number
  of device tree entries and the entries themselves. This format
  description could be used to extract device tree entries from a
  partition images and decompile them with dtc (device tree compiler).

doc-ref:
  - https://source.android.com/devices/architecture/dto/partitions
  - https://android.googlesource.com/platform/system/libufdt/+/refs/tags/android-10.0.0_r47

seq:
  - id: header
    type: dt_table_header
  - id: entries
    type: dt_table_entry
    repeat: expr
    repeat-expr: header.dt_entry_count

types:
  dt_table_header:
    seq:
      - id: magic
        contents: [0xd7, 0xb7, 0xab, 0x1e]
      - id: total_size
        type: u4
        doc: includes dt_table_header + all dt_table_entry and all dtb/dtbo
      - id: header_size
        type: u4
        doc: sizeof(dt_table_header)
      - id: dt_entry_size
        type: u4
        doc: sizeof(dt_table_entry)
      - id: dt_entry_count
        type: u4
        doc: number of dt_table_entry
      - id: dt_entries_offset
        type: u4
        doc: offset to the first dt_table_entry from head of dt_table_header
      - id: page_size
        type: u4
        doc: flash page size
      - id: version
        type: u4
        doc: DTBO image version
  dt_table_entry:
    seq:
      - id: dt_size
        type: u4
        doc: size of this entry
      - id: dt_offset
        type: u4
        doc: offset from head of dt_table_header
      - id: id
        type: u4
        doc: optional, must be zero if unused
      - id: rev
        type: u4
        doc: optional, must be zero if unused
      - id: custom
        type: u4
        repeat: expr
        repeat-expr: 4
        doc: optional, must be zero if unused
    instances:
      body:
        io: _root._io
        pos: dt_offset
        size: dt_size
        doc: DTB/DTBO file
