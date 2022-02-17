meta:
  id: xara
  title: XARA
  license: CC0-1.0
  ks-version: 0.9
  encoding: ascii
  endian: le
doc-ref:
 - https://en.wikipedia.org/wiki/Xar_(graphics)
 - http://site.xara.com/support/docs/webformat/spec/XARFormatDocument.pdf
seq:
  - id: header
    type: header
  - id: records
    type: record
    repeat: until
    repeat-until: _.tag == tags::end_of_file or _.tag == tags::start_compression
types:
  header:
    seq:
      - id: magic
        contents: "XARA"
      - id: magic2
        contents: [0xa3, 0xa3, 0x0d, 0x0a]
  record:
    seq:
      - id: tag
        type: u4
        enum: tags
      - id: len_data
        type: u4
      - id: data
        size: len_data
        type:
          switch-on: tag
          cases:
            tags::file_header: file_header
            tags::document_nudge: document_nudge
            tags::document_bitmap_smoothing: document_bitmap_smoothing
            tags::duplication_offset: duplication_offset
            tags::start_compression: start_compression
  file_header:
    seq:
      - id: filetype
        size: 3
      - id: len_file
        type: u4
      - id: weblink
        type: u4
      - id: refinement_flags
        type: u4
      - id: producer
        type: strz
      - id: producer_version
        type: strz
      - id: producer_build
        type: strz
  document_nudge:
    seq:
      - id: millipoint
        type: u4
  document_bitmap_smoothing:
    seq:
      - id: flags
        type: u1
      - id: reserved
        contents: [0, 0, 0, 0]
    instances:
      enable_bitmap_smoothing:
        value: flags & 0x1
  duplication_offset:
    seq:
      - id: coords
        size: 8
  start_compression:
    seq:
      - id: version
        size: 3
      - id: format
        type: u1
        enum: compression
