meta:
  id: allegro_dat
  title: Allegro data file
  application: Allegro library (v2.2-v4.4)
  license: CC0-1.0
  encoding: UTF-8
  endian: be
doc: |
  Allegro library for C (mostly used for game and multimedia apps
  programming) used its own container file format.

  In general, it allows storage of arbitrary binary data blocks
  bundled together with some simple key-value style metadata
  ("properties") for every block. Allegro also pre-defines some simple
  formats for bitmaps, fonts, MIDI music, sound samples and
  palettes. Allegro library v4.0+ also support LZSS compression.

  This spec applies to Allegro data files for library versions 2.2 up
  to 4.4.
doc-ref: https://liballeg.org/stabledocs/en/datafile.html
seq:
  - id: pack_magic
    type: u4
    enum: pack_enum
  - id: dat_magic
    contents: ALL.
  - id: num_objects
    type: u4
  - id: objects
    type: dat_object
    repeat: expr
    repeat-expr: num_objects
types:
  dat_object:
    seq:
      - id: properties
        type: property
        repeat: until
        repeat-until: 'not _.is_valid'
      - id: len_compressed
        type: s4
      - id: len_uncompressed
        type: s4
      - id: body
        size: len_compressed
        type:
          switch-on: type
          cases:
            '"BMP "': dat_bitmap
            '"RLE "': dat_rle_sprite
            '"FONT"': dat_font
    instances:
      type:
        value: properties.last.magic
  property:
    seq:
      - id: magic
        size: 4
        type: str
      - id: type
        size: 4
        type: str
        if: is_valid
      - id: len_body
        type: u4
        if: is_valid
      - id: body
        size: len_body
        type: str
        if: is_valid
    instances:
      is_valid:
        value: 'magic == "prop"'
  dat_bitmap:
    seq:
      - id: bits_per_pixel
        type: s2
      - id: width
        type: u2
      - id: height
        type: u2
      - id: image
        size-eos: true
  dat_rle_sprite:
    seq:
      - id: bits_per_pixel
        type: s2
      - id: width
        type: u2
      - id: height
        type: u2
      - id: len_image
        type: u4
      - id: image
        size-eos: true
  dat_font:
    seq:
      - id: font_size
        type: s2
      - id: body
        type:
          switch-on: font_size
          cases:
            8: dat_font_8
            16: dat_font_16
#            -1: dat_font_proportional
            0: dat_font_3_9
  dat_font_8:
    doc: |
      Simple monochrome monospaced font, 95 characters, 8x8 px
      characters.
    seq:
      - id: chars
        size: 8
        repeat: expr
        repeat-expr: 95
  dat_font_16:
    doc: |
      Simple monochrome monospaced font, 95 characters, 8x16 px
      characters.
    seq:
      - id: chars
        size: 16
        repeat: expr
        repeat-expr: 95
  dat_font_3_9:
    doc: |
      New bitmap font format introduced since Allegro 3.9: allows
      flexible designation of character ranges, 8-bit colored
      characters, etc.
    seq:
      - id: num_ranges
        type: s2
      - id: ranges
        type: range
        repeat: expr
        repeat-expr: num_ranges
    types:
      range:
        seq:
          - id: mono
            type: u1
          - id: start_char
            type: u4
            doc: First character in range
          - id: end_char
            type: u4
            doc: Last character in range (inclusive)
          - id: chars
            type: font_char
            repeat: expr
            repeat-expr: end_char - start_char + 1
      font_char:
        seq:
          - id: width
            type: u2
          - id: height
            type: u2
          - id: body
            size: width * height
enums:
  pack_enum:
    0x736c682e: unpacked
