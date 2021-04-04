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
doc-ref: https://www.adobe.com/content/dam/acom/en/devnet/pdf/swf-file-format-spec.pdf
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
            'tag_type::export_assets': symbol_class_body
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
  tag_type:
    0: end_of_file
    4: place_object
    5: remove_object
    9: set_background_color
    14: define_sound
    26: place_object2
    28: remove_object2
    43: frame_label
    56: export_assets
    65: script_limits
    69: file_attributes
    70: place_object3
    76: symbol_class
    77: metadata
    78: define_scaling_grid
    82: do_abc
    86: define_scene_and_frame_label_data
