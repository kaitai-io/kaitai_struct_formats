meta:
  id: swf
  title: Adobe Flash (AKA Shockwave Flash, Macromedia Flash)
  file-extension: swf
  xref:
    justsolve: SWF
    pronom: fmt/507
      # - fmt/{505..507} # Adobe Flash {8..10}
      # - fmt/{757..776} # Adobe Flash {11..30}
    loc:
      - fdd000130 # SWF 7
      - fdd000248 # SWF 8
    mime: application/x-shockwave-flash
    wikidata: Q594447
  tags:
    - executable
    - media
  license: CC0-1.0
  endian: le
#  imports:
#    - abc_bytecode
doc: |
  SWF files are used by Adobe Flash (AKA Shockwave Flash, Macromedia
  Flash) to encode rich interactive multimedia content and are,
  essentially, a container for special bytecode instructions to play
  back that content. In early 2000s, it was dominant rich multimedia
  web format (.swf files were integrated into web pages and played
  back with a browser plugin), but its usage largely declined in
  2010s, as HTML5 and performant browser-native solutions
  (i.e. JavaScript engines and graphical approaches, such as WebGL)
  emerged.

  There are a lot of versions of SWF (~36), format is somewhat
  documented by Adobe.
doc-ref: https://open-flash.github.io/mirrors/swf-spec-19.pdf
seq:
  - id: compression
    -orig-id: Signature
    type: u1
    enum: compressions
  - id: signature
    -orig-id: Signature
    contents: "WS"
  - id: version
    -orig-id: Version
    type: u1
  - id: len_file
    -orig-id: FileLength
    type: u4
  - id: plain_body
    size-eos: true
    type: swf_body
    if: compression == compressions::none
  - id: zlib_body
    size-eos: true
    process: zlib
    type: swf_body
    if: compression == compressions::zlib