enums:
  tags:
    0: up
    1: down
    2: file_header
    3: end_of_file
    10: atomic_tags
    11: essential_tags
    12: tag_description
    30: start_compression
    31: end_compression
    40: document
    41: chapter
    42: spread
    43: layer
    44: page
    45: spread_information
    46: grid_ruler_settings
    47: grid_ruler_origin
    48: layer_details
    49: guide_layer_details
    50: define_rgb_colour
    51: define_complex_colour
    52: spread_scaling_active
    53: spread_scaling_inactive
    60: reserved60
    61: preview_bitmap_gif
    62: preview_bitmap_jpeg
    63: preview_bitmap_png
    64: reserved64
    65: reserved65
    66: reserved66
    67: define_bitmap_jpeg
    68: define_bitmap_png
    69: reserved69
    70: reserved70
    71: define_bitmap_jpeg8bpp
    80: viewport
    81: view_quality
    82: document_view
    85: define_prefix_user_unit
    86: define_suffix_user_unit
    87: define_default_units
    90: document_comment
    91: document_dates
    92: document_undo_size
    93: document_flags
    100: path
    101: path_filled
    102: path_stroked
    103: path_filled_stroked
    104: group
    105: blend
    106: blender
    107: mould_envelope
    108: mould_perspective
    109: mould_group
    110: mould_path
    111: path_flags
    112: guideline
    113: path_relative
    114: path_relative_filled
    115: path_relative_stroked
    116: path_relative_filled_striked
    117: reserved117
    118: pathref_transform
    150: flat_fill
    151: line_colour
    152: line_width
    153: linear_fill
    154: circular_fill
    155: elliptical_fill
    156: conical_fill
    157: bitmap_fill
    158: contone_bitmap_fill
    159: fractal_fill
    160: fill_effect_fade
    161: fill_effect_rainbow
    162: fill_effect_alt_rainbow
    163: fill_repeating
    164: fill_non_repeating
    165: fill_repeating_inverted
    166: flat_transparent_fill
    167: linear_transparent_fill
    168: circular_transparent_fill
    169: ellipitcal_transparent_fill
    170: conical_transparent_fill
    171: bitmap_transparent_fill
    172: fractal_transparent_fill
    173: line_transparency
    174: start_cap
    175: end_cap
    176: join_style
    177: mitre_limit
    178: winding_rule
    179: quality
    180: transparent_fill_repeating
    181: transparent_fill_non_repeating
    182: transparent_fill_repeating_inverted
    183: dash_style
    184: define_dash
    185: arrow_head
    186: arrow_tail
    187: define_arrow
    188: define_dash_scaled
    189: user_value
    190: flat_fill_none
    191: flat_fill_black
    192: flat_fill_white
    193: line_colour_none
    194: line_colour_black
    195: line_colour_white
    198: node_bitmap
    199: node_contoned_bitmap
    200: diamond_fill
    201: diamond_transparent_fill
    202: three_col_fill
    203: three_col_transparent_fill
    204: four_col_fill
    205: four_col_transparent_fill
    206: fill_repeating_extra
    207: transparent_fill_repeating_extra
    1000: ellipse_simple
    1001: ellipse_complex
    1100: rectangle_simple
    1101: rectangle_simple_reformed
    1102: rectangle_simple_stellated
    1103: rectangle_simple_stellated_reformed
    1104: rectangle_simple_rounded
    1105: rectangle_simple_rounded_reformed
    1106: rectangle_simple_rounded_stellated
    1107: rectangle_simple_rounded_stellated_reformed
    1108: rectangle_complex
    1109: rectangle_complex_reformed
    1110: rectangle_complex_stellated
    1111: rectangle_complex_stellated_reformed
    1112: rectangle_complex_rounded
    1113: rectangle_complex_rounded_reformed
    1114: rectangle_complex_rounded_stellated
    1115: rectangle_complex_rounded_stellated_reformed
    1200: polygon_complex
    1201: polygon_complex_reformed
    1212: polygon_complex_stellated
    1213: polygon_complex_stellated_reformed
    1214: polygon_complex_rounded
    1215: polygon_complex_rounded_reformed
    1216: polygon_complex_rounded_stellated
    1217: polygon_complex_rounded_stellated_reformed
    1900: regular_shape_phase_1
    1901: regular_shape_phase_2
    2000: font_def_truetype
    2001: font_def_atm
    2100: text_story_simple
    2101: text_story_complex
    2110: text_story_simple_start_left
    2111: text_story_simple_start_right
    2112: text_story_simple_end_left
    2113: text_story_simple_end_right
    2114: text_story_complex_start_left
    2115: text_story_complex_start_right
    2116: text_story_complex_end_left
    2117: text_story_complex_end_right
    2150: text_story_word_wrap_info
    2151: text_story_indent_info
    2200: text_line
    2201: text_string
    2202: text_char
    2203: text_eol
    2204: text_kern
    2205: text_caret
    2206: text_line_info
    2900: text_linespace_ratio
    2901: text_linespace_absolute
    2902: text_justification_left
    2903: text_justification_centre
    2904: text_justification_right
    2905: text_justification_full
    2906: text_font_size
    2907: text_font_typeface
    2908: text_bold_on
    2909: text_bold_off
    2910: text_italic_on
    2911: text_italic_off
    2912: text_underline_on
    2913: text_underline_off
    2914: text_script_on
    2915: text_script_off
    2916: text_superscript_on
    2917: text_superscript_off
    2918: text_tracking
    2919: text_aspect_ratio
    2920: text_baseline
    3500: overprint_line_on
    3501: overprint_line_off
    3502: overprint_fill_on
    3503: overprint_fill_off
    3504: print_on_all_plates_on
    3505: print_on_all_plates_off
    3506: printer_settings
    3507: image_setting
    3508: colour_plate
    3509: print_mark_default
    3510: reserved3510
    4000: variable_width_func
    4001: variable_width_table
    4002: stroke_type
    4003: stroke_definition
    4004: stroke_airbrush
    4010: noise_fill
    4011: noise_transparent_fill
    4012: mould_bounds
    4015: export_hint
    4020: web_address
    4021: web_address_bounding_box
    4030: layer_frame_props
    4031: spread_anim_props
    4040: wizop
    4041: wizop_style
    4042: wizop_style_ref
    4050: shadow_controller
    4051: shadow
    4052: bevel
    4053: bev_attr_indent
    4054: bev_attr_light_angle
    4055: bev_attr_light_contrast
    4056: bev_attr_type
    4057: bevel_link
    4060: blender_curve_prop
    4061: blend_path
    4062: blender_curve_angles
    4066: contour_controller
    4067: contour
    4070: set_sentinel
    4071: set_property
    4072: blend_profiles
    4073: blender_additional
    4074: node_blend_path_filled
    4075: linear_fill_multi_stage
    4076: circular_fill_multistage
    4077: elliptical_fill_multistage
    4078: conical_fill_multistage
    4079: brush_attr
    4080: brush_definition
    4081: brush_data
    4082: more_brush_data
    4083: more_brush_attr
    4084: clip_view_controller
    4085: clip_view
    4086: feather
    4087: bar_property
    4088: square_fill_multi_stage
    4102: even_more_brush_data
    4103: even_more_brush_attr
    4104: time_stamp_brush_data
    4105: brush_pressure_info
    4106: brush_pressure_data
    4107: brush_attr_pressure_info
    4108: brush_colour_data
    4109: brush_pressure_sample_data
    4110: brush_time_sample_data
    4111: brush_attr_fill_flags
    4112: brush_transp_info
    4113: brush_attr_transp_info
    4114: document_nudge
    4115: bitmap_properties
    4116: document_bitmap_smoothing
    4117: xpe_bitmap_properties
    4118: define_bitmap_xpe
    4119: current_attributes
    4120: current_attribute_bounds
    4121: linear_fill_3point
    4122: linear_fill_multistage_3point
    4123: linear_transparent_fill_3point
    4124: duplication_offset
    4125: live_effect
    4126: locked_effect
    4127: feather_effect
    4128: compound_render
    4129: object_bounds
    4131: spread_phase2
    4132: current_attributes_phase2
    4134: spread_flash_props
    4135: printer_settings_phase2
    4136: document_information
    4137: clipview_path
    4138: define_bitmap_png_real
    4139: text_string_pos
    4140: spread_flash_props2
    4141: text_linespace_leading
    4200: text_tab
    4201: text_left_indent
    4202: text_first_indent
    4203: text_right_indent
    4204: text_ruler
    4205: text_story_height_info
    4206: text_story_link_info
    4207: text_story_translation_info
    4208: text_space_before
    4209: text_space_after
    4210: text_special_hyphen
    4211: text_soft_return
    4212: text_extra_font_info
    4213: text_extra_tt_font_def
    4214: text_extra_atm_font_def
  compression:
    0: zlib
