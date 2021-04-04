meta:
  id: pcf_font
  title: Portable Compiled Format (PCF) font
  file-extension: pcf
  xref:
    justsolve: PCF
    wikidata: Q3398726
  license: CC0-1.0
  ks-version: 0.9
  imports:
    - /common/bytes_with_io
  encoding: UTF-8
  endian: le
doc: |
  Portable Compiled Format (PCF) font is a bitmap font format
  originating from X11 Window System. It matches BDF format (which is
  text-based) closely, but instead being binary and
  platform-independent (as opposed to previously used SNF binary
  format) due to introduced features to handle different endianness
  and bit order.

  The overall composition of the format is straightforward: it's more
  or less classic directory of type-offset-size pointers, pointing to
  what PCF format calls "tables". Each table carries a certain
  piece of information related to the font (metadata properties,
  metrics, bitmaps, mapping of glyphs to characters, etc).
doc-ref: https://fontforge.org/docs/techref/pcf-format.html
seq:
  - id: magic
    -orig-id: header
    contents: [0x1, "fcp"]
  - id: num_tables
    -orig-id: table_count
    type: u4
  - id: tables
    type: table
    repeat: expr
    repeat-expr: num_tables
types:
  table:
    doc: |
      Table offers a offset + length pointer to a particular
      table. "Type" of table references certain enum. Applications can
      ignore enum values which they don't support.
    -webide-representation: "{type}"
    seq:
      - id: type
        type: u4
        enum: types
      - id: format
        type: format
      - id: len_body
        -orig-id: size
        type: u4
      - id: ofs_body
        -orig-id: offset
        type: u4
    instances:
      body:
        pos: ofs_body
        size: len_body
        type:
          switch-on: type
          cases:
            'types::properties': properties
            # TODO: accelerators
            # TODO: metrics
            # TODO: ink_metrics
            'types::bitmaps': bitmaps
            'types::bdf_encodings': bdf_encodings
            'types::swidths': swidths
            'types::glyph_names': glyph_names
            # TODO: bdf_accelerators
    types:
      properties:
        doc: |
          Array of properties (key-value pairs), used to convey different X11
          settings of a font. Key is always an X font atom.
        doc-ref: 'https://fontforge.org/docs/techref/pcf-format.html#properties-table'
        -webide-representation: "{num_props:dec} properties"
        seq:
          - id: format
            type: format
          - id: num_props
            type: u4
          - id: props
            type: prop
            repeat: expr
            repeat-expr: num_props
          - id: padding
            size: '(num_props & 3) == 0 ? 0 : (4 - (num_props & 3))'
            # In reality: align to next 4-byte boundary
          - id: len_strings
            type: u4
          - id: strings
            size: len_strings
            type: bytes_with_io
            doc: |
              Strings buffer. Never used directly, but instead is
              addressed by offsets from the properties.
        types:
          prop:
            doc: |
              Property is a key-value pair, "key" being always a
              string and "value" being either a string or a 32-bit
              integer based on an additinal flag (`is_string`).

              Simple offset-based mechanism is employed to keep this
              type's sequence fixed-sized and thus have simple access
              to property key/value by index.
            -webide-representation: "{name} => {str_value}/{int_value}"
            seq:
              - id: ofs_name
                type: u4
                doc: Offset to name in the strings buffer.
              - id: is_string
                -orig-id: isStringProp
                type: u1
                doc: |
                  Designates if value is an integer (zero) or a string (non-zero).
              - id: value_or_ofs_value
                type: u4
                doc: |
                  If the value is an integer (`is_string` is false),
                  then it's stored here. If the value is a string
                  (`is_string` is true), then it stores offset to the
                  value in the strings buffer.
            instances:
              name:
                io: _parent.strings._io
                pos: ofs_name
                type: strz
                doc: |
                  Name of the property addressed in the strings buffer.
                -webide-parse-mode: eager
              str_value:
                io: _parent.strings._io
                pos: value_or_ofs_value
                type: strz
                if: is_string != 0
                doc: |
                  Value of the property addressed in the strings
                  buffer, if this is a string value.
                -webide-parse-mode: eager
              int_value:
                value: value_or_ofs_value
                if: is_string == 0
                doc: |
                  Value of the property, if this is an integer value.
                -webide-parse-mode: eager

              # As of Kaitai Struct 0.9, `value` fails with:
              #
              #     "can't combine output types: StrFromBytesType(BytesTerminatedType(0,false,true,true,None),UTF-8) vs IntMultiType(false,Width4,Some(LittleEndian))"
              #
              # ... so currently it's commented out.

              #value:
              #  value: '(is_string != 0) ? str_value : int_value'
      bitmaps:
        doc: |
          Table containing uncompressed glyph bitmaps.
        doc-ref: 'https://fontforge.org/docs/techref/pcf-format.html#the-bitmap-table'
        seq:
          - id: format
            type: format
          - id: num_glyphs
            -orig-id: glyph_count
            type: u4
          - id: offsets
            type: u4
            repeat: expr
            repeat-expr: num_glyphs
          - id: bitmap_sizes
            type: u4
            repeat: expr
            repeat-expr: 4
      bdf_encodings:
        doc: |
          Table that allows mapping of character codes to glyphs present in the
          font. Supports 1-byte and 2-byte character codes.

          Note that this mapping is agnostic to character encoding itself - it
          can represent ASCII, Unicode (ISO/IEC 10646), various single-byte
          national encodings, etc. If application cares about it, normally
          encoding will be specified in `properties` table, in the properties named
          `CHARSET_REGISTRY` / `CHARSET_ENCODING`.
        doc-ref: 'https://fontforge.org/docs/techref/pcf-format.html#the-encoding-table'
        seq:
          - id: format
            type: format
          - id: min_char_or_byte2
            type: u2
          - id: max_char_or_byte2
            type: u2
          - id: min_byte1
            type: u2
          - id: max_byte1
            type: u2
          - id: default_char
            type: u2
          - id: glyph_indexes
            -orig-id: glyphindeces
            type: u2
            repeat: expr
            repeat-expr: (max_char_or_byte2 - min_char_or_byte2 + 1) * (max_byte1 - min_byte1 + 1)
      swidths:
        doc: |
          Table containing scalable widths of characters.
        doc-ref: 'https://fontforge.org/docs/techref/pcf-format.html#the-scalable-widths-table'
        -webide-representation: '{num_glyphs:dec} glyphs'
        seq:
          - id: format
            type: format
          - id: num_glyphs
            type: u4
          - id: swidths
            type: u4
            repeat: expr
            repeat-expr: num_glyphs
            doc: |
              The scalable width of a character is the width of the corresponding
              PostScript character in em-units (1/1000ths of an em).
      glyph_names:
        doc: |
          Table containing character names for every glyph.
        doc-ref: 'https://fontforge.org/docs/techref/pcf-format.html#the-glyph-names-table'
        -webide-representation: '{num_glyphs:dec} glyphs'
        seq:
          - id: format
            type: format
          - id: num_glyphs
            type: u4
          - id: names
            type: string_ref
            repeat: expr
            repeat-expr: num_glyphs
            doc: |
              Glyph names are represented as string references in strings buffer.
          - id: len_strings
            -orig-id: string_size
            type: u4
          - id: strings
            size: len_strings
            type: bytes_with_io
            doc: |
              Strings buffer which contains all glyph names.
        types:
          string_ref:
            -webide-representation: '{value}'
            seq:
              - id: ofs_string
                type: u4
            instances:
              value:
                io: _parent.strings._io
                pos: ofs_string
                type: strz
                -webide-parse-mode: eager
  format:
    doc: |
      Table format specifier, always 4 bytes. Original implementation treats
      it as always little-endian and makes liberal use of bitmasking to parse
      various parts of it.

      TODO: this format specification recognizes endianness and bit
      order format bits, but it does not really takes any parsing
      decisions based on them.
    doc-ref: 'https://fontforge.org/docs/techref/pcf-format.html#file-header'
    seq:
      - id: padding1
        type: b2
      - id: scan_unit_mask
        type: b2
      - id: is_most_significant_bit_first
        -orig-id: PCF_BYTE_MASK
        type: b1
      - id: is_big_endian
        -orig-id: PCF_BYTE_MASK
        type: b1
        doc: If set, then all integers in the table are treated as big-endian
      - id: glyph_pad_mask
        type: b2
        -orig-id: PCF_GLYPH_PAD_MASK
      - id: format
        type: u1
      - id: padding
        type: u2
enums:
  types:
    1:
      id: properties
      -orig-id: PCF_PROPERTIES
    2:
      id: accelerators
      -orig-id: PCF_ACCELERATORS
    4:
      id: metrics
      -orig-id: PCF_METRICS
    8:
      id: bitmaps
      -orig-id: PCF_BITMAPS
    0x10:
      id: ink_metrics
      -orig-id: PCF_INK_METRICS
    0x20:
      id: bdf_encodings
      -orig-id: PCF_BDF_ENCODINGS
    0x40:
      id: swidths
      -orig-id: PCF_SWIDTHS
    0x80:
      id: glyph_names
      -orig-id: PCF_GLYPH_NAMES
    0x100:
      id: bdf_accelerators
      -orig-id: PCF_BDF_ACCELERATORS