# lzma is not yet supporting in java runtime, that's why it's commented out
#  - id: lzma_body
#    size-eos: true
#    process: lzma_raw
#    type: swf_body
#    if: compression == compressions::lzma
types:
  swf_body:
    seq:
      - id: rect
        type: rect
      - id: frame_rate
        type: u2
      - id: frame_count
        type: u2
      - id: file_attributes_tag
        type: tag
        if: _root.version >= 8
      - id: tags
        type: tag
        repeat: eos
  rect:
    seq:
      - id: b1
        type: u1
      - id: skip
        size: num_bytes
    instances:
      num_bits:
        value: b1 >> 3
      num_bytes:
        value: ((num_bits * 4 - 3) + 7) / 8
  rgb:
    seq:
      - id: r
        type: u1
      - id: g
        type: u1
      - id: b
        type: u1
  # Swf specs has 3 types for color, rgb, rgba and arg.
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
# I wish I was able to load Fixed Floating point with Kaitai but couldn't find out how to do it.
  matrix:
    seq:
      - id: has_scale
        type: b1
      - id: n_scale_bits
        type: b5
        if: has_scale == true
      - id: scale_x
        size: n_scale_bits
        if: has_scale == true
      - id: scale_y
        size: n_scale_bits
        if: has_scale == true
      - id: has_rotate
        type: b1
      - id: n_rotate_bits
        type: b5
        if: has_rotate == true
      - id: rotate_skew_0
        size: n_rotate_bits
        if: has_rotate == true
      - id: rotate_skew_1
        size: n_rotate_bits
        if: has_rotate == true
      - id: n_translate_bits
        type: b5
      - id: translate_x
        size: n_translate_bits
      - id: translate_y
        size: n_translate_bits
  tag:
    seq:
      - id: record_header
        type: record_header
      - id: tag_body
        size: record_header.len
        type:
          switch-on: record_header.tag_type
          cases:
            'tag_type::define_sound': define_sound_body
            'tag_type::do_abc': do_abc_body
            'tag_type::script_limits': script_limits_body
            'tag_type::symbol_class': symbol_class_body
            'tag_type::set_background_color': rgb
            'tag_type::define_sprite': define_sprite_body
            'tag_type::export_assets': symbol_class_body
            'tag_type::define_shape4': define_shape4_body
  define_shape4_body:
    seq:
      - id: id
        -orig-id: ShapeId
        type: u2
      - id: shape_bounds
        type: rect
      - id: edge_bounds
        type: rect
      - id: reserved
        type: b5
      - id: use_fill_winding_rule
        type: b1
      - id: use_non_scaling_stroke
        type: b1
      - id: use_scaling_stroke
        type: b1
      - id: shapes
        # We need to carry the version of the shape as it impact the layout of the struct down the tree
        type: shape_with_style(4)
  shape_with_style:
    params:
      - id: shape_version
        type: u1
    seq:
      - id: fill_styles
        type: fill_style_array(shape_version)
      - id: line_styles
        type: line_style_array(shape_version)
  line_style_array:
    params:
      - id: shape_version
        type: u1
    seq:
      - id: line_style_count
        type: u1
      - id: line_style_count_extended
        type: u2
        if: line_style_count == 0xFF
      - id: line_styles
        type: line_style(shape_version)
        repeat: expr
        repeat-expr: line_style_count
        if: shape_version != 4
      - id: line_styles2
        type: line_style2(shape_version)
        repeat: expr
        repeat-expr: line_style_count == 0xFF ? line_style_count_extended : line_style_count
        if: shape_version == 4
  line_style:
    params:
      - id: shape_version
        type: u1
    seq:
      - id: width
        type: u2
      - id: color_a
        type: rgba
        if: shape_version == 4
      - id: color
        type: rgb
        if: shape_version != 4
  line_style2:
    params:
      - id: shape_version
        type: u1
    seq:
      - id: width
        type: u2
      - id: start_cap_style
        type: b2
        enum: cap_type
      - id: join_style
        type: b2
        enum: join_style
      - id: has_fill_flag
        type: b1
      - id: no_h_scale_flag
        type: b1
      - id: no_v_scale_flag
        type: b1
      - id: pixel_hinting_flag
        type: b1
      - id: reserved
        type: b5
      - id: no_close
        type: b1
      - id: end_cap_style
        type: b2
        enum: cap_type
      - id: meter_limit_factor
        type: u2
        if: join_style == join_style::miter_join
      - id: color
        type: rgba
        if: has_fill_flag == false
      - id: fill_type
        type: fill_style(shape_version)
        if: has_fill_flag == true
  fill_style_array:
    params:
      - id: shape_version
        type: u1
    seq:
      - id: fill_style_count
        type: u1
      - id: fill_style_count_extended
        type: u2
        if: fill_style_count == 0xFF
      - id: fill_styles
        type: fill_style(shape_version)
        repeat: expr
        repeat-expr: fill_style_count == 0xFF ? fill_style_count_extended : fill_style_count
  fill_style:
    params:
      - id: shape_version
        type: u1
    seq:
      - id: fill_style_type
        type: u1
        enum: fill_style_type_enum
      - id: color_a
        type: rgba
        if: fill_style_type == fill_style_type_enum::solid and shape_version == 4
      - id: color
        type: rgb
        if: fill_style_type == fill_style_type_enum::solid and shape_version != 4
      - id: gradient_matrix
        type: matrix
        if: fill_style_type == fill_style_type_enum::linear_gradient or fill_style_type == fill_style_type_enum::radial_gradient or fill_style_type == fill_style_type_enum::focal_gradient
      - id: gradient
        type: gradient_type(shape_version)
        if: fill_style_type == fill_style_type_enum::linear_gradient or fill_style_type == fill_style_type_enum::radial_gradient
  gradient_type:
    params:
      - id: shape_version
        type: u1
    seq:
      - id: spread_mode
        type: b2
        enum: spread_mode_enum
      - id: interpolation_mode
        type: b2
        enum: interpolation_mode_enum
      - id: num_gradient
        type: b4
      - id: gradient_records
        type: grad_record(shape_version)
        repeat: expr
        repeat-expr: num_gradient
  grad_record:
    params:
      - id: shape_version
        type: u1
    seq:
      - id: ratio
        type: u1
      - id: color_a
        type: rgba
        if:  shape_version == 4
      - id: color
        type: rgb
        if: shape_version != 4

  define_sprite_body:
    seq:
      - id: id
        -orig-id: SpriteId
        type: u2
      - id: frame_count
        type: u2
      - id: tags
        type: tag
        repeat: until
        repeat-until: _.record_header.tag_type == tag_type::end_of_file
  define_sound_body:
    seq:
      - id: id
        -orig-id: SoundId
        type: u2
      - id: format
        -orig-id: SoundFormat
        type: b4
      - id: sampling_rate
        -orig-id: SoundRate
        type: b2
        enum: sampling_rates
        doc: Sound sampling rate, as per enum. Ignored for Nellymoser and Speex codecs.
      - id: bits_per_sample
        -orig-id: SoundSize
        type: b1
        enum: bps
      - id: num_channels
        -orig-id: SoundType
        type: b1
        enum: channels
      - id: num_samples
        type: u4
    enums:
      sampling_rates:
        0: rate_5_5_khz
        1: rate_11_khz
        2: rate_22_khz
        3: rate_44_khz
      bps:
        0: sound_8_bit
        1: sound_16_bit
      channels:
        0: mono
        1: stereo
  do_abc_body:
    seq:
      - id: flags
        type: u4
      - id: name
        type: strz
        encoding: ASCII
      - id: abcdata
        size-eos: true
        #type: abc_bytecode
  script_limits_body:
    seq:
      - id: max_recursion_depth
        type: u2
      - id: script_timeout_seconds
        type: u2
  symbol_class_body:
    seq:
      - id: num_symbols
        type: u2
      - id: symbols
        type: symbol
        repeat: expr
        repeat-expr: num_symbols
    types:
      symbol:
        seq:
          - id: tag
            type: u2
          - id: name
            type: strz
            encoding: ASCII
  record_header:
    seq:
      - id: tag_code_and_length
        type: u2
      - id: big_len
        type: s4
        if: small_len == 0x3f
    instances:
      tag_type:
        value: 'tag_code_and_length >> 6'
        enum: tag_type
      small_len:
        value: 'tag_code_and_length & 0b111111'
      len:
        value: 'small_len == 0x3f ? big_len : small_len'
