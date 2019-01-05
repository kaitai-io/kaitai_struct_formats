meta:
  id: ttf
  file-extension: ttf
  title: TrueType Font File
  xref:
    justsolve: TrueType
    pronom: x-fmt/453
    wikidata: Q751800
  license: MIT
  endian: be
doc: |
  A TrueType font file contains data, in table format, that comprises
  an outline font.
doc-ref: https://www.microsoft.com/typography/tt/ttf_spec/ttch02.doc
seq:
  - id: offset_table
    type: offset_table
  - id: directory_table
    type: dir_table_entry
    repeat: expr
    repeat-expr: offset_table.num_tables
types:
  fixed:
    seq:
      - id: major
        type: u2
      - id: minor
        type: u2
    -webide-representation: '{major:dec}.{minor:dec}'
  offset_table:
    seq:
      - id: sfnt_version
        type: fixed
      - id: num_tables
        type: u2
      - id: search_range
        type: u2
      - id: entry_selector
        type: u2
      - id: range_shift
        type: u2
  dir_table_entry:
    seq:
      - id: tag
        type: str
        size: 4
        encoding: ascii
      - id: checksum
        type: u4
      - id: offset
        type: u4
      - id: length
        type: u4
    instances:
      value:
        size: length
        io: _root._io
        pos: offset
        type:
          switch-on: tag
          cases:
            "'cmap'": cmap
            "'cvt '": cvt
            "'glyf'": glyf
            "'head'": head
            "'hhea'": hhea
            "'OS/2'": os2
            "'prep'": prep
            "'fpgm'": fpgm
            "'kern'": kern
            "'maxp'": maxp
            "'post'": post
            "'name'": name
        -webide-parse-mode: eager
    -webide-representation: '{tag} [{length:dec}b]: {value}'
  cmap:
    doc: >
      cmap - Character To Glyph Index Mapping Table
      This table defines the mapping of character codes to the glyph index values used in the font.
    seq:
      - id: version_number
        type: u2
      - id: number_of_encoding_tables
        type: u2
      - id: tables
        type: subtable_header
        repeat: expr
        repeat-expr: number_of_encoding_tables
    -webide-represetation: "hello"
    types:
      subtable_header:
        seq:
          - id: platform_id
            type: u2
          - id: encoding_id
            type: u2
          - id: subtable_offset
            type: u4
        -webide-representation: "p:{platform_id:dec}, e:{encoding_id:dec}"
        instances:
          table:
            type: subtable
            io: _parent._io
            pos: subtable_offset
            -webide-parse-mode: eager
      subtable:
        seq:
          - id: format
            type: u2
            enum: subtable_format
          - id: length
            type: u2
          - id: version
            type: u2
          - id: value
            size: length - 6
            type:
              switch-on: format
              cases:
                subtable_format::byte_encoding_table: byte_encoding_table
                subtable_format::high_byte_mapping_through_table: high_byte_mapping_through_table
                subtable_format::segment_mapping_to_delta_values: segment_mapping_to_delta_values
                subtable_format::trimmed_table_mapping: trimmed_table_mapping
        enums:
          subtable_format:
            0: byte_encoding_table
            2: high_byte_mapping_through_table
            4: segment_mapping_to_delta_values
            6: trimmed_table_mapping
        types:
          byte_encoding_table:
            seq:
              - id: glyph_id_array
                size: 256
          high_byte_mapping_through_table:
            seq:
              - id: sub_header_keys
                type: u2
                repeat: expr
                repeat-expr: 256
              # TODO
          segment_mapping_to_delta_values:
            seq:
              - id: seg_count_x2
                type: u2
              - id: search_range
                type: u2
              - id: entry_selector
                type: u2
              - id: range_shift
                type: u2
              - id: end_count
                type: u2
                repeat: expr
                repeat-expr: seg_count
              - id: reserved_pad
                type: u2
              - id: start_count
                type: u2
                repeat: expr
                repeat-expr: seg_count
              - id: id_delta
                type: u2
                repeat: expr
                repeat-expr: seg_count
              - id: id_range_offset
                type: u2
                repeat: expr
                repeat-expr: seg_count
              - id: glyph_id_array
                type: u2
                repeat: eos
            instances:
              seg_count:
                value: seg_count_x2 / 2
                -webide-parse-mode: eager
          trimmed_table_mapping:
            seq:
              - id: first_code
                type: u2
              - id: entry_count
                type: u2
              - id: glyph_id_array
                type: u2
                repeat: expr
                repeat-expr: entry_count
  cvt:
    doc: >
      cvt  - Control Value Table
      This table contains a list of values that can be referenced by instructions.
      They can be used, among other things, to control characteristics for different glyphs.
    seq:
      - id: fwords
        type: s2
        repeat: eos
  glyf:
    # https://github.com/fonttools/fonttools/blob/678876325ef26ac33e8c6d13f4fb70c3bef5da8e/Lib/fontTools/ttLib/tables/_g_l_y_f.py
    # TODO: sadly, Kaitai currently cannot parse this structure
    seq:
      - id: number_of_contours
        type: s2
      - id: x_min
        type: s2
      - id: y_min
        type: s2
      - id: x_max
        type: s2
      - id: y_max
        type: s2
      - id: value
        type: simple_glyph
        if: number_of_contours > 0
    types:
      simple_glyph:
        seq:
          - id: end_pts_of_contours
            type: u2
            repeat: expr
            repeat-expr: _parent.number_of_contours
          - id: instruction_length
            type: u2
          - id: instructions
            size: instruction_length
          - id: flags
            type: flag
            repeat: expr
            repeat-expr: point_count
        instances:
          point_count:
            value: end_pts_of_contours.max + 1
        types:
          flag:
            seq:
              - id: reserved
                type: b2
              - id: y_is_same
                type: b1
              - id: x_is_same
                type: b1
              - id: repeat
                type: b1
              - id: y_short_vector
                type: b1
              - id: x_short_vector
                type: b1
              - id: on_curve
                type: b1
              - id: repeat_value
                type: u1
                if: repeat
  head:
    enums:
      flags:
        0x01: baseline_at_y0            # Bit 0 - baseline for font at y=0
        0x02: left_sidebearing_at_x0    # Bit 1 - left sidebearing at x=0
        0x04: flag_depend_on_point_size # Bit 2 - instructions may depend on point size
        0x08: flag_force_ppem           # Bit 3 - force ppem to integer values for all internal scaler math;
                                        #         may use fractional ppem sizes if this bit is clear
        0x10: flag_may_advance_width    # Bit 4 - instructions may alter advance width (the advance widths might not scale linearly)
      font_direction_hint:
        0: fully_mixed_directional_glyphs
        1: only_strongly_left_to_right
        2: strongly_left_to_right_and_neutrals
        #-1: only_strongly_right_to_left
        #-2: strongly_right_to_left_and_neutrals
    seq:
      - id: version
        type: fixed
      - id: font_revision
        type: fixed
      - id: checksum_adjustment
        type: u4
      - id: magic_number
        contents: [0x5F, 0x0F, 0x3C, 0xF5]
      - id: flags
        type: u2
        enum: flags
      - id: units_per_em
        type: u2
      - id: created
        type: u8
      - id: modified
        type: u8
      - id: x_min
        type: s2
      - id: y_min
        type: s2
      - id: x_max
        type: s2
      - id: y_max
        type: s2
      - id: mac_style
        type: u2
      - id: lowest_rec_ppem
        type: u2
      - id: font_direction_hint
        type: s2
        enum: font_direction_hint
      - id: index_to_loc_format
        type: s2
      - id: glyph_data_format
        type: s2
  hhea:
    seq:
      - id: version
        type: fixed
      - id: ascender
        type: s2
        doc: 'Typographic ascent'
      - id: descender
        type: s2
        doc: 'Typographic descent'
      - id: line_gap
        type: s2
        doc: 'Typographic line gap. Negative LineGap values are treated as zero in Windows 3.1, System 6, and System 7.'
      - id: advance_width_max
        type: u2
        doc: 'Maximum advance width value in `hmtx` table.'
      - id: min_left_side_bearing
        type: s2
        doc: 'Minimum left sidebearing value in `hmtx` table.'
      - id: min_right_side_bearing
        type: s2
        doc: 'Minimum right sidebearing value; calculated as Min(aw - lsb - (xMax - xMin)).'
      - id: x_max_extend
        type: s2
        doc: 'Max(lsb + (xMax - xMin)).'
      - id: caret_slope_rise
        type: s2
      - id: caret_slope_run
        type: s2
      - id: reserved
        contents: [0,0,0,0,0,0,0,0,0,0]
      - id: metric_data_format
        type: s2
      - id: number_of_hmetrics
        type: u2
  os2:
    doc: 'The OS/2 table consists of a set of metrics that are required by Windows and OS/2.'
    types:
      panose:
        enums:
          family_kind:
            0: any
            1: no_fit
            2: text_and_display
            3: script
            4: decorative
            5: pictorial
          serif_style:
            0: any
            1: no_fit
            2: cove
            3: obtuse_cove
            4: square_cove
            5: obtuse_square_cove
            6: square
            7: thin
            8: bone
            9: exaggerated
            10: triangle
            11: normal_sans
            12: obtuse_sans
            13: perp_sans
            14: flared
            15: rounded
          weight:
            0: any
            1: no_fit
            2: very_light
            3: light
            4: thin
            5: book
            6: medium
            7: demi
            8: bold
            9: heavy
            10: black
            11: nord
          proportion:
            0: any
            1: no_fit
            2: old_style
            3: modern
            4: even_width
            5: expanded
            6: condensed
            7: very_expanded
            8: very_condensed
            9: monospaced
          contrast:
            0: any
            1: no_fit
            2: none
            3: very_low
            4: low
            5: medium_low
            6: medium
            7: medium_high
            8: high
            9: very_high
          stroke_variation:
            0: any
            1: no_fit
            2: gradual_diagonal
            3: gradual_transitional
            4: gradual_vertical
            5: gradual_horizontal
            6: rapid_vertical
            7: rapid_horizontal
            8: instant_vertical
          arm_style:
            0: any
            1: no_fit
            2: straight_arms_horizontal
            3: straight_arms_wedge
            4: straight_arms_vertical
            5: straight_arms_single_serif
            6: straight_arms_double_serif
            7: non_straight_arms_horizontal
            8: non_straight_arms_wedge
            9: non_straight_arms_vertical
            10: non_straight_arms_single_serif
            11: non_straight_arms_double_serif
          letter_form:
            0: any
            1: no_fit
            2: normal_contact
            3: normal_weighted
            4: normal_boxed
            5: normal_flattened
            6: normal_rounded
            7: normal_off_center
            8: normal_square
            9: oblique_contact
            10: oblique_weighted
            11: oblique_boxed
            12: oblique_flattened
            13: oblique_rounded
            14: oblique_off_center
            15: oblique_square
          midline:
            0: any
            1: no_fit
            2: standard_trimmed
            3: standard_pointed
            4: standard_serifed
            5: high_trimmed
            6: high_pointed
            7: high_serifed
            8: constant_trimmed
            9: constant_pointed
            10: constant_serifed
            11: low_trimmed
            12: low_pointed
            13: low_serifed
          x_height:
            0: any
            1: no_fit
            2: constant_small
            3: constant_standard
            4: constant_large
            5: ducking_small
            6: ducking_standard
            7: ducking_large
        seq:
          - id: family_type
            type: u1
            enum: family_kind
          - id: serif_style
            type: u1
            enum: serif_style
          - id: weight
            type: u1
            enum: weight
          - id: proportion
            type: u1
            enum: proportion
          - id: contrast
            type: u1
            enum: contrast
          - id: stroke_variation
            type: u1
            enum: stroke_variation
          - id: arm_style
            type: u1
            enum: arm_style
          - id: letter_form
            type: u1
            enum: letter_form
          - id: midline
            type: u1
            enum: midline
          - id: x_height
            type: u1
            enum: x_height
      unicode_range:
        seq:
          - { id: basic_latin, type: b1 }
          - { id: latin_1_supplement, type: b1 }
          - { id: latin_extended_a, type: b1 }
          - { id: latin_extended_b, type: b1 }
          - { id: ipa_extensions, type: b1 }
          - { id: spacing_modifier_letters, type: b1 }
          - { id: combining_diacritical_marks, type: b1 }
          - { id: basic_greek, type: b1 }
          - { id: greek_symbols_and_coptic, type: b1 }
          - { id: cyrillic, type: b1 }
          - { id: armenian, type: b1 }
          - { id: basic_hebrew, type: b1 }
          - { id: hebrew_extended, type: b1 }
          - { id: basic_arabic, type: b1 }
          - { id: arabic_extended, type: b1 }
          - { id: devanagari, type: b1 }
          - { id: bengali, type: b1 }
          - { id: gurmukhi, type: b1 }
          - { id: gujarati, type: b1 }
          - { id: oriya, type: b1 }
          - { id: tamil, type: b1 }
          - { id: telugu, type: b1 }
          - { id: kannada, type: b1 }
          - { id: malayalam, type: b1 }
          - { id: thai, type: b1 }
          - { id: lao, type: b1 }
          - { id: basic_georgian, type: b1 }
          - { id: georgian_extended, type: b1 }
          - { id: hangul_jamo, type: b1 }
          - { id: latin_extended_additional, type: b1 }
          - { id: greek_extended, type: b1 }
          - { id: general_punctuation, type: b1 }
          - { id: superscripts_and_subscripts, type: b1 }
          - { id: currency_symbols, type: b1 }
          - { id: combining_diacritical_marks_for_symbols, type: b1 }
          - { id: letterlike_symbols, type: b1 }
          - { id: number_forms, type: b1 }
          - { id: arrows, type: b1 }
          - { id: mathematical_operators, type: b1 }
          - { id: miscellaneous_technical, type: b1 }
          - { id: control_pictures, type: b1 }
          - { id: optical_character_recognition, type: b1 }
          - { id: enclosed_alphanumerics, type: b1 }
          - { id: box_drawing, type: b1 }
          - { id: block_elements, type: b1 }
          - { id: geometric_shapes, type: b1 }
          - { id: miscellaneous_symbols, type: b1 }
          - { id: dingbats, type: b1 }
          - { id: cjk_symbols_and_punctuation, type: b1 }
          - { id: hiragana, type: b1 }
          - { id: katakana, type: b1 }
          - { id: bopomofo, type: b1 }
          - { id: hangul_compatibility_jamo, type: b1 }
          - { id: cjk_miscellaneous, type: b1 }
          - { id: enclosed_cjk_letters_and_months, type: b1 }
          - { id: cjk_compatibility, type: b1 }
          - { id: hangul, type: b1 }
          - { id: reserved_for_unicode_subranges1, type: b1 }
          - { id: reserved_for_unicode_subranges2, type: b1 }
          - { id: cjk_unified_ideographs, type: b1 }
          - { id: private_use_area, type: b1 }
          - { id: cjk_compatibility_ideographs, type: b1 }
          - { id: alphabetic_presentation_forms, type: b1 }
          - { id: arabic_presentation_forms_a, type: b1 }
          - { id: combining_half_marks, type: b1 }
          - { id: cjk_compatibility_forms, type: b1 }
          - { id: small_form_variants, type: b1 }
          - { id: arabic_presentation_forms_b, type: b1 }
          - { id: halfwidth_and_fullwidth_forms, type: b1 }
          - { id: specials, type: b1 }
          - { id: reserved, size: 7 }
      # TODO: is this correct?
      code_page_range:
        seq:
          - { id: symbol_character_set, type: b1 }
          - { id: oem_character_set, type: b1 }
          - { id: macintosh_character_set, type: b1 }
          - { id: reserved_for_alternate_ansi_oem, type: b7 }
          - { id: cp1361_korean_johab, type: b1 }
          - { id: cp950_chinese_traditional_chars_taiwan_and_hong_kong, type: b1 }
          - { id: cp949_korean_wansung, type: b1 }
          - { id: cp936_chinese_simplified_chars_prc_and_singapore, type: b1 }
          - { id: cp932_jis_japan, type: b1 }
          - { id: cp874_thai, type: b1 }
          - { id: reserved_for_alternate_ansi, type: b8 }
          - { id: cp1257_windows_baltic, type: b1 }
          - { id: cp1256_arabic, type: b1 }
          - { id: cp1255_hebrew, type: b1 }
          - { id: cp1254_turkish, type: b1 }
          - { id: cp1253_greek, type: b1 }
          - { id: cp1251_cyrillic, type: b1 }
          - { id: cp1250_latin_2_eastern_europe, type: b1 }
          - { id: cp1252_latin_1, type: b1 }
          - { id: cp437_us, type: b1 }
          - { id: cp850_we_latin_1, type: b1 }
          - { id: cp708_arabic_asmo_708, type: b1 }
          - { id: cp737_greek_former_437_g, type: b1 }
          - { id: cp775_ms_dos_baltic, type: b1 }
          - { id: cp852_latin_2, type: b1 }
          - { id: cp855_ibm_cyrillic_primarily_russian, type: b1 }
          - { id: cp857_ibm_turkish, type: b1 }
          - { id: cp860_ms_dos_portuguese, type: b1 }
          - { id: cp861_ms_dos_icelandic, type: b1 }
          - { id: cp862_hebrew, type: b1 }
          - { id: cp863_ms_dos_canadian_french, type: b1 }
          - { id: cp864_arabic, type: b1 }
          - { id: cp865_ms_dos_nordic, type: b1 }
          - { id: cp866_ms_dos_russian, type: b1 }
          - { id: cp869_ibm_greek, type: b1 }
          - { id: reserved_for_oem, type: b16 }
    enums:
      weight_class:
        100: thin
        200: extra_light
        300: light
        400: normal
        500: medium
        600: semi_bold
        700: bold
        800: extra_bold
        900: black
      width_class:
        1: ultra_condensed
        2: extra_condensed
        3: condensed
        4: semi_condensed
        5: normal
        6: semi_expanded
        7: expanded
        8: extra_expanded
        9: ultra_expanded
      fs_type:
        # Restricted License embedding: When only this bit is set, this font may
        # not be embedded, copied or modified.
        2: restricted_license_embedding
        # Preview & Print embedding: When this bit is set, the font may be embedded,
        # and temporarily loaded on the remote system. Documents containing Preview
        # & Print fonts must be opened “read-only;” no edits can be applied to the document.
        4: preview_and_print_embedding
        # Editable embedding: When this bit is set, the font may be embedded and
        # temporarily loaded on other systems. Documents containing Editable fonts
        # may be opened for reading and writing.
        8: editable_embedding
      fs_selection:
        0x01: italic
        0x02: underscore
        0x04: negative
        0x08: outlined
        0x10: strikeout
        0x20: bold
        0x40: regular
    seq:
      - id: version
        type: u2
        doc: 'The version number for this OS/2 table.'
      - id: x_avg_char_width
        type: s2
        doc: >
          The Average Character Width parameter specifies the arithmetic average of the escapement (width)
          of all of the 26 lowercase letters a through z of the Latin alphabet and the space character.
          If any of the 26 lowercase letters are not present, this parameter should equal the weighted average
          of all glyphs in the font. For non-UGL (platform 3, encoding 0) fonts, use the unweighted average.
      - id: weight_class
        type: u2
        enum: weight_class
        doc: >
          Indicates the visual weight (degree of blackness or thickness of strokes)
          of the characters in the font.
      - id: width_class
        type: u2
        enum: width_class
        doc: >
          Indicates a relative change from the normal aspect ratio (width to height ratio)
          as specified by a font designer for the glyphs in a font.
      - id: fs_type
        type: s2
        enum: fs_type
        doc: >
          Indicates font embedding licensing rights for the font.
          Embeddable fonts may be stored in a document.
          When a document with embedded fonts is opened on a system that does
          not have the font installed (the remote system), the embedded font
          may be loaded for temporary (and in some cases, permanent) use on that
          system by an embedding-aware application. Embedding licensing rights are
          granted by the vendor of the font.
      - id: y_subscript_x_size
        type: s2
        doc: 'The recommended horizontal size in font design units for subscripts for this font.'
      - id: y_subscript_y_size
        type: s2
        doc: 'The recommended vertical size in font design units for subscripts for this font.'
      - id: y_subscript_x_offset
        type: s2
        doc: 'The recommended horizontal offset in font design untis for subscripts for this font.'
      - id: y_subscript_y_offset
        type: s2
        doc: 'The recommended vertical offset in font design units from the baseline for subscripts for this font.'
      - id: y_superscript_x_size
        type: s2
        doc: 'The recommended horizontal size in font design units for superscripts for this font.'
      - id: y_superscript_y_size
        type: s2
        doc: 'The recommended vertical size in font design units for superscripts for this font.'
      - id: y_superscript_x_offset
        type: s2
        doc: 'The recommended horizontal offset in font design units for superscripts for this font.'
      - id: y_superscript_y_offset
        type: s2
        doc: 'The recommended vertical offset in font design units from the baseline for superscripts for this font.'
      - id: y_strikeout_size
        type: s2
        doc: 'Width of the strikeout stroke in font design units.'
      - id: y_strikeout_position
        type: s2
        doc: 'The position of the strikeout stroke relative to the baseline in font design units.'
      - id: s_family_class
        type: s2
        doc: 'This parameter is a classification of font-family design.'
      - id: panose
        type: panose
      - id: unicode_range
        type: unicode_range
      - id: ach_vend_id
        type: str
        size: 4
        encoding: ascii
        doc: 'The four character identifier for the vendor of the given type face.'
      - id: selection
        type: u2
        enum: fs_selection
        doc: 'Contains information concerning the nature of the font patterns'
      - id: first_char_index
        type: u2
        doc: 'The minimum Unicode index (character code) in this font, according to the cmap subtable for platform ID 3 and encoding ID 0 or 1.'
      - id: last_char_index
        type: u2
        doc: 'The maximum Unicode index (character code) in this font, according to the cmap subtable for platform ID 3 and encoding ID 0 or 1.'
      - id: typo_ascender
        type: s2
        doc: 'The typographic ascender for this font.'
      - id: typo_descender
        type: s2
        doc: 'The typographic descender for this font.'
      - id: typo_line_gap
        type: s2
        doc: 'The typographic line gap for this font.'
      - id: win_ascent
        type: u2
        doc: 'The ascender metric for Windows.'
      - id: win_descent
        type: u2
        doc: 'The descender metric for Windows.'
      - id: code_page_range
        type: code_page_range
        doc: 'This field is used to specify the code pages encompassed by the font file in the `cmap` subtable for platform 3, encoding ID 1 (Microsoft platform).'
  prep:
    seq:
      - id: instructions
        size-eos: true
  fpgm:
    seq:
      - id: instructions
        size-eos: true
  kern:
    types:
      subtable:
        types:
          format0:
            types:
              kerning_pair:
                seq:
                  - id: left
                    type: u2
                  - id: right
                    type: u2
                  - id: value
                    type: s2
                -webide-representation: '{left:dec}+{right:dec}: {value:dec}'
            seq:
              - id: pair_count
                type: u2
              - id: search_range
                type: u2
              - id: entry_selector
                type: u2
              - id: range_shift
                type: u2
              - id: kerning_pairs
                type: kerning_pair
                repeat: expr
                repeat-expr: pair_count
        seq:
          - id: version
            type: u2
          - id: length
            type: u2
          - id: format
            type: u1
          - id: reserved
            type: b4
          - id: is_override
            type: b1
          - id: is_cross_stream
            type: b1
          - id: is_minimum
            type: b1
          - id: is_horizontal
            type: b1
          - id: format0
            type: format0
            if: format == 0
    seq:
      - id: version
        type: u2
      - id: subtable_count
        type: u2
      - id: subtables
        type: subtable
        repeat: expr
        repeat-expr: subtable_count
  maxp:
    seq:
      - id: table_version_number
        type: fixed
        doc: '0x00010000 for version 1.0.'
      - id: num_glyphs
        type: u2
        doc: 'The number of glyphs in the font.'
      - id: max_points
        type: u2
        doc: 'Maximum points in a non-composite glyph.'
      - id: max_contours
        type: u2
        doc: 'Maximum contours in a non-composite glyph.'
      - id: max_composite_points
        type: u2
        doc: 'Maximum points in a composite glyph.'
      - id: max_composite_contours
        type: u2
        doc: 'Maximum contours in a composite glyph.'
      - id: max_zones
        type: u2
        doc: '1 if instructions do not use the twilight zone (Z0), or 2 if instructions do use Z0; should be set to 2 in most cases.'
      - id: max_twilight_points
        type: u2
        doc: 'Maximum points used in Z0.'
      - id: max_storage
        type: u2
        doc: 'Number of Storage Area locations.'
      - id: max_function_defs
        type: u2
        doc: 'Number of FDEFs.'
      - id: max_instruction_defs
        type: u2
        doc: 'Number of IDEFs.'
      - id: max_stack_elements
        type: u2
        doc: 'Maximum stack depth.'
      - id: max_size_of_instructions
        type: u2
        doc: 'Maximum byte count for glyph instructions.'
      - id: max_component_elements
        type: u2
        doc: 'Maximum number of components referenced at "top level" for any composite glyph.'
      - id: max_component_depth
        type: u2
        doc: 'Maximum levels of recursion; 1 for simple components.'
  post:
    types:
      format20:
        types:
          pascal_string:
            seq:
              - id: length
                type: u1
              - id: value
                type: str
                size: length
                encoding: ascii
                if: length != 0
            -webide-representation: "{value}"
        seq:
          - id: number_of_glyphs
            type: u2
          - id: glyph_name_index
            type: u2
            repeat: expr
            repeat-expr: number_of_glyphs
          - id: glyph_names
            type: pascal_string
            repeat: until
            repeat-until: _.length == 0
    seq:
      - id: format
        type: fixed
      - id: italic_angle
        type: fixed
      - id: underline_position
        type: s2
      - id: underline_thichness
        type: s2
      - id: is_fixed_pitch
        type: u4
      - id: min_mem_type42
        type: u4
      - id: max_mem_type42
        type: u4
      - id: min_mem_type1
        type: u4
      - id: max_mem_type1
        type: u4
      - id: format20
        type: format20
        if: format.major == 2 and format.minor == 0
  name:
    doc: |
      Name table is meant to include human-readable string metadata
      that describes font: name of the font, its styles, copyright &
      trademark notices, vendor and designer info, etc.

      The table includes a list of "name records", each of which
      corresponds to a single metadata entry.
    doc-ref: https://developer.apple.com/fonts/TrueType-Reference-Manual/RM06/Chap6name.html
    types:
      name_record:
        seq:
          - id: platform_id
            -orig-id: platformID
            type: u2
            enum: platforms
          - id: encoding_id
            -orig-id: platformSpecificID
            type: u2
          - id: language_id
            -orig-id: languageID
            type: u2
          - id: name_id
            -orig-id: nameID
            type: u2
            enum: names
          - id: len_str
            -orig-id: length
            type: u2
          - id: ofs_str
            -orig-id: offset
            type: u2
        instances:
          ascii_value:
            type: str
            size: len_str
            encoding: ascii
            io: _parent._io
            pos: _parent.ofs_strings + ofs_str
            #if: encoding_id == 0
            -webide-parse-mode: eager
          unicode_value:
            type: str
            size: len_str
            encoding: utf-16be
            io: _parent._io
            pos: _parent.ofs_strings + ofs_str
            #if: encoding_id == 1
            -webide-parse-mode: eager
        -webide-representation: "{ascii_value}"
    seq:
      - id: format_selector
        -orig-id: format
        type: u2
      - id: num_name_records
        -orig-id: count
        type: u2
      - id: ofs_strings
        -orig-id: stringOffset
        type: u2
      - id: name_records
        -orig-id: nameRecord
        type: name_record
        repeat: expr
        repeat-expr: num_name_records
    enums:
      platforms:
        0: unicode
        1: macintosh
        2: reserved_2
        3: microsoft
      names:
        0: copyright
        1: font_family
        2: font_subfamily
        3: unique_subfamily_id
        4: full_font_name
        5: name_table_version
        6: postscript_font_name
        7: trademark
        8: manufacturer
        9: designer
        10: description
        11: url_vendor
        12: url_designer
        13: license
        14: url_license
        15: reserved_15
        16: preferred_family
        17: preferred_subfamily
        18: compatible_full_name
        19: sample_text
