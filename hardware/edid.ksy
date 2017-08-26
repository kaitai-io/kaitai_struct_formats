meta:
  id: edid
  title: EDID (VESA Enhanced Extended Display Identification Data)
  xref:
    repo: https://github.com/kaitai-io/edid.ksy.git
  license: CC0-1.0
  endian: le
seq:
  - id: magic
    contents: [0x00, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0x00]
  - id: mfg_bytes
    type: u2
  - id: product_code
    type: u2
    doc: Manufacturer product code
  - id: serial
    type: u4
    doc: Serial number
  - id: mfg_week
    type: u1
    doc: Week of manufacture. Week numbering is not consistent between manufacturers.
  - id: mfg_year_mod
    type: u1
    doc: Year of manufacture, less 1990. (1990–2245). If week=255, it is the model year instead.
  - id: edid_version_major
    type: u1
    doc: EDID version, usually 1 (for 1.3)
  - id: edid_version_minor
    type: u1
    doc: EDID revision, usually 3 (for 1.3)
  - id: input_flags
    type: u1
  - id: screen_size_h
    type: u1
    doc: Maximum horizontal image size, in centimetres (max 292 cm/115 in at 16:9 aspect ratio)
  - id: screen_size_v
    type: u1
    doc: Maximum vertical image size, in centimetres. If either byte is 0, undefined (e.g. projector)
  - id: gamma_mod
    type: u1
    doc: Display gamma, datavalue = (gamma*100)-100 (range 1.00–3.54)
  - id: features_flags
    type: u1
  - id: chromacity
    type: chromacity_info
    doc: 'Phosphor or filter chromaticity structure, which provides info on colorimetry and white point'
    doc-ref: Standard, section 3.7
  - id: est_timings
    type: est_timings_info
    doc: |
      Block of bit flags that indicates support of so called
      "established timings", which is a commonly used subset of VESA
      DMT (Discrete Monitor Timings) modes.
    doc-ref: Standard, section 3.8
  - id: std_timings
    type: std_timing
    doc: |
      Array of descriptions of so called "standard timings", which are
      used to specify up to 8 additional timings not included in
      "established timings".
    repeat: expr
    repeat-expr: 8
