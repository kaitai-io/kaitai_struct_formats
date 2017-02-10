meta:
  id: gif
  file-extension: gif
  endian: le
seq:
  - id: hdr
    type: header
  - id: logical_screen_descriptor
    type: logical_screen_descriptor_struct
  - id: global_color_table
    type: color_table
    # https://www.w3.org/Graphics/GIF/spec-gif89a.txt - section 18
    if: logical_screen_descriptor.has_color_table
    size: logical_screen_descriptor.color_table_size * 3
  - id: blocks
    type: block
    repeat: eos
types:
  header:
    # https://www.w3.org/Graphics/GIF/spec-gif89a.txt - section 17
    seq:
      - id: magic
        contents: 'GIF'
      - id: version
        size: 3
        encoding: ASCII
  logical_screen_descriptor_struct:
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
    instances:
      has_color_table:
        value: '(flags & 0b10000000) != 0'
      color_table_size:
        value: '2 << (flags & 7)'
  color_table:
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
        enum: block_type
      - id: body
        type:
          switch-on: block_type
          cases:
            'block_type::extension': extension
            'block_type::local_image_descriptor': local_image_descriptor
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
      - id: flags
        type: u1
      - id: local_color_table
        type: color_table
        if: has_color_table
        size: color_table_size * 3
      - id: image_data
        type: image_data
    instances:
      has_color_table:
        value: '(flags & 0b10000000) != 0'
      has_interlace:
        value: '(flags & 0b01000000) != 0'
      has_sorted_color_table:
        value: '(flags & 0b00100000) != 0'
      color_table_size:
        value: '2 << (flags & 7)'
  image_data:
    # https://www.w3.org/Graphics/GIF/spec-gif89a.txt - section 22
    seq:
      - id: lzw_min_code_size
        type: u1
      - id: subblocks
        type: subblocks
  extension:
    seq:
      - id: label
        type: u1
        enum: extension_label
      - id: body
        type:
          switch-on: label
          cases:
            'extension_label::application': ext_application
            'extension_label::comment': subblocks
            'extension_label::graphic_control': ext_graphic_control
            _: subblocks
  ext_application:
    seq:
      - id: application_id
        type: subblock
      - id: subblocks
        type: subblock
        repeat: until
        repeat-until: _.num_bytes == 0
  ext_graphic_control:
    # https://www.w3.org/Graphics/GIF/spec-gif89a.txt - section 23
    seq:
      - id: block_size
        contents: [4]
      - id: flags
        type: u1
      - id: delay_time
        type: u2
      - id: transparent_idx
        type: u1
      - id: terminator
        contents: [0]
    instances:
      transparent_color_flag:
        value: '(flags & 0b00000001) != 0'
      user_input_flag:
        value: '(flags & 0b00000010) != 0'
  subblocks:
    seq:
      - id: entries
        type: subblock
        repeat: until
        repeat-until: _.num_bytes == 0
  subblock:
    seq:
      - id: num_bytes
        type: u1
      - id: bytes
        size: num_bytes
enums:
  block_type:
    0x21: extension
    0x2c: local_image_descriptor
    0x3b: end_of_file
  extension_label:
    0xf9: graphic_control
    0xfe: comment
    0xff: application
