meta:
  id: nulib_lmd
  file-extension: lmd
  application: Games with Namco NU library
  title: Namco Lumen UI
  license: MIT
  endian: le
  bit-endian: le
  imports:
    - nulib_xmd
seq:
  - id: xmd
    type: nulib_xmd
instances:
  references:
    pos: xmd.positions[2]
    size: xmd.lengths[2]
  textures:
    type: textures
    pos: xmd.positions[1]
    size: xmd.lengths[1]
  lmb:
    type: lmb
    pos: xmd.positions[0]
    size: xmd.lengths[0]
types:
  nothing: {}
  textures:
    seq:
      - id: texture_hashes
        type: u4
        repeat: eos
  lmb:
    seq:
      - id: magic
        contents: "LMB\0"
      - id: texture_id
        type: u4
      - id: resource_id
        type: u4
      - id: xmd_padding
        size: 4
        type: nothing
      - id: num_padding
        type: u4
      - id: unknown4
        type: u4
      - id: unknown5
        type: u4
      - id: total_file_len
        type: u4
      - id: padding
        size: 0x10
        repeat: expr
        repeat-expr: num_padding
      - id: tags
        type: tag
        repeat: eos
  tag:
    doc: |
      tags are read from top to bottom
      BE CAREFUL:
      Any tag can depend on any other tag that comes before it.
      So while resolving references keep that in mind.
      However also by spect, a tag cannot depend on tags that
      come after it.
    seq:
      - id: tag_type
        type: u2
        enum: tag_type
      - id: offset
        type: u2
        valid:
          any-of:
            - 0
      - id: data_len
        type: u4
      - id: data
        type:
          switch-on: tag_type
          cases:
            'tag_type::symbols': symbols
            'tag_type::colors': colors
            'tag_type::transforms': transforms
            'tag_type::positions': positions
            'tag_type::bounds': bounds
            'tag_type::properties': properties
            'tag_type::defines': defines
            'tag_type::texture_atlases': texture_atlases
            'tag_type::shape': shape
            'tag_type::graphic': graphic
            'tag_type::dynamic_text': dynamic_text
            'tag_type::define_sprite': define_sprite
            'tag_type::frame_label': frame_label
            'tag_type::keyframe': frame
            'tag_type::show_frame': frame
            'tag_type::remove_object': remove_object
            'tag_type::do_action': do_action
            'tag_type::place_object': place_object
            'tag_type::action_script': action_script
            'tag_type::fonts': fonts
            _: unknown_tag_data
        size: data_len * 4
      - id: children
        type: tag
        repeat: expr
        # I don't know how well this is gonna work non-dynamic languages...
        repeat-expr: data.as<unknown_tag_data>.num_children
    enums:
      tag_type:
        0x0000: invalid

        0x000a: fonts
        0xf001: symbols
        0xf002: colors
        0xf003: transforms
        0xf004: bounds
        0xf005: action_script
        0xff05: action_script_2
        0xf007: texture_atlases
        0xf00c: properties
        0xf00d: defines

        0xf022: shape
        0xf024: graphic
        0xf037: color_matrix
        0xf103: positions

        0xf008: unknown_f008
        0xf009: unknown_f009
        0xf00a: unknown_f00a
        0xf00b: unknown_f00b

        0x0025: dynamic_text
        0x0027: define_sprite # aka movie clip

        0x002b: frame_label
        0x0001: show_frame
        0xf105: keyframe
        0x0004: place_object
        0x0005: remove_object
        0x000c: do_action

        0xff00: end
  unknown_tag_data:
    instances:
      num_children:
        value: 0
  fonts:
    seq:
      - id: unknown
        type: u4
  action_script:
    seq:
      - id: num_actions
        type: u4
      - id: actions
        type: avm1_bytecode(_index)
        repeat: expr
        repeat-expr: num_actions
    types:
      avm1_bytecode:
        params:
          - id: i
            type: u4
        seq:
          - id: len_bytecode
            type: u4
          - id: bytecode
            doc: 'This bytecode is for *AVM1*, not AVM2. Refer to projects such as OpenFlash for more info.'
            size: len_bytecode
          - id: padding
            type: nothing
            size: 4 - len_bytecode % 4
            if: i != _parent.num_actions - 1
  defines:
    seq:
      - id: num_shapes
        type: u4
      - id: unknown1
        type: u4
      - id: num_sprites
        type: u4
      - id: unknown2
        type: u4
      - id: num_texts
        type: u4
      - id: unknown3
        type: u4
        repeat: expr
        repeat-expr: 3
    instances:
      num_children:
        value: num_sprites + num_texts + num_shapes
  place_object:
    seq:
      - id: character_id
        type: u4
      - id: placement_id
        type: u4
      - id: unknown1
        type: u4
      - id: name_id
        type: u4
      - id: placement_mode
        type: u2
        enum: placement_mode
      - id: blend_mode
        type: u2
        enum: blend_mode
      - id: depth
        type: u2
      - id: unknown2
        type: u2
      - id: unknown3
        type: u2
      - id: unknown4
        type: u2
      - id: position_id
        doc: 'This is conditionally a position id, transform id, or nothing (0xffff) depending on position_flags'
        type: u2
      - id: position_flags
        type: u2
        enum: position_flags
      - id: color_mult_id
        type: u4
      - id: color_add_id
        type: u4
      - id: has_color_matrix
        type: u4
      - id: has_unknown_f014
        type: u4
    enums:
      position_flags:
        0x0000: transform
        0x8000: position
        0xffff: no_transform
      placement_mode:
        0x01: place
        0x02: move
      blend_mode:
        0x00: normal
        0x02: layer
        0x03: multiply
        0x04: screen
        0x05: lighten
        0x06: darken
        0x07: difference
        0x08: add
        0x09: subtract
        0x0a: invert
        0x0b: alpha
        0x0c: erase
        0x0d: overlay
        0x0e: hard_light
  do_action:
    seq:
      - id: action_id
        type: u4
      - id: unknown
        type: u4
  remove_object:
    seq:
      - id: unknown1
        type: u4
      - id: depth
        type: u2
      - id: unknown2
        type: u2
  frame:
    seq:
      - id: id
        type: u4
      - id: num_children
        doc: 'children directly follow this tag, they may be place/remove object or do_action'
        type: u4
  frame_label:
    seq:
      - id: name_id
        type: u4
      - id: start_frame
        type: u4
  define_sprite:
    seq:
      - id: character_id
        type: u4
      - id: unknown1
        size: 8
      - id: num_frame_labels
        doc: 'labels follow this tag, their respective index is the keyframe id'
        type: u4
      - id: num_frames
        doc: 'frames and keyframes may be mixed and come directly after this tag'
        type: u4
      - id: num_keyframes
        type: u4
      - id: unknown2
        type: u4
    instances:
      num_children:
        value: num_frame_labels + num_frames + num_keyframes
  dynamic_text:
    seq:
      - id: character_id
        type: u4
      - id: unknown1
        type: u4
      - id: placeholder_text
        type: u4
      - id: unknown2
        type: u4
      - id: stroke_color_id
        type: u4
      - id: unknown3
        type: u4
        repeat: expr
        repeat-expr: 3
      - id: alignment
        type: u2
        enum: text_alignment
      - id: unknown4
        type: u2
      - id: unknown5
        type: u4
        repeat: expr
        repeat-expr: 2
      - id: size
        type: f4
      - id: unknown6
        type: u4
        repeat: expr
        repeat-expr: 4
    enums:
      text_alignment:
        0: left
        1: right
        2: center
  shape:
    seq:
      - id: character_id
        type: u4
      - id: unknown1
        type: u4
      - id: bounds_id
        type: u4
      - id: unknown2
        type: u4
      - id: num_graphics
        doc: 'graphics are the following tags'
        type: u4
    instances:
      num_children:
        value: num_graphics
  graphic:
    seq:
      - id: atlas_id
        type: u4
      - id: fill_type
        type: u2
      - id: num_vertices
        type: u2
      - id: num_indices
        type: u4
      - id: vertices
        type: vertex
        repeat: expr
        repeat-expr: num_vertices
      - id: indices
        type: u2
        repeat: expr
        repeat-expr: num_indices
    types:
      vertex:
        seq:
          - id: x
            type: f4
          - id: y
            type: f4
          - id: u
            type: f4
          - id: v
            type: f4
  texture_atlases:
    seq:
      - id: num_values
        type: u4
      - id: values
        type: texture_atlas
        repeat: expr
        repeat-expr: num_values
    types:
      texture_atlas:
        seq:
          - id: id
            type: u4
          - id: name_id
            type: u4
          - id: width
            type: f4
          - id: height
            type: f4
  properties:
    seq:
      - id: unknown
        size: 3 * 4
      - id: max_character_id
        type: u4
      - id: unknown2
        type: u4
      - id: entry_character_id
        type: u4
      - id: max_depth
        type: u2
      - id: unknown3
        type: u2
      - id: framerate
        type: f4
      - id: width
        type: f4
      - id: height
        type: f4
      - id: unknown4
        size: 2 * 4
  bounds:
    seq:
      - id: num_values
        type: u4
      - id: values
        type: rect
        repeat: expr
        repeat-expr: num_values
    types:
      rect:
        seq:
          - id: x
            type: f4
          - id: y
            type: f4
          - id: width
            type: f4
          - id: height
            type: f4
  positions:
    seq:
      - id: num_values
        type: u4
      - id: values
        type: position
        repeat: expr
        repeat-expr: num_values
    types:
      position:
        seq:
          - id: x
            type: f4
          - id: y
            type: f4

  transforms:
    seq:
      - id: num_values
        type: u4
      - id: values
        type: matrix
        repeat: expr
        repeat-expr: num_values
    types:
      matrix:
        seq:
          - id: a
            type: f4
          - id: b
            type: f4
          - id: c
            type: f4
          - id: d
            type: f4
          - id: x
            type: f4
          - id: y
            type: f4
  colors:
    seq:
      - id: num_values
        type: u4
      - id: values
        type: color
        size: 8
        repeat: expr
        repeat-expr: num_values
    types:
      color:
        seq:
          - id: r
            type: u2
          - id: g
            type: u2
          - id: b
            type: u2
          - id: a
            type: u2
  symbols:
    seq:
      - id: num_values
        type: u4
      - id: values
        type: string
        repeat: expr
        repeat-expr: num_values
    types:
      string:
        seq:
          - id: len
            type: u4
          - id: value
            type: str
            encoding: UTF-8
            size: len
          - id: padding
            type: nothing
            size: 4 - len % 4
