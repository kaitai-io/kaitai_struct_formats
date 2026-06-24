meta:
  id: edid
  title: EDID (VESA Enhanced Extended Display Identification Data)
  xref:
    repo: https://github.com/kaitai-io/edid.ksy.git
    wikidata: Q1376385
  license: CC0-1.0
  endian: le

doc-ref: |
  VESA Enhanced Extended Display Identification Data Standard
  Defines EDID Structure Version 1, Revision 4

seq:
  - id: magic
    contents: [0x00, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0x00]
    doc: Magic header bytes.
    doc-ref: |
      Section 3.3: Header

  - id: manufacturer
    type: manufacturer
    doc: Information about the manufacturer.
    doc-ref: |
      Section 3.4.1: ID Manufacturer Name

  - id: product
    type: product
    doc: Information about the product.
    doc-ref: |
      Section 3.4.2: ID Product Code
      Section 3.4.3: ID Serial Number
      Section 3.4.4: Week and Year of Manufacture or Model Year

  - id: edid_version
    type: edid_version
    doc: EDID standard version.
    doc-ref: |
      Section 3.5: EDID Structure Version and Revision

  - id: display
    type: display
    doc: Basic display parameters and features.
    doc-ref: |
      Section 3.6: Basic Display Parameters and Features

  - id: chromaticity
    type: chromaticity
    doc: Chromaticity information and white point coordinates.
    doc-ref: |
      Section 3.7: Display x,y Chromaticity Coordinates

  - id: established_timings
    type: established_timings
    doc: |
      Block of bit flags that indicates support of so called
      "established timings", which is a commonly used subset of VESA
      DMT (Discrete Monitor Timings) modes.
    doc-ref: |
      Section 3.8: Established Timings I and II

  - id: standard_timings
    size: 2
    type: standard_timing
    repeat: expr
    repeat-expr: 8
    doc: |
      Array of descriptions of so called "standard timings", which are
      used to specify up to 8 additional timings not included in
      "established timings".
    doc-ref: |
      Section 3.9: Standard Timings

  - id: descriptors
    size: 18
    type: descriptor
    repeat: expr
    repeat-expr: 4
    doc: These 18 byte data fields shall contain either detailed timing data or other types of data.
    doc-ref: |
      Section 3.10: 18 Byte Descriptors

  - id: extension_blocks_count
    type: u1
    doc: Number of extension blocks to follow after this block.
    doc-ref: |
      Section 3.11: Extension Flag and Checksum

  - id: checksum
    type: u1
    doc: Checksum over the data of this block. All 128 bytes shall sum up to 0x00.
    doc-ref: |
      Section 3.11: Extension Flag and Checksum

