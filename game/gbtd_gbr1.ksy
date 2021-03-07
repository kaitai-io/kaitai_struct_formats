meta:
  id: gbr1
  endian: le
  encoding: ascii
  title: GBM file
  license: MIT
  ks-opaque-types: true
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
        contents: HPJMTL
      - id: object_type
        type: u2
        enum: type
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
            type::producer:                   producer
            type::map:                        map
            type::map_tile_data:              map_tile_data
            type::map_properties:             map_properties
            type::map_property_data:          map_property_data
            type::map_default_property_value: map_default_property_value
            type::map_settings:               map_settings
            type::map_property_colors:        map_property_colors
            type::map_export_settings:        map_export_settings
            type::map_export_properties:      map_export_properties

    enums:
      type:
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

    types:
      producer:
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

      map:
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

      map_tile_data:
        types:
          record:
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
        seq:
          - id: data
            type: record
            repeat: expr
            repeat-expr: num_records
        instances:
          num_records:
            value: master.object.as<gbr1_object>.body.as<map>.width * master.object.as<gbr1_object>.body.as<map>.height
          master:
            type: "lookup_object(_root.objects, _parent.master_id)"

      map_properties:
        types:
          record:
            seq:
              - id: type
                type: u4
              - id: size
                type: u4
              - id: name
                type: strz
                size: 32
        seq:
          - id: data
            type: record
            repeat: expr
            repeat-expr: num_records

        instances:
          num_records:
            value: master.object.as<gbr1_object>.body.as<map>.prop_count
          master:
            type: "lookup_object(_root.objects, _parent.master_id)"

      map_property_data:
        types:
          record:
            seq:
              - id: value
                type: u2
        seq:
          - id: data
            type: record
            repeat: expr
            repeat-expr: num_records

        instances:
          num_records:
            value: master.object.as<gbr1_object>.body.as<map>.prop_count * master.object.as<gbr1_object>.body.as<map>.width * master.object.as<gbr1_object>.body.as<map>.height
          master:
            type: "lookup_object(_root.objects, _parent.master_id)"

      map_default_property_value:
        types:
          record:
            seq:
              - id: value
                type: u2
        seq:
          - id: data
            type: record
            repeat: expr
            repeat-expr: num_records

        instances:
          num_records:
            value: master.object.as<gbr1_object>.body.as<map>.prop_count * master.object.as<gbr1_object>.body.as<map>.tile_count
          master:
            type: "lookup_object(_root.objects, _parent.master_id)"

      map_settings:
        seq:
          - id: form_width
            type: u4
          - id: form_height
            type: u4
          - id: form_maximized
            type: u1
          - id: info_panel
            type: u1
          - id: grid
            type: u1
          - id: double_markers
            type: u1
          - id: prop_colors
            type: u1
          - id: zoom
            type: u2
          - id: color_set
            type: u2
          - id: bookmarks
            type: u2
            repeat: expr
            repeat-expr: 3
          - id: block_fill_pattern
            type: u4
          - id: block_fill_width
            type: u4
          - id: block_fill_height
            type: u4

      map_property_colors:
        types:
          record:
            seq:
              - id: property
                type: u4
              - id: operator
                type: u4
              - id: value
                type: u4
        seq:
          - id: data
            type: record
            repeat: expr
            repeat-expr: num_records

        instances:
          num_records:
            value: master.object.as<gbr1_object>.body.as<map>.prop_color_count
          master:
            type: "lookup_object(_root.objects, _parent.master_id)"

      map_export_settings:
        seq:
          - id: file_name
            type: strz
            size: 255
            doc: Specification incorrectly lists this attribute as string(256)
          - id: file_type
            type: u1
          - id: section_name
            type: strz
            size: 40
          - id: label_name
            type: strz
            size: 40
          - id: bank
            type: u1
          - id: plane_count
            type: u2
          - id: plane_order
            type: u2
          - id: map_layout
            type: u2
          - id: split
            type: u1
          - id: split_size
            type: u4
          - id: split_bank
            type: u1
          - id: sel_tab
            type: u1
          - id: prop_count
            type: u2
          - id: tile_offset
            type: u2

      map_export_properties:
        types:
          record:
            seq:
              - id: property
                type: u4
              - id: size
                type: u4
        seq:
          - id: data
            type: record
            repeat: expr
            repeat-expr: num_records

        instances:
          num_records:
            value: master.object.as<gbr1_object>.body.as<map>.prop_count
          master:
            type: "lookup_object(_root.objects, _parent.master_id)"
