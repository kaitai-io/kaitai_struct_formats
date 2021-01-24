meta:
  id: gbr1
  endian: le
  encoding: ascii
  title: GBM file
  license: MIT
  application: Gameboy Map Builder, GBMB
  file-extension:
    - gbm
  tags:
    - game

doc: |
  GBR1 files are used by Gameboy Map Builder, GBMB
  to store maps created with the program.
doc-ref: https://www.devrs.com/gb/hmgd/gbmb.html

seq:
  - id: magic
    contents: GBO1
  - id: objects
    type: gbr1_object
    repeat: eos

types:
  gbr1_object:
    seq:
      - id: marker
        contents: [0x48, 0x50, 0x4a, 0x4d, 0x54, 0x4c] # HPJMTL
      - id: object_type
        type: u2
        enum: object_type
      - id: object_id
        type: u2
      - id: master_id
        type: u2
      - id: crc
        type: u4
      - id: object_length
        type: u4
      - id: body
        size: object_length
        type:
          switch-on: object_type
          cases:
            object_type::producer:                   object_producer
            object_type::map:                        object_map
            object_type::map_tile_data:              object_map_tile_data
            object_type::map_properties:             object_map_properties
            object_type::map_property_data:          object_map_property_data
            object_type::map_default_property_value: object_map_default_property_value
            object_type::map_settings:               object_map_settings
            object_type::map_property_colors:        object_map_property_colors
            object_type::map_export_settings:        object_map_export_settings
            object_type::map_export_properties:      object_map_export_properties
            object_type::deleted:                    object_deleted
    
    enums:
      object_type:
        0x0001: producer
        0x0002: map
        0x0003: map_tile_data
        0x0004: map_properties
        0x0005: map_property_data
        0x0006: map_default_property_value
        0x0007: map_settings
        0x0008: map_property_colors
        0x0009: map_export_settings
        0x000A: map_export_properties
        0xFFFF: deleted

  object_producer:
    seq:
      - id: name
        type: strz
        size: 128
      - id: version
        type: strz
        size: 10
      - id: info
        type: strz
        size: 128

  object_map:
    seq:
      - id: name
        type: strz
        size: 128
      - id: width
        type: u4
      - id: height
        type: u4
      - id: prop_count
        type: u4
      - id: tile_file
        type: strz
        size: 256
      - id: tile_count
        type: u4
      - id: prop_color_count
        type: u4

  object_map_tile_data:
    seq:
      - id: master_id
        type: u2
      - id: data
        type: object_map_tile_data_record
        repeat: expr
        #repeat-expr: master.tile_count
        repeat-expr: 0
    instances:
      master:
      #  value: find_master(master_id) # <--- Doesn't work (https://github.com/kaitai-io/kaitai_struct/issues/172)
        value: 0
         

  object_map_tile_data_record:
    seq:
      - id: flipped_vertically
        type: b1
      - id: flipped_horizontally
        type: b1
      - id: reserved1
        type: b3
      - id: sgb_palette
        type: b3
      - id: reserved2
        type: b1
      - id: gbc_palette
        type: b5
      - id: tile_number
        type: b10

  object_map_properties:
    seq:
      - id: dummy
        size: 0

  object_map_property_data:
    seq:
      - id: dummy
        size: 0

  object_map_default_property_value:
    seq:
      - id: dummy
        size: 0

  object_map_settings:
    seq:
      - id: dummy
        size: 0

  object_map_property_colors:
    seq:
      - id: dummy
        size: 0

  object_map_export_settings:
    seq:
      - id: dummy
        size: 0

  object_map_export_properties:
    seq:
      - id: dummy
        size: 0

  object_deleted:
    doc: Deleted object
