meta:
  id: vdi
  title: VirtualBox Disk Image
  application:
    - VirtualBox
    - QEMU
    - VMWare Workstation
  file-extension: vdi
  xref:
    forensicswiki: Virtual_Disk_Image_(VDI)
    pronom: fmt/726
    wikidata: Q29209126
  license: GPL-3.0-or-later
  encoding: utf-8
  endian: le
doc-ref: https://github.com/qemu/qemu/blob/master/block/vdi.c
#  - https://github.com/qemu/qemu/blob/master/block/vdi.c
#  - https://www.virtualbox.org/browser/vbox/trunk/src/VBox/Storage/VDI.cpp
#  - https://forums.virtualbox.org/viewtopic.php?t=8046
doc: |
  A native VirtualBox file format
  Images for testing can be downloaded from
   * https://www.osboxes.org/virtualbox-images/
   * https://virtualboxes.org/images/
   * https://virtualboximages.com/
  or you can convert images of other formats.
seq:
  - id: header
    type: header

instances:
  block_discarded:
    value: "0xfffffffe"
  block_unallocated:
    value: "0xffffffff"
  blocks_map:
    -orig-id: bmap
    pos: header.blocks_map_offset
    size: header.blocks_map_size
    type: blocks_map
    doc: >
      block_index = offset_in_virtual_disk / block_size
      actual_data_offset = blocks_map[block_index]*block_size+metadata_size+offset_in_block

      The blocks_map will take up blocks_in_image_max * sizeof(uint32_t) bytes;
      since the blocks_map is read and written in a single operation, its size needs to be limited to INT_MAX; furthermore, when opening an image, the blocks_map size is rounded up to be aligned on BDRV_SECTOR_SIZE.
      Therefore this should satisfy the following: blocks_in_image_max * sizeof(uint32_t) + BDRV_SECTOR_SIZE == INT_MAX + 1 (INT_MAX + 1 is the first value not representable as an int)
      This guarantees that any value below or equal to the constant will, when multiplied by sizeof(uint32_t) and rounded up to a BDRV_SECTOR_SIZE boundary, still be below or equal to INT_MAX.
  disk:
    pos: header.blocks_offset
    #size: header.header_main.disk_size
    type: disk
types:
  header:
    seq:
      - id: text
        type: str
        size: 0x40

      - id: signature
        contents: [0x7F, 0x10, 0xDA, 0xBE]

      - id: version
        type: version

      - id: header_size_optional
        type: u4
        if: subheader_size_is_dynamic

      - id: header_main
        size: header_size
        type: header_main
    instances:
      subheader_size_is_dynamic:
        value: version.major>=1
      header_size:
        value: '(subheader_size_is_dynamic ? header_size_optional : 336)'

      blocks_map_size:
        value: ( ( header_main.blocks_in_image * 4 + header_main.geometry.sector_size - 1 ) / header_main.geometry.sector_size ) * header_main.geometry.sector_size
      blocks_map_offset:
        value: header_main.blocks_map_offset

      blocks_offset:
        -orig-id: data_offset
        value: header_main.offset_data
      block_size:
        value: header_main.block_metadata_size + header_main.block_data_size

    types:
      uuid:
        seq:
          - id: uuid
            size: 16
      version:
        seq:
          - id: major
            type: u2
          - id: minor
            type: u2
      header_main:
        seq:
          - id: image_type
            type: u4
            enum: image_type

          - id: image_flags
            type: flags

          - id: description
            type: str
            size: 256

          - id: blocks_map_offset
            -orig-id: offset_bmap
            type: u4
            if: _parent.version.major>=1

          - id: offset_data
            type: u4
            if: _parent.version.major>=1

          - id: geometry
            type: geometry

          - id: reserved1
            -orig-id: unused1
            type: u4
            if: _parent.version.major>=1

          - id: disk_size
            type: u8

          - id: block_data_size
            -orig-id: block_size
            type: u4
            doc: "Size of block (bytes)."

          - id: block_metadata_size
            -orig-id: block_extra
            type: u4
            if: _parent.version.major>=1

          - id: blocks_in_image
            type: u4

          - id: blocks_allocated
            type: u4

          - id: uuid_image
            type: uuid

          - id: uuid_last_snap
            type: uuid

          - id: uuid_link
            type: uuid

          - id: uuid_parent
            type: uuid
            if: _parent.version.major>=1

          - id: lchc_geometry
            type: geometry
            if: _parent.version.major>=1 and _io.pos + 16 <= _io.size

          #- id: reserved2
          #  -orig_id: unused2
          #  size: _io.size - _io.pos
        types:
          geometry:
            seq:
              - id: cylinders
                type: u4

              - id: heads
                type: u4

              - id: sectors
                type: u4

              - id: sector_size
                type: u4
          flags:
            seq: #little endian assummed
              - id: reserved0
                type: b15
              - id: zero_expand
                type: b1
              - id: reserved1
                type: b6
              - id: diff
                type: b1
              - id: fixed
                type: b1
              - id: reserved2
                type: b8
  blocks_map:
    seq:
      - id: index
        type: block_index
        repeat: expr
        repeat-expr: _root.header.header_main.blocks_in_image
    types:
      block_index:
        seq:
          - id: index
            type: u4
        instances:
          is_allocated:
            value: index < _root.block_discarded
          block:
            #io: _root.disk._io
            value: _root.disk.blocks[index]
            if: is_allocated
  disk:
    seq:
      - id: blocks
        type: block
        repeat: expr
        repeat-expr: _root.header.header_main.blocks_in_image
    types:
      block:
        seq:
          - id: metadata
            size: _root.header.header_main.block_metadata_size
          - id: data
            size: _root.header.header_main.block_data_size
            type: sector
            repeat: eos
        types:
          sector:
            seq:
              - id: data
                size: _root.header.header_main.geometry.sector_size

enums:
  image_type:
    1: dynamic
    2: static
    3: undo
    4: diff