types:
  chromacity_info:
    doc: |
      Chromaticity information: colorimetry and white point
      coordinates. All coordinates are stored as fixed precision
      10-bit numbers, bits are shuffled for compactness.
    seq:
      - id: red_x_1_0
        type: b2
        doc: Red X, bits 1..0
      - id: red_y_1_0
        type: b2
        doc: Red Y, bits 1..0
      - id: green_x_1_0
        type: b2
        doc: Green X, bits 1..0
      - id: green_y_1_0
        type: b2
        doc: Green Y, bits 1..0
      - id: blue_x_1_0
        type: b2
        doc: Blue X, bits 1..0
      - id: blue_y_1_0
        type: b2
        doc: Blue Y, bits 1..0
      - id: white_x_1_0
        type: b2
        doc: White X, bits 1..0
      - id: white_y_1_0
        type: b2
        doc: White Y, bits 1..0
      - id: red_x_9_2
        type: u1
        doc: Red X, bits 9..2
      - id: red_y_9_2
        type: u1
        doc: Red Y, bits 9..2
      - id: green_x_9_2
        type: u1
        doc: Green X, bits 9..2
      - id: green_y_9_2
        type: u1
        doc: Green Y, bits 9..2
      - id: blue_x_9_2
        type: u1
        doc: Blue X, bits 9..2
      - id: blue_y_9_2
        type: u1
        doc: Blue Y, bits 9..2
      - id: white_x_9_2
        type: u1
        doc: White X, bits 9..2
      - id: white_y_9_2
        type: u1
        doc: White Y, bits 9..2
    instances:
      # Raw chromacity coordinates as 10-bit integers
      red_x_int:
        value: '(red_x_9_2 << 2) | red_x_1_0'
      red_y_int:
        value: '(red_y_9_2 << 2) | red_y_1_0'
      green_x_int:
        value: '(green_x_9_2 << 2) | green_x_1_0'
      green_y_int:
        value: '(green_y_9_2 << 2) | green_y_1_0'
      blue_x_int:
        value: '(blue_x_9_2 << 2) | blue_x_1_0'
      blue_y_int:
        value: '(blue_y_9_2 << 2) | blue_y_1_0'
      white_x_int:
        value: '(white_x_9_2 << 2) | white_x_1_0'
      white_y_int:
        value: '(white_y_9_2 << 2) | white_y_1_0'
      # User-friendly chromacity coordinates as floating point fractions
      red_x:
        value: red_x_int / 1024.0
        doc: Red X coordinate
      red_y:
        value: red_y_int / 1024.0
        doc: Red Y coordinate
      green_x:
        value: green_x_int / 1024.0
        doc: Green X coordinate
      green_y:
        value: green_y_int / 1024.0
        doc: Green Y coordinate
      blue_x:
        value: blue_x_int / 1024.0
        doc: Blue X coordinate
      blue_y:
        value: blue_y_int / 1024.0
        doc: Blue Y coordinate
      white_x:
        value: white_x_int / 1024.0
        doc: White X coordinate
      white_y:
        value: white_y_int / 1024.0
        doc: White Y coordinate
  est_timings_info:
    seq:
      # Byte 0: "Established Timing I"
      - id: can_720_400_70
        type: b1
        doc: Supports 720 x 400 @ 70Hz
      - id: can_720_400_88
        type: b1
        doc: Supports 720 x 400 @ 88Hz
      - id: can_640_480_60
        type: b1
        doc: Supports 640 x 480 @ 60Hz
      - id: can_640_480_67
        type: b1
        doc: Supports 640 x 480 @ 67Hz
      - id: can_640_480_72
        type: b1
        doc: Supports 640 x 480 @ 72Hz
      - id: can_640_480_75
        type: b1
        doc: Supports 640 x 480 @ 75Hz
      - id: can_800_600_56
        type: b1
        doc: Supports 800 x 600 @ 56Hz
      - id: can_800_600_60
        type: b1
        doc: Supports 800 x 600 @ 60Hz
      # Byte 1: "Established Timing II"
      - id: can_800_600_72
        type: b1
        doc: Supports 800 x 600 @ 72Hz
      - id: can_800_600_75
        type: b1
        doc: Supports 800 x 600 @ 75Hz
      - id: can_832_624_75
        type: b1
        doc: Supports 832 x 624 @ 75Hz
      - id: can_1024_768_87_i
        type: b1
        doc: Supports 1024 x 768 @ 87Hz(I)
      - id: can_1024_768_60
        type: b1
        doc: Supports 1024 x 768 @ 60Hz
      - id: can_1024_768_70
        type: b1
        doc: Supports 1024 x 768 @ 70Hz
      - id: can_1024_768_75
        type: b1
        doc: Supports 1024 x 768 @ 75Hz
      - id: can_1280_1024_75
        type: b1
        doc: Supports 1280 x 1024 @ 75Hz
      # Byte 2: "Manufacturer's Timings"
      - id: can_1152_870_75
        type: b1
        doc: Supports 1152 x 870 @ 75Hz
      - id: reserved
        type: b7
  std_timing:
    seq:
      - id: horiz_active_pixels_mod
        type: u1
        doc: |
          Range of horizontal active pixels, written in modified form:
          `(horiz_active_pixels / 8) - 31`. This yields an effective
          range of 256..2288, with steps of 8 pixels.
      - id: aspect_ratio
        type: b2
        enum: aspect_ratios
        doc: |
          Aspect ratio of the image. Can be used to calculate number
          of vertical pixels.
      - id: refresh_rate_mod
        type: b5
        doc: |
          Refresh rate in Hz, written in modified form: `refresh_rate
          - 60`. This yields an effective range of 60..123 Hz.
    instances:
      horiz_active_pixels:
        value: (horiz_active_pixels_mod + 31) * 8
        doc: Range of horizontal active pixels.
      refresh_rate:
        value: refresh_rate_mod + 60
        doc: Vertical refresh rate, Hz.
    enums:
      aspect_ratios:
        0: ratio_16_10
        1: ratio_4_3
        2: ratio_5_4
        3: ratio_16_9
instances:
  mfg_id_ch1:
    value: '(mfg_bytes & 0b0111110000000000) >> 10'
  mfg_id_ch2:
    value: '(mfg_bytes & 0b0000001111100000) >> 5'
  mfg_id_ch3:
    value: '(mfg_bytes & 0b0000000000011111)'
#  mfg_str:
#    value: '[mfg_id_ch1 + 0x40, mfg_id_ch2 + 0x40, mfg_id_ch3 + 0x40].to_s("ASCII")'
  mfg_year:
    value: mfg_year_mod + 1990
  gamma:
    value: (gamma_mod + 100) / 100.0
    if: gamma_mod != 0xff
