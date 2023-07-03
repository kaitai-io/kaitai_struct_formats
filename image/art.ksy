meta:
  id: arcanum_aart
  title: "Arcanum: of steamworks and magick obscura graphics"
  file-extension: art
  endian: le
  bit-endian: le
seq:
  - id: art_header
    type: art_header
  - id: palettes
    type: art_pal
    repeat: expr
    repeat-expr: (art_header.pal_entries[0]>0).to_i+(art_header.pal_entries[1]>0).to_i+(art_header.pal_entries[2]>0).to_i+(art_header.pal_entries[3]>0).to_i
  - id: frame_headers
    type: art_frame_header
    repeat: expr
    repeat-expr: (art_header.flags.to_i & 1>0?1:art_header.direction_count)*art_header.frame_count
  - id: frame_data
    size: frame_headers[_index].size
    repeat: expr
    repeat-expr: (art_header.flags.to_i & 1>0?1:art_header.direction_count)*art_header.frame_count
types:
  art_header:
    seq:
      - id: flags
        type: u4
        enum: art_flags
      - id: frame_rate
        type: u4
      - id: direction_count
        type: u4
      - id: pal_entries
        type: u4
        repeat: expr
        repeat-expr: 4
      - id: action_frame
        type: u4
      - id: frame_count
        type: u4
      - id: unknown
        type: u4
        repeat: expr
        repeat-expr: 24
  art_pal:
    seq:
      - type: u4
        repeat: expr
        repeat-expr: 256
  art_frame_header:
    seq:
      - id: width
        type: u4
      - id: height
        type: u4
      - id: size
        type: u4
      - id: offset_x
        type: s4
      - id: offset_y
        type: s4
      - id: delta_x
        type: s4
      - id: delta_y
        type: s4
enums:
  art_flags:
    1: static
    2: critter
    4: font
    8: facade