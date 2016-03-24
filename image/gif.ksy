meta:
  id: gif
  file-extension: gif
  endian: le
seq:
  - id: header
    type: header
  - id: logical_screen_descriptor
    type: logical_screen_descriptor
  - id: global_color_table
    type: global_color_table
    # https://www.w3.org/Graphics/GIF/spec-gif89a.txt - section 18
    if: '(logical_screen_descriptor.flags & 0x80) != 0'
    size: (2 << (logical_screen_descriptor.flags & 7)) * 3
  - id: blocks
    type: block
    repeat: eos
types:
  header:
    seq:
      - id: magic
        contents: 'GIF'
      - id: version
        size: 3
        encoding: ASCII
  logical_screen_descriptor:
    # https://www.w3.org/Graphics/GIF/spec-gif89a.txt - section 18
    seq:
      - id: screen_width
        type: u2
      - id: screen_height
        type: u2
      - id: flags
        type: u1
      - id: bg_color_index
        type: u1
      - id: pixel_aspect_ratio
        type: u1
  global_color_table:
    # https://www.w3.org/Graphics/GIF/spec-gif89a.txt - section 19
    seq:
      - id: entries
        type: color_table_entry
        repeat: eos
  color_table_entry:
    seq:
      - id: red
        type: u1
      - id: green
        type: u1
      - id: blue
        type: u1
  block:
    seq:
      - id: block_type
        type: u1
      - id: local_image_descriptor
        type: local_image_descriptor
        if: block_type == 0x2c
  local_image_descriptor:
    seq:
      - id: left
        type: u2
      - id: top
        type: u2
      - id: width
        type: u2
      - id: height
        type: u2
      - id: lid_flags
        type: u1
