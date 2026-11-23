meta:
  id: aseprite
  title: Aseprite sprite
  application: Aseprite
  file-extension:
    - ase
    - aseprite
  license: CC0-1.0
  ks-version: 0.9
  endian: le
  bit-endian: le
doc: |
  Native file format of the Aseprite pixel art editor, also written by
  LibreSprite and other tools. It is close to the FLI/FLC animation format:
  a 128 byte header followed by frames, each made of typed chunks that
  describe layers, cels (the image of one layer in one frame), palettes,
  tags, slices, tilesets and user data.

  Image and tile data of cels and tilesets are zlib compressed and kept
  here as raw bytes. Every chunk is read within its own size, so chunk types
  added in newer versions of the format are skipped instead of breaking
  the parse.
doc-ref: https://github.com/aseprite/aseprite/blob/main/docs/ase-file-specs.md
seq:
  - id: header
    type: header
    size: 128
  - id: frames
    type: frame
    repeat: expr
    repeat-expr: header.num_frames
types:
  header:
    seq:
      - id: len_file
        type: u4
      - id: magic
        contents: [0xe0, 0xa5]
      - id: num_frames
        type: u2
      - id: width
        type: u2
      - id: height
        type: u2
      - id: color_depth
        type: u2
        enum: color_depth
        doc: Bits per pixel
      - id: flags
        type: header_flags
        size: 4
      - id: speed
        type: u2
        doc: Milliseconds between frames. Deprecated, every frame has its own duration.
      - id: reserved1
        size: 8
      - id: transparent_index
        type: u1
        doc: Palette entry used as transparent color in non-background layers of indexed sprites
      - id: reserved2
        size: 3
      - id: num_colors
        type: u2
        doc: 0 means 256 in old sprites
      - id: pixel_width
        type: u1
      - id: pixel_height
        type: u1
        doc: Pixel aspect ratio is pixel_width / pixel_height, 1:1 if either is 0
      - id: grid_x
        type: s2
      - id: grid_y
        type: s2
      - id: grid_width
        type: u2
        doc: 0 when there is no grid
      - id: grid_height
        type: u2
  header_flags:
    seq:
      - id: layer_opacity_valid
        type: b1
      - id: group_opacity_valid
        type: b1
        doc: Layer blend mode and opacity are valid for groups
      - id: layers_have_uuid
        type: b1
  frame:
    seq:
      - id: len_frame
        type: u4
      - id: magic
        contents: [0xfa, 0xf1]
      - id: num_chunks_old
        type: u2
        doc: Chunk count, 0xffff when there may be more and num_chunks_new holds the count
      - id: duration
        type: u2
        doc: Milliseconds
      - id: reserved
        size: 2
      - id: num_chunks_new
        type: u4
        doc: Chunk count, 0 means use num_chunks_old
      - id: chunks
        type: chunk
        repeat: expr
        repeat-expr: num_chunks
    instances:
      num_chunks:
        value: 'num_chunks_new != 0 ? num_chunks_new : num_chunks_old'
  chunk:
    seq:
      - id: len_chunk
        type: u4
        doc: Includes the 6 bytes of this header
      - id: chunk_type
        type: u2
        enum: chunk_type
      - id: body
        size: len_chunk - 6
        type:
          switch-on: chunk_type
          cases:
            'chunk_type::old_palette_256': old_palette_chunk
            'chunk_type::old_palette_64': old_palette_chunk
            'chunk_type::layer': layer_chunk
            'chunk_type::cel': cel_chunk
            'chunk_type::cel_extra': cel_extra_chunk
            'chunk_type::color_profile': color_profile_chunk
            'chunk_type::external_files': external_files_chunk
            'chunk_type::mask': mask_chunk
            'chunk_type::tags': tags_chunk
            'chunk_type::palette': palette_chunk
            'chunk_type::user_data': user_data_chunk
            'chunk_type::slice': slice_chunk
            'chunk_type::tileset': tileset_chunk
  ase_string:
    seq:
      - id: len_value
        type: u2
      - id: value
        type: str
        size: len_value
        encoding: UTF-8
  old_palette_chunk:
    doc: |
      Ignored when a palette chunk (0x2019) is present. Channels are 0-255 in
      chunk 0x0004 and 0-63 in chunk 0x0011.
    seq:
      - id: num_packets
        type: u2
      - id: packets
        type: old_palette_packet
        repeat: expr
        repeat-expr: num_packets
  old_palette_packet:
    seq:
      - id: num_skip
        type: u1
        doc: Entries to skip from the last packet
      - id: num_colors_raw
        type: u1
      - id: colors
        type: rgb
        repeat: expr
        repeat-expr: num_colors
    instances:
      num_colors:
        value: 'num_colors_raw == 0 ? 256 : num_colors_raw'
  rgb:
    seq:
      - id: r
        type: u1
      - id: g
        type: u1
      - id: b
        type: u1
  rgba:
    seq:
      - id: r
        type: u1
      - id: g
        type: u1
      - id: b
        type: u1
      - id: a
        type: u1
  layer_chunk:
    seq:
      - id: flags
        type: layer_flags
        size: 2
      - id: layer_type
        type: u2
        enum: layer_type
      - id: child_level
        type: u2
        doc: Nesting level relative to the previous layer, used to build groups
      - id: default_width
        type: u2
        doc: Ignored
      - id: default_height
        type: u2
        doc: Ignored
      - id: blend_mode
        type: u2
        enum: blend_mode
      - id: opacity
        type: u1
        doc: Only valid when header.flags.layer_opacity_valid is set
      - id: reserved
        size: 3
      - id: name
        type: ase_string
      - id: tileset_index
        type: u4
        if: layer_type == layer_type::tilemap
      - id: uuid
        size: 16
        if: _root.header.flags.layers_have_uuid
  layer_flags:
    seq:
      - id: visible
        type: b1
      - id: editable
        type: b1
      - id: lock_movement
        type: b1
      - id: background
        type: b1
      - id: prefer_linked_cels
        type: b1
      - id: collapsed
        type: b1
        doc: The group is shown collapsed
      - id: reference
        type: b1
  cel_chunk:
    seq:
      - id: layer_index
        type: u2
        doc: Index of the layer, counting layer chunks in file order
      - id: x
        type: s2
      - id: y
        type: s2
      - id: opacity
        type: u1
      - id: cel_type
        type: u2
        enum: cel_type
      - id: z_index
        type: s2
        doc: 0 keeps the layer order, positive values show the cel that many layers later
      - id: reserved
        size: 5
      - id: content
        type:
          switch-on: cel_type
          cases:
            'cel_type::raw_image': cel_image
            'cel_type::linked': cel_linked
            'cel_type::compressed_image': cel_image
            'cel_type::compressed_tilemap': cel_tilemap
  cel_image:
    seq:
      - id: width
        type: u2
      - id: height
        type: u2
      - id: pixels
        size-eos: true
        doc: Rows of pixels, zlib compressed for cel_type::compressed_image
  cel_linked:
    seq:
      - id: frame_position
        type: u2
        doc: Frame whose cel on the same layer is reused
  cel_tilemap:
    seq:
      - id: width
        type: u2
        doc: In tiles
      - id: height
        type: u2
        doc: In tiles
      - id: bits_per_tile
        type: u2
      - id: tile_id_mask
        type: u4
      - id: x_flip_mask
        type: u4
      - id: y_flip_mask
        type: u4
      - id: diagonal_flip_mask
        type: u4
      - id: reserved
        size: 10
      - id: tiles
        size-eos: true
        doc: Rows of tiles, zlib compressed
  cel_extra_chunk:
    doc: Extra information for the cel read just before
    seq:
      - id: flags
        type: u4
        doc: 1 means precise bounds are set
      - id: x
        type: fixed
      - id: y
        type: fixed
      - id: width
        type: fixed
      - id: height
        type: fixed
      - id: reserved
        size: 16
  fixed:
    doc: 16.16 fixed point number
    seq:
      - id: raw
        type: s4
    instances:
      value:
        value: raw / 65536.0
  color_profile_chunk:
    seq:
      - id: profile_type
        type: u2
        enum: color_profile_type
      - id: flags
        type: u2
        doc: 1 means the fixed gamma is used
      - id: gamma
        type: fixed
      - id: reserved
        size: 8
      - id: len_icc
        type: u4
        if: profile_type == color_profile_type::icc
      - id: icc
        size: len_icc
        if: profile_type == color_profile_type::icc
  external_files_chunk:
    seq:
      - id: num_entries
        type: u4
      - id: reserved
        size: 8
      - id: entries
        type: external_file
        repeat: expr
        repeat-expr: num_entries
  external_file:
    seq:
      - id: id
        type: u4
      - id: file_type
        type: u1
        enum: external_file_type
      - id: reserved
        size: 7
      - id: name
        type: ase_string
        doc: File name, or an extension ID like "publisher/ExtensionName"
  mask_chunk:
    doc: Deprecated
    seq:
      - id: x
        type: s2
      - id: y
        type: s2
      - id: width
        type: u2
      - id: height
        type: u2
      - id: reserved
        size: 8
      - id: name
        type: ase_string
      - id: bitmap
        size: height * ((width + 7) / 8)
        doc: 8 pixels per byte, leftmost in the high bit
  tags_chunk:
    seq:
      - id: num_tags
        type: u2
      - id: reserved
        size: 8
      - id: tags
        type: tag
        repeat: expr
        repeat-expr: num_tags
  tag:
    seq:
      - id: from_frame
        type: u2
      - id: to_frame
        type: u2
      - id: direction
        type: u1
        enum: loop_direction
      - id: repeat
        type: u2
        doc: Times to play the tag, 0 means not specified
      - id: reserved1
        size: 6
      - id: color
        type: rgb
        doc: Deprecated, the user data chunk after the tags chunk holds the color
      - id: reserved2
        size: 1
      - id: name
        type: ase_string
  palette_chunk:
    seq:
      - id: num_entries_total
        type: u4
        doc: New palette size
      - id: first_index
        type: u4
      - id: last_index
        type: u4
      - id: reserved
        size: 8
      - id: entries
        type: palette_entry
        repeat: expr
        repeat-expr: last_index - first_index + 1
  palette_entry:
    seq:
      - id: flags
        type: u2
      - id: color
        type: rgba
      - id: name
        type: ase_string
        if: flags & 1 != 0
  user_data_chunk:
    doc: |
      User data of the object read just before: a layer, a cel, the sprite
      (after the palette in the first frame), each tag in order after the tags
      chunk, or a tileset and its tiles.
    seq:
      - id: flags
        type: u4
      - id: text
        type: ase_string
        if: flags & 1 != 0
      - id: color
        type: rgba
        if: flags & 2 != 0
      - id: len_properties
        type: u4
        if: flags & 4 != 0
        doc: Includes this field and num_property_maps
      - id: num_property_maps
        type: u4
        if: flags & 4 != 0
      - id: property_maps
        size: len_properties - 8
        if: flags & 4 != 0
        doc: Typed key/value maps, kept as raw bytes
  slice_chunk:
    seq:
      - id: num_keys
        type: u4
      - id: flags
        type: u4
        doc: 1 means 9-patch, 2 means there is a pivot
      - id: reserved
        size: 4
      - id: name
        type: ase_string
      - id: keys
        type: slice_key
        repeat: expr
        repeat-expr: num_keys
  slice_key:
    seq:
      - id: frame
        type: u4
        doc: Valid from this frame to the end of the animation
      - id: x
        type: s4
      - id: y
        type: s4
      - id: width
        type: u4
      - id: height
        type: u4
      - id: center_x
        type: s4
        if: _parent.flags & 1 != 0
      - id: center_y
        type: s4
        if: _parent.flags & 1 != 0
      - id: center_width
        type: u4
        if: _parent.flags & 1 != 0
      - id: center_height
        type: u4
        if: _parent.flags & 1 != 0
      - id: pivot_x
        type: s4
        if: _parent.flags & 2 != 0
      - id: pivot_y
        type: s4
        if: _parent.flags & 2 != 0
  tileset_chunk:
    seq:
      - id: id
        type: u4
      - id: flags
        type: u4
        doc: |
          1: link to an external file, 2: tiles inside this file,
          4: tile id 0 is the empty tile
      - id: num_tiles
        type: u4
      - id: tile_width
        type: u2
      - id: tile_height
        type: u2
      - id: base_index
        type: s2
        doc: Number shown in the UI for the first tile, only for display
      - id: reserved
        size: 14
      - id: name
        type: ase_string
      - id: external_file_id
        type: u4
        if: flags & 1 != 0
      - id: external_tileset_id
        type: u4
        if: flags & 1 != 0
      - id: len_image
        type: u4
        if: flags & 2 != 0
      - id: image
        size: len_image
        if: flags & 2 != 0
        doc: Tiles stacked vertically, zlib compressed
enums:
  color_depth:
    8: indexed
    16: grayscale
    32: rgba
  chunk_type:
    0x0004: old_palette_256
    0x0011: old_palette_64
    0x2004: layer
    0x2005: cel
    0x2006: cel_extra
    0x2007: color_profile
    0x2008: external_files
    0x2016: mask
    0x2017: path
    0x2018: tags
    0x2019: palette
    0x2020: user_data
    0x2022: slice
    0x2023: tileset
  layer_type:
    0: image
    1: group
    2: tilemap
  blend_mode:
    0: normal
    1: multiply
    2: screen
    3: overlay
    4: darken
    5: lighten
    6: color_dodge
    7: color_burn
    8: hard_light
    9: soft_light
    10: difference
    11: exclusion
    12: hue
    13: saturation
    14: color
    15: luminosity
    16: addition
    17: subtract
    18: divide
  cel_type:
    0: raw_image
    1: linked
    2: compressed_image
    3: compressed_tilemap
  color_profile_type:
    0: none
    1: srgb
    2: icc
  external_file_type:
    0: palette
    1: tileset
    2: properties_extension
    3: tile_management_extension
  loop_direction:
    0: forward
    1: reverse
    2: ping_pong
    3: ping_pong_reverse