enums:
  compressions:
    0x46: none # F
    0x43: zlib # C
    0x5a: lzma # Z
  join_style:
    0: round_join
    1: bevel_join
    2: miter_join
  cap_type:
    0: round_cap
    1: no_cap
    2: square_cap
  fill_style_type_enum:
    0x00: solid
    0x10: linear_gradient
    0x12: radial_gradient
    0x13: focal_gradient
    0x40: repeat_bitmap
    0x41: clipped_bitmap
    0x42: non_smoothed_repeat_bitmap
    0x43: non_smoothed_clipped_bitmap
  spread_mode_enum:
    0: pad_mode
    1: reflect_mode
    2: repeat_mode
    3: reserved
  interpolation_mode_enum:
    0: normal_rgb
    1: linear_rgb
    2: reserved
    3: reserved
  tag_type:
    0: end_of_file
    1: show_frame
    2: define_shape
    4: place_object
    5: remove_object
    9: set_background_color
    14: define_sound
    26: place_object2
    28: remove_object2
    39: define_sprite
    43: frame_label
    56: export_assets
    65: script_limits
    69: file_attributes
    70: place_object3
    76: symbol_class
    77: metadata
    78: define_scaling_grid
    82: do_abc
    83: define_shape4
    86: define_scene_and_frame_label_data
