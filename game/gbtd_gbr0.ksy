meta:
  id: gbr0
  endian: le
  encoding: ascii
  title: GBR file
  license: MIT
  application: GameBoy Tile Designer, GBTD
  file-extension:
    - gbr
  tags:
    - game

doc: |
  GBR0 files are used by GameBoy Tile Designer
  to store tilemaps created with the program.
doc-ref: https://www.devrs.com/gb/hmgd/gbtd.html

seq:
  - id: magic
    contents: GBO0
  - id: objects
    type: gbr0_object
    repeat: eos

types:
  gbr0_object:
    seq:
      - id: object_type
        type: u2
        enum: type
      - id: object_id
        type: u2
      - id: record_length
        type: u4
      - id: body
        size: record_length
        type:
          switch-on: object_type
          cases:
            type::producer:      producer
            type::tile_data:     tile_data
            type::tile_settings: tile_settings
            type::tile_export:   tile_export
            type::tile_import:   tile_import
            type::palettes:      palettes
            type::tile_pal:      tile_pal
            type::deleted:       deleted
    
    enums:
      type:
        0x0001: producer
        0x0002: tile_data
        0x0003: tile_settings
        0x0004: tile_export
        0x0005: tile_import
        0x000D: palettes
        0x000E: tile_pal
        0x00FF: deleted

    types:
      producer:
        seq:
          - id: name
            type: strz
            size: 30
          - id: version
            type: strz
            size: 10
          - id: info
            type: strz
            size: 80

      tile_data:
        seq:
          - id: name
            type: strz
            size: 30
          - id: width
            type: u2
          - id: height
            type: u2
          - id: count
            type: u2
          - id: color_set
            size: 4
          - id: tiles
            size: width*height
            repeat: expr
            repeat-expr: count

      tile_settings:
        seq:
          - id: tile_id
            type: u2
          - id: simple
            type: u1
          - id: flags
            type: u1
          - id: left_color
            type: u1
          - id: right_color
            type: u1
          - id: split_width
            type: u2
          - id: split_height
            type: u2
          - id: split_order
            type: u1 # Note: Official specification incorrectly says "long"
          - id: color_set
            type: u1
          - id: bookmarks
            type: u2
            repeat: expr
            repeat-expr: 3
          - id: auto_update
            type: u1
        
      tile_export:
        seq:
          - id: tile_id
            type: u2
          - id: file_name
            type: strz
            size: 128
          - id: file_type
            type: u1
          - id: section_name
            type: strz
            size: 20
          - id: label_name
            type: strz
            size: 20
          - id: bank
            type: u1
          - id: tile_array
            type: u1
          - id: format
            type: u1
          - id: counter
            type: u1
          - id: export_from
            type: u2
          - id: export_to
            type: u2
          - id: compression
            type: u1
          - id: include_colors
            type: u1
          - id: sgb_palettes
            type: u1
          - id: gbc_palettes
            type: u1
          - id: make_meta_tiles
            type: u1
          - id: meta_offset
            type: u4
          - id: meta_counter
            type: u1
          - id: split
            type: u1
          - id: block_size
            type: u4
          - id: sel_tab
            type: u1

      tile_import:
        seq:
          - id: tile_id
            type: u2
          - id: file_name
            type: strz
            size: 128
          - id: file_type
            type: u1
          - id: from_tile
            type: u2
          - id: to_tile
            type: u2
          - id: tile_count
            type: u2
          - id: color_conversion
            type: u1
          - id: first_byte
            type: u4
          - id: binary_file_type
            type: u1

      palette:
        seq:
          - id: colors
            type: u4
            repeat: expr
            repeat-expr: 4

      palettes:
        seq:
          - id: id
            type: u2
          - id: count
            type: u2
          - id: colors
            type: palette
            repeat: expr
            repeat-expr: count
          - id: sgb_count
            type: u2
          - id: sgb_colors
            type: palette
            repeat: expr
            repeat-expr: sgb_count

      tile_pal:
        seq:
          - id: id
            type: u2
          - id: count
            type: u2
          - id: color_set
            type: u4
            repeat: expr
            repeat-expr: count
          - id: sgb_count
            type: u2
          - id: sgb_color_set
            type: u4
            repeat: expr
            repeat-expr: sgb_count
        
      deleted:
        doc: Deleted object