types:

  manufacturer:
    seq:
      - id: reserved_raw
        type: b1
        valid:
          expr: _.as<u1> == 0b0
      - id: char1_raw
        type: b5
      - id: char2_raw
        type: b5
      - id: char3_raw
        type: b5

    instances:
      pnp_id:
        value: '[char1_raw + 0x40, char2_raw + 0x40, char3_raw + 0x40].as<bytes>.to_s("ASCII")'
        doc: The ISA Plug and Play Device Identifier (PNPID) of the manufacturer.

  product:
    seq:
      - id: product_code
        type: u2
        doc: Manufacturer assigned product code.

      - id: serial_number
        type: u4
        doc: Manufacturer assigned serial number.

      - id: week_raw
        type: u1

      - id: year_raw
        type: u1
        valid:
          min: 0x10
          max: 0xff

    instances:
      model_year_flag:
        value: true
        if: week_raw == 0xff
        doc: Whether the year is interpreted as the model year.

      week_of_manufacture:
        value: week_raw
        if: 0x01 <= week_raw and week_raw <= 0x36
        doc: Week of manufacture. Week numbering is not consistent between manufacturers.

      week_of_manufacture_unspecified:
        value: true
        if: week_raw == 0x00
        doc: Whether the week of manufacture is unspecified.

      year_of_manufacture:
        value: year_raw + 1990
        if: not model_year_flag
        doc: Year of manufacture.

      model_year:
        value: year_raw + 1990
        if: model_year_flag
        doc: The model year.

  edid_version:
    seq:
      - id: major
        type: u1
        valid: 0x01
        doc: EDID version, usually 1 (for 1.x).
      - id: minor
        type: u1
        # Note: Strictly adhering to the specification version 1.4 we should set:
        #valid: 0x04
        doc: EDID revision, usually 4 (for 1.4).

  display:
    seq:
      - id: video_input
        type: video_input
        doc: Indicate support for various video input signal features.
        doc-ref: |
          Section 3.6.1: Video Input Definition

      - id: screen
        type: screen
        doc: The horizontal and vertical screen size or aspect ratio.
        doc-ref: |
          Section 3.6.2: Horizontal and Vertical Screen Size or Aspect Ratio

      - id: gamma_raw
        type: u1
        valid:
          # Note: Specification says minimum value is 0x01 but this seems wrong and would leave 0x00 undefined.
          # min: 0x01
          min: 0x00
          max: 0xff
        doc-ref: |
          Section 3.6.3: Display Transfer Characteristics (Gamma)

      - id: feature_support
        type: feature_support
        doc: Indicate support for various display (hardware) features.
        doc-ref: |
          Section 3.6.4: Feature Support

    types:
      video_input:
        seq:
          - id: video_signal_type
            type: b1
            enum: video_signal_type
            doc: Analog or digital input signal type.

          # Analog Video Signal
          # Signal Level Standard
          - id: signal_level_raw
            type: b2
            enum: signal_level
            if: video_signal_type == video_signal_type::analog
            doc: Analog video signal level amplitudes.
          # Video Setup
          - id: video_setup
            type: b1
            if: video_signal_type == video_signal_type::analog
            doc: Whether there is a blank to black setup.
          # Synchronization Types
          - id: separate_sync
            type: b1
            if: video_signal_type == video_signal_type::analog
            doc: Whether separate sync H and V signals are supported.
          - id: composite_sync
            type: b1
            if: video_signal_type == video_signal_type::analog
            doc: Whether composite sync signal on horizontal is supported.
          - id: sync_on_green
            type: b1
            if: video_signal_type == video_signal_type::analog
            doc: Whether composite sync signal on green video is supported.
          # Serrations
          - id: serration
            type: b1
            if: video_signal_type == video_signal_type::analog
            doc: Whether serration on the vertical sync is supported.

          # Digital Video Signal
          - id: color_depth
            type: b3
            enum: color_bit_depth
            if: video_signal_type == video_signal_type::digital
            doc: Supported color bit depth.
          - id: video_interface
            type: b4
            enum: digital_video_interface_standard
            valid:
              expr: _.as<u1> <= 0b0101
            if: video_signal_type == video_signal_type::digital
            doc: Supported digital video interface standard.

        enums:
          signal_level:
            0b00: signal_level_0
            0b01: signal_level_1
            0b10: signal_level_2
            0b11: signal_level_3

          color_bit_depth:
            0b000: undefined
            0b001: primary_color_bits_6
            0b010: primary_color_bits_8
            0b011: primary_color_bits_10
            0b100: primary_color_bits_12
            0b101: primary_color_bits_14
            0b110: primary_color_bits_16

          digital_video_interface_standard:
            0b0000: undefined
            0b0001: dvi
            0b0010: hdmi_a
            0b0011: hdmi_b
            0b0100: mddi
            0b0101: dp

        types:
          signal_level_0:
            instances:
              signal_level_video:
                value: 0.700
              signal_level_sync:
                value: 0.300
          signal_level_1:
            instances:
              signal_level_video:
                value: 0.714
              signal_level_sync:
                value: 0.286
          signal_level_2:
            instances:
              signal_level_video:
                value: 1.000
              signal_level_sync:
                value: 0.400
          signal_level_3:
            instances:
              signal_level_video:
                value: 0.700
              signal_level_sync:
                value: 0.000

      screen:
        seq:
          - id: horizontal_raw
            type: u1
          - id: vertical_raw
            type: u1

        instances:
          size_horizontal:
            value: horizontal_raw
            if: horizontal_raw != 0x00 and vertical_raw != 0x00
            doc: Horizontal image size, measured in centimetres, range is 1 - 255.
          size_vertical:
            value: vertical_raw
            if: horizontal_raw != 0x00 and vertical_raw != 0x00
            doc: Vertical image size, measured in centimetres, range is 1 - 255.
          aspect_ratio_landscape:
            value: (horizontal_raw + 99.0) / 100.0
            if: horizontal_raw != 0x00 and vertical_raw == 0x00
            doc: Aspect ratio in landscape orientation, range is 1.00 - 3.54.
          aspect_ratio_portrait:
            value: 100.0 / (vertical_raw + 99.0)
            if: horizontal_raw == 0x00 and vertical_raw != 0x00
            doc: Aspect ratio in portrait orientation, range is 0.28 - 1.00.
          size_unknown:
            value: true
            if: horizontal_raw == 0x00 and vertical_raw == 0x00
            doc: Screen size and aspect ratio are unknown or undefined.

      feature_support:
        seq:
          - id: standby_mode
            type: b1
            doc: Whether standby mode is supported.
          - id: suspend_mode
            type: b1
            doc: Whether suspend mode is supported.
          - id: active_off_mode
            type: b1
            doc: Whether active off mode is supported.
          - id: display_color_type
            type: b2
            enum: display_color_type
            if: _parent.video_input.video_signal_type == video_signal_type::analog
            doc: The display color type, like monochrome / grayscale, rgb, ...
          - id: color_encoding_format
            type: b2
            enum: color_encoding_format
            if: _parent.video_input.video_signal_type == video_signal_type::digital
            doc: The supported color encoding formats.
          - id: srgb_default
            type: b1
            doc: Whether sRGB is the defualt color space.
          - id: preferred_timing_mode
            type: b1
            doc: Whether the preferred timing mode includes the native pixel format and refresh rate of the display.
          - id: continuous_frequency
            type: b1
            doc: Whether this is a continuous frequency display.

        enums:
          display_color_type:
            0b00: monochrome_grayscale
            0b01: rgb_color
            0b10: non_rgb_color
            0b11: undefinied_color_type

          color_encoding_format:
            0b00: supports_rgb444
            0b01: supports_rgb444_ycrcb444
            0b10: supports_rgb444_ycrcb422
            0b11: supports_rgb444_ycrcb444_ycrcb422

    instances:
      gamma:
        value: (gamma_raw + 100) / 100.0
        if: gamma_raw != 0xff
        doc: The display transfer characteristic (gamma value), range is 1.00 - 3.54.

      gamma_see_extension:
        value: true
        if: gamma_raw == 0xff
        doc: The display transfer characteristic (gamma value) is stored in an extension block.

  chromaticity:
    seq:
      - id: red_x_1_0_raw
        type: b2
        doc: Red X, bits 1..0
      - id: red_y_1_0_raw
        type: b2
        doc: Red Y, bits 1..0
      - id: green_x_1_0_raw
        type: b2
        doc: Green X, bits 1..0
      - id: green_y_1_0_raw
        type: b2
        doc: Green Y, bits 1..0
      - id: blue_x_1_0_raw
        type: b2
        doc: Blue X, bits 1..0
      - id: blue_y_1_0_raw
        type: b2
        doc: Blue Y, bits 1..0
      - id: white_x_1_0_raw
        type: b2
        doc: White X, bits 1..0
      - id: white_y_1_0_raw
        type: b2
        doc: White Y, bits 1..0
      - id: red_x_9_2_raw
        type: u1
        doc: Red X, bits 9..2
      - id: red_y_9_2_raw
        type: u1
        doc: Red Y, bits 9..2
      - id: green_x_9_2_raw
        type: u1
        doc: Green X, bits 9..2
      - id: green_y_9_2_raw
        type: u1
        doc: Green Y, bits 9..2
      - id: blue_x_9_2_raw
        type: u1
        doc: Blue X, bits 9..2
      - id: blue_y_9_2_raw
        type: u1
        doc: Blue Y, bits 9..2
      - id: white_x_9_2_raw
        type: u1
        doc: White X, bits 9..2
      - id: white_y_9_2_raw
        type: u1
        doc: White Y, bits 9..2

    instances:
      red_x_int_raw:
        value: '(red_x_9_2_raw << 2) | red_x_1_0_raw'
      red_y_int_raw:
        value: '(red_y_9_2_raw << 2) | red_y_1_0_raw'
      green_x_int_raw:
        value: '(green_x_9_2_raw << 2) | green_x_1_0_raw'
      green_y_int_raw:
        value: '(green_y_9_2_raw << 2) | green_y_1_0_raw'
      blue_x_int_raw:
        value: '(blue_x_9_2_raw << 2) | blue_x_1_0_raw'
      blue_y_int_raw:
        value: '(blue_y_9_2_raw << 2) | blue_y_1_0_raw'
      white_x_int_raw:
        value: '(white_x_9_2_raw << 2) | white_x_1_0_raw'
      white_y_int_raw:
        value: '(white_y_9_2_raw << 2) | white_y_1_0_raw'

      red_x:
        value: red_x_int_raw / 1024.0
        doc: Red CIE X coordinate.
      red_y:
        value: red_y_int_raw / 1024.0
        doc: Red CIE Y coordinate.
      green_x:
        value: green_x_int_raw / 1024.0
        doc: Green CIE X coordinate.
      green_y:
        value: green_y_int_raw / 1024.0
        doc: Green CIE Y coordinate.
      blue_x:
        value: blue_x_int_raw / 1024.0
        doc: Blue CIE X coordinate.
      blue_y:
        value: blue_y_int_raw / 1024.0
        doc: Blue CIE Y coordinate.
      white_x:
        value: white_x_int_raw / 1024.0
        doc: White CIE X coordinate.
      white_y:
        value: white_y_int_raw / 1024.0
        doc: White CIE Y coordinate.

  established_timings:
    seq:
      # Byte 0: "Established Timing I"
      - id: supports_720x400px_70hz
        type: b1
        doc: Supports 720 x 400 @ 70 Hz
      - id: supports_720x400px_88hz
        type: b1
        doc: Supports 720 x 400 @ 88 Hz
      - id: supports_640x480px_60hz
        type: b1
        doc: Supports 640 x 480 @ 60 Hz
      - id: supports_640x480px_67hz
        type: b1
        doc: Supports 640 x 480 @ 67 Hz
      - id: supports_640x480px_72hz
        type: b1
        doc: Supports 640 x 480 @ 72 Hz
      - id: supports_640x480px_75hz
        type: b1
        doc: Supports 640 x 480 @ 75 Hz
      - id: supports_800x600px_56hz
        type: b1
        doc: Supports 800 x 600 @ 56 Hz
      - id: supports_800x600px_60hz
        type: b1
        doc: Supports 800 x 600 @ 60 Hz
      # Byte 1: "Established Timing II"
      - id: supports_800x600px_72hz
        type: b1
        doc: Supports 800 x 600 @ 72 Hz
      - id: supports_800x600px_75hz
        type: b1
        doc: Supports 800 x 600 @ 75 Hz
      - id: supports_832x624px_75hz
        type: b1
        doc: Supports 832 x 624 @ 75 Hz
      - id: supports_1024x768px_87hz_i
        type: b1
        doc: Supports 1024 x 768 @ 87 Hz (I)
      - id: supports_1024x768px_60hz
        type: b1
        doc: Supports 1024 x 768 @ 60 Hz
      - id: supports_1024x768px_70hz
        type: b1
        doc: Supports 1024 x 768 @ 70 Hz
      - id: supports_1024x768px_75hz
        type: b1
        doc: Supports 1024 x 768 @ 75 Hz
      - id: supports_1280x1024px_75hz
        type: b1
        doc: Supports 1280 x 1024 @ 75 Hz
      # Byte 2: "Manufacturer's Timings"
      - id: supports_1152x870px_75hz
        type: b1
        doc: Supports 1152 x 870 @ 75 Hz
      - id: manufacturer_specific
        type: b7
        doc: Manufacturer specified timings.

  standard_timing:
    seq:
      - id: horizontal_addressable_pixels_raw
        type: u1
        valid:
          min: 0x01
          max: 0xff

      - id: aspect_ratio
        type: b2
        enum: aspect_ratios
        doc: Aspect ratio of the image. Can be used to calculate number of vertical pixels.

      - id: refresh_rate_raw
        type: b6

    instances:
      bytes_lookahead_internal:
        pos: 0
        size: 2

      is_used_internal:
        value: bytes_lookahead_internal != [0x01, 0x01]

      horizontal_addressable_pixels:
        value: (horizontal_addressable_pixels_raw + 31) * 8
        if: is_used_internal
        doc: Number of horizontal active pixels, range is 256 - 2288.

      refresh_rate:
        value: refresh_rate_raw + 60
        if: is_used_internal
        doc: Vertical refresh rate, measured in Hz, range is 60 - 123.

    enums:
      aspect_ratios:
        0b00: ratio_16_10
        0b01: ratio_4_3
        0b10: ratio_5_4
        0b11: ratio_16_9

  descriptor:
    seq:
      - id: detailed_timing_descriptor
        type: detailed_timing_descriptor
        size: 18
        if: is_detailed_timing_descriptor
        doc: Detailed timing descriptors represent supported video timing modes of the display.

      - id: display_descriptor
        type: display_descriptor
        size: 18
        if: is_display_descriptor
        doc: Display descriptors provide a variety of misc information about the display.

    instances:
      bytes_lookahead_internal:
        pos: 0
        size: 2

      is_detailed_timing_descriptor:
        value: bytes_lookahead_internal != [0x00, 0x00]
        doc: The descriptor is a detailed timing descriptor.
      is_display_descriptor:
        value: bytes_lookahead_internal == [0x00, 0x00]
        doc: The descriptor is a display descriptor.

    types:
      detailed_timing_descriptor:
        seq:
          - id: pixel_clock_raw
            type: u2
            valid:
              min: 0x00_01
              max: 0xff_ff

          - id: horizontal_addressable_video_7_0_raw
            type: u1
          - id: horizontal_blanking_7_0_raw
            type: u1
          - id: horizontal_addressable_video_11_8_raw
            type: b4
          - id: horizontal_blanking_11_8_raw
            type: b4

          - id: vertical_addressable_video_7_0_raw
            type: u1
          - id: vertical_blanking_7_0_raw
            type: u1
          - id: vertical_addressable_video_11_8_raw
            type: b4
          - id: vertical_blanking_11_8_raw
            type: b4

          - id: horizontal_front_porch_7_0_raw
            type: u1
          - id: horizontal_sync_pulse_width_7_0_raw
            type: u1
          - id: vertical_front_porch_3_0_raw
            type: b4
          - id: vertical_sync_pulse_width_3_0_raw
            type: b4

          - id: horizontal_front_porch_9_8_raw
            type: b2
          - id: horizontal_sync_pulse_width_9_8_raw
            type: b2
          - id: vertical_front_porch_5_4_raw
            type: b2
          - id: vertical_sync_pulse_width_5_4_raw
            type: b2

          - id: horizontal_addressable_video_image_size_7_0_raw
            type: u1
          - id: vertical_addressable_video_image_size_7_0_raw
            type: u1
          - id: horizontal_addressable_video_image_size_11_8_raw
            type: b4
          - id: vertical_addressable_video_image_size_11_8_raw
            type: b4

          - id: border_size_left
            type: u1
            doc: Left border size, value is measured in pixels, range is 0 - 255.
          - id: border_size_top
            type: u1
            doc: Top border size, value is measured in lines, range is 0 - 255.

          # Last byte with lots of flags
          # Bit 7
          - id: is_interlaced
            type: b1
            doc: Whether the video signal is interlaced.

          # Bit 6, 5
          - id: stereo_viewing_6_5_raw
            type: b2

          # Bit 4
          - id: video_sync_signal_type
            type: b1
            enum: video_signal_type
            doc: Whether the video input signal is analog or digital.

          # Bit 3
          - id: video_sync_signal_definition_analog
            type: b1
            enum: sync_definition_analog
            if: 'video_sync_signal_type == video_signal_type::analog'
            doc: Analog video sync signal definition.

          - id: video_sync_signal_definition_digital
            type: b1
            enum: sync_definition_digital
            if: 'video_sync_signal_type == video_signal_type::digital'
            doc: Digital video sync signal definition.

          # Bit 2
          - id: has_serrations
            type: b1
            if: |
              video_sync_signal_type == video_signal_type::analog or
              video_sync_signal_definition_digital == sync_definition_digital::digital_composite
            doc: Whether the signal has serrations.

          - id: vertical_sync_polarity
            type: b1
            enum: sync_polarity
            if: |
              video_sync_signal_type == video_signal_type::digital and
              video_sync_signal_definition_digital == sync_definition_digital::digital_separate
            doc: Vertical sync signal polarity (positive / negative).

          # Bit 1
          - id: sync_line
            type: b1
            enum: sync_line
            if: 'video_sync_signal_type == video_signal_type::analog'
            doc: Whether sync signal is on green line only or on all three (RGB) lines.

          - id: horizontal_sync_polarity
            type: b1
            enum: sync_polarity
            if: 'video_sync_signal_type == video_signal_type::digital'
            doc: Horizontal sync signal polarity (positive / negative).

          # Bit 0
          - id: stereo_viewing_0_raw
            type: b1

        doc-ref: "Section: 3.10.2 Detailed Timing Descriptor"

        enums:
          sync_definition_analog:
            0b0: analog_composite
            0b1: bipolar_analog_composite

          sync_definition_digital:
            0b0: digital_composite
            0b1: digital_separate

          sync_polarity:
            0b0: negative
            0b1: positive

          sync_line:
            0b0: green
            0b1: all

          stereo_viewing:
            0b000: do_not_care
            0b001: no_stereo
            0b010: sequential_right_sync
            0b100: sequential_left_sync
            0b011: interleaved_lines_right_even
            0b101: interleaved_lines_left_even
            0b110: interleaved_4_way
            0b111: side_by_side

        instances:
          pixel_clock:
            value: pixel_clock_raw * 10_000
            doc: Pixel clock, value is measured in Hz. Range is 10 kHz to 655.35 MHz in 10 kHz steps.

          horizontal_addressable_video:
            value: '(horizontal_addressable_video_11_8_raw << 8) | horizontal_addressable_video_7_0_raw'
            doc: Horizontal addressable video, value is measured in pixels, range is 0 - 4095.
          vertical_addressable_video:
            value: '(vertical_addressable_video_11_8_raw << 8) | vertical_addressable_video_7_0_raw'
            doc: Vertical addressable video, value is measured in lines, range is 0 - 4095.

          horizontal_blanking:
            value: '(horizontal_blanking_11_8_raw << 8) | horizontal_blanking_7_0_raw'
            doc: Horizontal blanking, value is measured in pixels, range is 0 - 4095.
          vertical_blanking:
            value: '(vertical_blanking_11_8_raw << 8) | vertical_blanking_7_0_raw'
            doc: Vertical blanking, value is measured in lines, range is 0 - 4095.

          horizontal_front_porch:
            value: '(horizontal_front_porch_9_8_raw << 8) | horizontal_front_porch_7_0_raw'
            doc: Horizontal front porch, value is measured in pixels, range is 0 - 1023.
          vertical_front_porch:
            value: '(vertical_front_porch_5_4_raw << 4) | vertical_front_porch_3_0_raw'
            doc: Vertical front porch, value is measured in lines, range is 0 - 63.

          horizontal_sync_pulse_width:
            value: '(horizontal_sync_pulse_width_9_8_raw << 8) | horizontal_sync_pulse_width_7_0_raw'
            doc: Horizontal sync pulse width, value is measured in pixels, range is 0 - 1023.
          vertical_sync_pulse_width:
            value: '(vertical_sync_pulse_width_5_4_raw << 4) | vertical_sync_pulse_width_3_0_raw'
            doc: Vertical sync pulse width, value is measured in lines, range is 0 - 63.

          horizontal_back_porch:
            value: horizontal_blanking - horizontal_front_porch - horizontal_sync_pulse_width
            doc: Horizontal back porch, value is measured in pixels.
          vertical_back_porch:
            value: vertical_blanking - vertical_front_porch - vertical_sync_pulse_width
            doc: Vertical back porch, value is measured in lines.

          horizontal_addressable_video_image_size:
            value: '(horizontal_addressable_video_image_size_11_8_raw << 8) | horizontal_addressable_video_image_size_7_0_raw'
            doc: Horizontal video image size, value is measured in mm, range is 0 - 4095.
          vertical_addressable_video_image_size:
            value: '(vertical_addressable_video_image_size_11_8_raw << 8) | vertical_addressable_video_image_size_7_0_raw'
            doc: Vertical video image size, value is measured in mm, range is 0 - 4095.

          border_size_right:
            value: border_size_left
            doc: Right border size, value is measured in pixels, range is 0 - 255.

          border_size_bottom:
            value: border_size_top
            doc: Bottom border size, value is measured in lines, range is 0 - 255.

          stereo_viewing_raw:
            value: '(stereo_viewing_6_5_raw << 2) | stereo_viewing_0_raw.as<u1>'

          # Note: Ugly hack because we can not use switch-on cases in instances
          stereo_viewing:
            value: |
              stereo_viewing_raw.as<u1> == 0b000 ? stereo_viewing::no_stereo : (
              stereo_viewing_raw.as<u1> == 0b001 ? stereo_viewing::no_stereo : (
              stereo_viewing_raw.as<u1> == 0b010 ? stereo_viewing::sequential_right_sync : (
              stereo_viewing_raw.as<u1> == 0b100 ? stereo_viewing::sequential_left_sync : (
              stereo_viewing_raw.as<u1> == 0b011 ? stereo_viewing::interleaved_lines_right_even : (
              stereo_viewing_raw.as<u1> == 0b101 ? stereo_viewing::interleaved_lines_left_even : (
              stereo_viewing_raw.as<u1> == 0b110 ? stereo_viewing::interleaved_4_way : stereo_viewing::side_by_side
              ))))))
            doc: Supported stereo viewing mode.


      display_descriptor:
        seq:
          - id: indicator_raw
            type: u2
            valid: 0x0000
          - id: reserved_raw
            type: u1
            valid: 0x00
          # Note: Could do this as an enum if enums could map different values to same name.
          - id: tag
            type: u1
            doc: Display descriptor type tag.
          - id: payload
            type:
              switch-on: tag
              cases:
                0xff: product_serial_number_descriptor
                0xfe: alphanumeric_data_string_descriptor
                0xfd: display_range_limits_descriptor
                0xfc: product_name_descriptor
                0xfb: color_point_data_descriptor
                0xfa: standard_timing_identifiers_descriptor
                0xf9: color_management_data_descriptor
                0xf8: cvt_timing_codes_descriptor
                0xf7: established_timings_descriptor
                0x10: dummy_descriptor
                0x0f: manufacturer_specified_descriptor
                0x0e: manufacturer_specified_descriptor
                0x0d: manufacturer_specified_descriptor
                0x0c: manufacturer_specified_descriptor
                0x0b: manufacturer_specified_descriptor
                0x0a: manufacturer_specified_descriptor
                0x09: manufacturer_specified_descriptor
                0x08: manufacturer_specified_descriptor
                0x07: manufacturer_specified_descriptor
                0x06: manufacturer_specified_descriptor
                0x05: manufacturer_specified_descriptor
                0x04: manufacturer_specified_descriptor
                0x03: manufacturer_specified_descriptor
                0x02: manufacturer_specified_descriptor
                0x01: manufacturer_specified_descriptor
                0x00: manufacturer_specified_descriptor
                _: unknown_descriptor
            doc: Payload of the display descriptor.

        doc-ref: "Section: 3.10.3 Display Descriptor Definitions"

        types:
          product_serial_number_descriptor:
            seq:
              - id: reserved_raw
                type: u1
                valid: 0x00
              - id: serial_number
                type: str
                size: 13
                encoding: ASCII
                terminator: 0x0a
                pad-right: 0x20
                doc: Display product serial number, up to 13 characters.
            doc-ref: "Section: 3.10.3.1 Display Product Serial Number Descriptor Definition"

          alphanumeric_data_string_descriptor:
            seq:
              - id: reserved_raw
                type: u1
                valid: 0x00
              - id: string
                type: str
                size: 13
                encoding: ASCII
                terminator: 0x0a
                pad-right: 0x20
                doc: An alphanumeric data string, up to 13 bytes.
            doc-ref: "Section: 3.10.3.2 Alphanumeric Data String Descriptor Definition"

          display_range_limits_descriptor:
            seq:
              - id: reserved_raw
                type: b4
                valid:
                  expr: _.as<u1> == 0b0000
              - id: range_limits_offsets_horizontal
                type: b2
                enum: rate_offset
                doc: Horizontal range limit offsets.
              - id: range_limits_offsets_vertical
                type: b2
                enum: rate_offset
                doc: Vertical range limit offsets.
              - id: min_vertical_rate_raw
                type: u1
                valid:
                  min: 0x01
                  max: 0xff
              - id: max_vertical_rate_raw
                type: u1
                valid:
                  min: 0x01
                  max: 0xff
              - id: min_horizontal_rate_raw
                type: u1
                valid:
                  min: 0x01
                  max: 0xff
              - id: max_horizontal_rate_raw
                type: u1
                valid:
                  min: 0x01
                  max: 0xff
              - id: max_pixel_clock_raw
                type: u1
                valid:
                  min: 0x01
                  max: 0xff
              - id: timing_support_flags
                type: u1
                enum: timing_support_flags
                doc: Flags describing the interpretation of the remaining bytes.
              - id: video_timing_data
                type:
                  switch-on: timing_support_flags
                  cases:
                    'timing_support_flags::default_gtf_supported': padding
                    'timing_support_flags::range_limits_only': padding
                    'timing_support_flags::secondary_gtf_supported': gtf_curve_definition
                    'timing_support_flags::cvt_supported': cvt_definition
                    _: reserved_raw
                if: |
                  timing_support_flags == timing_support_flags::secondary_gtf_supported or
                  timing_support_flags == timing_support_flags::cvt_supported
                size: 7
                doc: Timing definitions, interpretation according to the above flags.

            doc-ref: "Section: 3.10.3.3 Display Range Limits & Additional Timing Descriptor Definition"

            instances:
              vertical_lower_offset:
                value: 'range_limits_offsets_vertical == rate_offset::min_max_offset ? 255 : 0'
                doc: Lower offset of vertical rate, value is measured in Hz.
              vertical_upper_offset:
                value: 'range_limits_offsets_vertical != rate_offset::no_offset ? 255 : 0'
                doc: Upper offset of vertical rate, value is measured in Hz.
              horizontal_lower_offset:
                value: 'range_limits_offsets_horizontal == rate_offset::min_max_offset ? 255 : 0'
                doc: Lower offset of horizontal rate, value is measured in kHz.
              horizontal_upper_offset:
                value: 'range_limits_offsets_horizontal != rate_offset::no_offset ? 255 : 0'
                doc: Upper offset of horizontal rate, value is measured in kHz.

              min_vertical_rate:
                value: min_vertical_rate_raw + vertical_lower_offset
                doc: Minimum vertical scanning rate, value is measured in Hz, range is 1 - 510 Hz.
              max_vertical_rate:
                value: max_vertical_rate_raw + vertical_upper_offset
                doc: Maximum vertical scanning rate, value is measured in Hz, range is 1 - 510 Hz.
              min_horizontal_rate:
                value: (min_horizontal_rate_raw + horizontal_lower_offset) * 1_000
                doc: Minimum horizontal scanning rate, value is measured in Hz, range is 1 - 510 kHz.
              max_horizontal_rate:
                value: (max_horizontal_rate_raw + horizontal_upper_offset) * 1_000
                doc: Maximum horizontal scanning rate, value is measured in Hz, range is 1 - 510 kHz.

              max_pixel_clock:
                value: max_pixel_clock_raw * 10 * 1_000_000
                doc: Maximum pixel clock speed, value is measured in Hz, in multiples of 10 MHz.

            enums:
              rate_offset:
                0b00: no_offset
                0b01: invalid
                0b10: max_offset
                0b11: min_max_offset

              timing_support_flags:
                0x00: default_gtf_supported
                0x01: range_limits_only
                0x02: secondary_gtf_supported
                0x03: invalid
                0x04: cvt_supported

            types:
              padding:
                seq:
                  - id: padding_linefeed
                    type: u1
                    valid: 0x0a
                    doc: Padding data.
                  - id: padding_space
                    type: u1
                    valid: 0x20
                    repeat: expr
                    repeat-expr: 2
                    doc: Padding data.

              reserved_raw:
                seq:
                  - id: reserved_raw
                    size: 6

              gtf_curve_definition:
                seq:
                  - id: reserved_raw
                    type: u1
                    valid: 0x00
                  - id: start_frequency_raw
                    type: u1
                  - id: param_c_raw
                    type: u1
                  - id: param_m_raw
                    type: u2
                  - id: param_k_raw
                    type: u1
                  - id: param_j_raw
                    type: u1

                instances:
                  start_frequency:
                    value: start_frequency_raw * 2 * 1000
                    doc: Start frequency for secondary GTF curve, value is measured in Hz.
                  param_c:
                    value: param_c_raw / 2.0
                    doc: GTF parameter C, blanking formula offset.
                  param_m:
                    value: param_m_raw * 1.0
                    doc: GTF parameter M, blanking formula gradient.
                  param_k:
                    value: param_k_raw * 1.0
                    doc: GTF parameter K, blanking formula scaling factor.
                  param_j:
                    value: param_j_raw / 2.0
                    doc: GTF parameter J, blanking formula scaling factor weighting.

              cvt_definition:
                seq:
                  - id: cvt_standard_version
                    type: cvt_standard_version
                    doc: The CVT standard version.
                  - id: pixel_clock_precision_offset_raw
                    type: b6
                  - id: max_active_pixels_per_line_9_8_raw
                    type: b2
                  - id: max_active_pixels_per_line_7_0_raw
                    type: u1
                  - id: supported_aspect_ratios
                    type: supported_aspect_ratios
                    doc: Supported aspect ratios.
                  - id: preferred_aspect_ratio
                    type: b3
                    enum: preferred_aspect_ratio
                    doc: Preferred aspect ratios.
                  - id: supports_reduced_cvt_blanking
                    type: b1
                    doc: Whether reduced CVT blanking is supported.
                  - id: supports_standard_cvt_blanking
                    type: b1
                    doc: Whether standard CVT blanking is supported.
                  - id: reserved_raw
                    type: b3
                    valid:
                      expr: _.as<u1> == 0b000
                  - id: display_scaling_type
                    type: display_scaling
                    doc: Supported display scaling types (stretch / shrink).
                  - id: preferred_vertical_refresh_rate
                    type: u1
                    valid:
                      min: 0x01
                      max: 0xff
                    doc: The preferred vertical refresh rate, value is measured in Hz, range is 1 - 255.

                types:
                  cvt_standard_version:
                    seq:
                      - id: major
                        type: b4
                        doc: CVT standard version.
                      - id: minor
                        type: b4
                        doc: CVT standard revision.

                  supported_aspect_ratios:
                    seq:
                      - id: supports_ratio_4_3
                        type: b1
                        doc: Display supports aspect ratio 4:3.
                      - id: supports_ratio_16_9
                        type: b1
                        doc: Display supports aspect ratio 16:9.
                      - id: supports_ratio_16_10
                        type: b1
                        doc: Display supports aspect ratio 16:10.
                      - id: supports_ratio_5_4
                        type: b1
                        doc: Display supports aspect ratio 5:4.
                      - id: supports_ratio_15_9
                        type: b1
                        doc: Display supports aspect ratio 15:9.
                      - id: reserverd
                        type: b3
                        valid:
                          expr: _.as<u1> == 0b0000

                  display_scaling:
                    seq:
                      - id: supports_horizontal_shrink
                        type: b1
                        doc: Whether horizontal shrink is supported.
                      - id: supports_horizontal_stretch
                        type: b1
                        doc: Whether horizontal stretch is supported.
                      - id: supports_vertical_shrink
                        type: b1
                        doc: Whether vertical shrink is supported.
                      - id: supports_vertical_stretch
                        type: b1
                        doc: Whether vertical stretch is supported.
                      - id: reserved_raw
                        type: b4
                        valid:
                          expr: _.as<u1> == 0b0000

                enums:
                  preferred_aspect_ratio:
                    0b000: ratio_4_3
                    0b001: ratio_16_9
                    0b010: ratio_16_10
                    0b011: ratio_5_4
                    0b100: ratio_15_9

                instances:
                  pixel_clock_precision_offset:
                    value: pixel_clock_precision_offset_raw * 250_000
                    doc: Maximal pixel clock offset (subtractive), value is measured in Hz.

                  max_pixel_clock_precise:
                    value: '_parent.max_pixel_clock - pixel_clock_precision_offset'
                    doc: Maximum pixel clock speed, value is measured in Hz, precision is 0.25 MHz.

                  max_active_pixels_per_line:
                    value: '(max_active_pixels_per_line_9_8_raw << 8) | max_active_pixels_per_line_7_0_raw'
                    if: max_active_pixels_per_line_7_0_raw != 0x00
                    doc: Maximum of active pixels per line.

                  unlimited_active_pixels_per_line:
                    value: true
                    if: max_active_pixels_per_line_7_0_raw == 0x00
                    doc: Number of active pixels per line is not limited.

          product_name_descriptor:
            seq:
              - id: reserved_raw
                type: u1
                valid: 0x00
              - id: name
                type: str
                size: 13
                encoding: ASCII
                terminator: 0x0a
                pad-right: 0x20
                doc: Display product/model name, up to 13 characters.
            doc-ref: "Section: 3.10.3.4 Display Product Name (ASCII) String Descriptor Definition"

          color_point_data_descriptor:
            seq:
              - id: reserved_raw
                type: u1
                valid: 0x00

              - id: white_points
                size: 5
                type: white_point
                repeat: expr
                repeat-expr: 2
                doc: Chromaticity coordinates of additional white points.

              - id: padding_linefeed
                type: u1
                valid: 0x0a
                doc: Padding data.
              - id: padding_space
                type: u1
                valid: 0x20
                repeat: expr
                repeat-expr: 2
                doc: Padding data.
            doc-ref: "Section: 3.10.3.5 Color Point Descriptor Definition"

            types:
              white_point:
                seq:
                  - id: index_raw
                    type: u1
                  - id: reserved_raw
                    type: b4
                    valid:
                      expr: _.as<u1> == 0b0000
                  - id: white_x_1_0_raw
                    type: b2
                    if: is_used_internal
                  - id: white_y_1_0_raw
                    type: b2
                    if: is_used_internal
                  - id: white_x_9_2_raw
                    type: u1
                    if: is_used_internal
                  - id: white_y_9_2_raw
                    type: u1
                    if: is_used_internal
                  - id: gamma_raw
                    type: u1
                    valid:
                      min: 0x00
                      max: 0xff
                    if: is_used_internal

                instances:
                  is_used_internal:
                    value: true
                    if: index_raw >= 0x01

                  index:
                    value: index_raw
                    if: is_used_internal
                    doc: White point index.

                  white_x_int_raw:
                    value: '(white_x_9_2_raw << 2) | white_x_1_0_raw'
                    if: is_used_internal
                  white_y_int_raw:
                    value: '(white_y_9_2_raw << 2) | white_y_1_0_raw'
                    if: is_used_internal

                  white_x:
                    value: white_x_int_raw / 1024.0
                    if: is_used_internal
                    doc: White CIE X coordinate.
                  white_y:
                    value: white_y_int_raw / 1024.0
                    if: is_used_internal
                    doc: White CIE Y coordinate.

                  gamma:
                    value: (gamma_raw + 100) / 100.0
                    if: is_used_internal and gamma_raw != 0xff
                    doc: The associated gamma value, range is 1.00 - 3.54.

                  gamma_see_extension:
                    value: true
                    if: is_used_internal and gamma_raw == 0xff
                    doc: The associated gamma value is stored in an extension block.

          standard_timing_identifiers_descriptor:
            seq:
              - id: reserved_raw
                type: u1
                valid: 0x00
              - id: standard_timings
                size: 2
                type: standard_timing
                repeat: expr
                repeat-expr: 6
                doc: Up to six additional standard timings.
              - id: padding_linefeed
                type: u1
                valid: 0x0a
                doc: Padding data.
            doc-ref: "Section: 3.10.3.6 Standard Timing Identifier Definition"

          color_management_data_descriptor:
            seq:
              - id: reserved_raw
                type: u1
                valid: 0x00
              - id: version
                type: u1
                valid: 0x03
                doc: Display Color Management standard version number.
              - id: coefficient_red_a3
                type: u2
                doc: Red a3 color management polynomial coefficient.
              - id: coefficient_red_a2
                type: u2
                doc: Red a2 color management polynomial coefficient.
              - id: coefficient_green_a3
                type: u2
                doc: Green a3 color management polynomial coefficient.
              - id: coefficient_green_a2
                type: u2
                doc: Green a2 color management polynomial coefficient.
              - id: coefficient_blue_a3
                type: u2
                doc: Blue a3 color management polynomial coefficient.
              - id: coefficient_blue_a2
                type: u2
                doc: Blue a2 color management polynomial coefficient.
            doc-ref: "Section: 3.10.3.7 Color Management Data Definition"

          cvt_timing_codes_descriptor:
            seq:
              - id: reserved_raw
                type: u1
                valid: 0x00
              - id: version
                type: u1
                valid: 0x01
                doc: Coordinated Video Timings (CVT) standard version number.
              - id: cvt_timing_codes
                size: 3
                type: cvt_timing_code
                repeat: expr
                repeat-expr: 4
                doc: Up to 4 CVT 3-byte code descriptors, in descending priority.
            doc-ref: "Section: 3.10.3.8 CVT 3 Byte Code Descriptor Definition"

            types:
              cvt_timing_code:
                seq:
                  - id: lines_per_field_7_0_raw
                    type: u1
                  - id: lines_per_field_11_8_raw
                    type: b4
                  - id: aspect_ratio
                    type: b2
                    if: is_used_internal
                    doc: The aspect ratio.
                  - id: reserved
                    type: b3
                    valid:
                      expr: _.as<u1> == 0b000
                  - id: preferred_vertical_rate
                    type: b2
                    if: is_used_internal
                    doc: Preferred vertical rate.
                  - id: supports_vertical_rate_50hz
                    type: b1
                    if: is_used_internal
                    doc: Supports 50 Hz vertical rate with standard blanking.
                  - id: supports_vertical_rate_60hz
                    type: b1
                    if: is_used_internal
                    doc: Supports 60 Hz vertical rate with standard blanking.
                  - id: supports_vertical_rate_75hz
                    type: b1
                    if: is_used_internal
                    doc: Supports 75 Hz vertical rate with standard blanking.
                  - id: supports_vertical_rate_85hz
                    type: b1
                    if: is_used_internal
                    doc: Supports 85 Hz vertical rate with standard blanking.
                  - id: supports_vertical_rate_60hz_rb
                    type: b1
                    if: is_used_internal
                    doc: Supports 60 Hz vertical rate with reduced blanking.

                instances:
                  bytes_lookahead_internal:
                    pos: 0
                    size: 3

                  is_used_internal:
                    value: bytes_lookahead_internal != [0x00, 0x00, 0x00]

                  lines_per_field:
                    value: '(lines_per_field_11_8_raw << 8) | lines_per_field_7_0_raw'
                    if: is_used_internal
                    doc: Number of addressable lines per field.

          established_timings_descriptor:
            seq:
              - id: reserved_raw
                type: u1
                valid: 0x00
              - id: version
                type: u1
                valid: 0x0a
                doc: Monitor Timing standard version number.
              # Byte 6: "Established Timing III"
              - id: supports_640x350px_85hz
                type: b1
                doc: Supports 640 x 350 @ 85Hz
              - id: supports_640x400px_85hz
                type: b1
                doc: Supports 640 x 400 @ 85 Hz
              - id: supports_720x400px_85hz
                type: b1
                doc: Supports 720 x 400 @ 85 Hz
              - id: supports_640x480px_85hz
                type: b1
                doc: Supports 640 x 480 @ 85 Hz
              - id: supports_848x480px_60hz
                type: b1
                doc: Supports 848 x 480 @ 60 Hz
              - id: supports_800x600px_85hz
                type: b1
                doc: Supports 800 x 600 @ 85 Hz
              - id: supports_1024x768px_85hz
                type: b1
                doc: Supports 1024 x 768 @ 85 Hz
              - id: supports_1152x864_75hz
                type: b1
                doc: Supports 1152 x 864 @ 75 Hz
              # Byte 7: "Established Timing III"
              - id: supports_1280x768px_60hz_rb
                type: b1
                doc: Supports 1280 x 768 @ 60 Hz (Reduced Blanking)
              - id: supports_1280x768px_60hz
                type: b1
                doc: Supports 1280 x 768 @ 60 Hz
              - id: supports_1280x768px_75hz
                type: b1
                doc: Supports 1280 x 768 @ 75 Hz
              - id: supports_1280x768px_85hz
                type: b1
                doc: Supports 1280 x 768 @ 85 Hz
              - id: supports_1280x960px_60hz
                type: b1
                doc: Supports 1280 x 960 @ 60 Hz
              - id: supports_1280x960px_85hz
                type: b1
                doc: Supports 1280 x 960 @ 85 Hz
              - id: supports_1280x1024px_60hz
                type: b1
                doc: Supports 1280 x 1024 @ 60 Hz
              - id: supports_1280x1024px_85hz
                type: b1
                doc: Supports 1280 x 1024 @ 85 Hz
              # Byte 8: "Established Timing III"
              - id: supports_1360x768px_60hz
                type: b1
                doc: Supports 1360 x 768 @ 60 Hz
              - id: supports_1440x900px_60hz_rb
                type: b1
                doc: Supports 1440 x 900 @ 60 Hz (Reduced Blanking)
              - id: supports_1440x900px_60hz
                type: b1
                doc: Supports 1440 x 900 @ 60 Hz
              - id: supports_1440x900px_75hz
                type: b1
                doc: Supports 1440 x 900 @ 75 Hz
              - id: supports_1440x900px_85hz
                type: b1
                doc: Supports 1440 x 900 @ 85 Hz
              - id: supports_1400x1050px_60hz_rb
                type: b1
                doc: Supports 1400 x 1050 @ 60 Hz (Reduced Blanking)
              - id: supports_1400x1050px_60hz
                type: b1
                doc: Supports 1400 x 1050 @ 60 Hz
              - id: supports_1400x1050px_75hz
                type: b1
                doc: Supports 1400 x 1050 @ 75 Hz
              # Byte 9: "Established Timing III"
              - id: supports_1400x1050px_85hz
                type: b1
                doc: Supports 1400 x 1050 @ 85 Hz
              - id: supports_1680x1050px_60hz_rb
                type: b1
                doc: Supports 1680 x 1050 @ 60 Hz (Reduced Blanking)
              - id: supports_1680x1050px_60hz
                type: b1
                doc: Supports 1680 x 1050 @ 60 Hz
              - id: supports_1680x1050px_75hz
                type: b1
                doc: Supports 1680 x 1050 @ 75 Hz
              - id: supports_1680x1050px_85hz
                type: b1
                doc: Supports 1680 x 1050 @ 85 Hz
              - id: supports_1600x1200px_60hz
                type: b1
                doc: Supports 1600 x 1200 @ 60 Hz
              - id: supports_1600x1200px_65hz
                type: b1
                doc: Supports 1600 x 1200 @ 65 Hz
              - id: supports_1600x1200px_70hz
                type: b1
                doc: Supports 1600 x 1200 @ 70 Hz
              # Byte 10: "Established Timing III"
              - id: supports_1600x1200px_75hz
                type: b1
                doc: Supports 1600 x 1200 @ 75 Hz
              - id: supports_1600x1200px_85hz
                type: b1
                doc: Supports 1600 x 1200 @ 85 Hz
              - id: supports_1792x1344px_60hz
                type: b1
                doc: Supports 1792 x 1344 @ 60 Hz
              - id: supports_1792x1344px_75hz
                type: b1
                doc: Supports 1792 x 1344 @ 75 Hz
              - id: supports_1856x1392px_60hz
                type: b1
                doc: Supports 1856 x 1392 @ 60 Hz
              - id: supports_1856x1392px_75hz
                type: b1
                doc: Supports 1856 x 1392 @ 75 Hz
              - id: supports_1920x1200px_60hz_rb
                type: b1
                doc: Supports 1920 x 1200 @ 60 Hz (Reduced Blanking)
              - id: supports_1920x1200px_60hz
                type: b1
                doc: Supports 1920 x 1200 @ 60 Hz
              # Byte 11: "Established Timing III"
              - id: supports_1920x1200px_75hz
                type: b1
                doc: Supports 1920 x 1200 @ 75 Hz
              - id: supports_1920x1200px_85hz
                type: b1
                doc: Supports 1920 x 1200 @ 85 Hz
              - id: supports_1920x1440px_60hz
                type: b1
                doc: Supports 1920 x 1440 @ 60 Hz
              - id: supports_1920x1440px_75hz
                type: b1
                doc: Supports 1920 x 1440 @ 75 Hz
              - id: reserved_1_raw
                type: b4
                valid:
                  expr: _.as<u1> == 0b0000
              # Byte 12 .. 17
              - id: reserved_2_raw
                contents: [0x00, 0x00, 0x00, 0x00, 0x00, 0x00]
            doc-ref: "Section: 3.10.3.9 Established Timings III Descriptor Definition"

          dummy_descriptor:
            seq:
              - id: reserved_raw
                type: u1
                valid: 0x00
              - id: padding
                contents: [0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00]
                doc: Padding data.
                # TODO: Maybe accept invalid payload which seems to happen in the wild?
            doc-ref: "Section: 3.10.3.11 Dummy Descriptor Definition"

          manufacturer_specified_descriptor:
            seq:
              - id: reserved_raw
                type: u1
                valid: 0x00
              - id: data
                size: 13
                doc: Manufacturer specified proprietary data.
            doc-ref: "Section: 3.10.3.12 Manufacturer Specified Data"

          unknown_descriptor:
            seq:
              - id: data_raw
                # Just read 14 bytes of raw data
                size: 14

enums:
  video_signal_type:
    0: analog
    1: digital
