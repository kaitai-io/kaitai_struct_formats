meta:
  id: pcx
  file-extension: pcx
  endian: le
  license: CC0-1.0
seq:
  - id: hdr
    type: header
    size: 128
instances:
  palette_256:
    doc-ref: http://web.archive.org/web/20100206055706/http://www.qzx.com/pc-gpe/pcx.txt - "VGA 256 Color Palette Information"
    pos: _io.size - 769
    type: t_palette_256
    if: hdr.version == versions::v3_0 and hdr.bits_per_pixel == 8 and hdr.num_planes == 1
types:
  header:
    doc-ref: http://web.archive.org/web/20100206055706/http://www.qzx.com/pc-gpe/pcx.txt - "ZSoft .PCX FILE HEADER FORMAT"
    seq:
      - id: magic
        contents: [0x0a]
        doc: |
          Technically, this field was supposed to be "manufacturer"
          mark to distinguish between various software vendors, and
          0x0a was supposed to mean "ZSoft", but everyone else ended
          up writing a 0x0a into this field, so that's what majority
          of modern software expects to have in this attribute.
      - id: version
        type: u1
        enum: versions
      - id: encoding
        type: u1
        enum: encodings
      - id: bits_per_pixel
        type: u1
      - id: img_x_min
        type: u2
      - id: img_y_min
        type: u2
      - id: img_x_max
        type: u2
      - id: img_y_max
        type: u2
      - id: hdpi
        type: u2
      - id: vdpi
        type: u2
      - id: palette_16
        size: 48
      - id: reserved
        contents: [0]
      - id: num_planes
        type: u1
      - id: bytes_per_line
        type: u2
      - id: palette_info
        type: u2
      - id: h_screen_size
        type: u2
      - id: v_screen_size
        type: u2
  t_palette_256:
    seq:
      - id: magic
        contents: [0x0c]
      - id: colors
        type: rgb
        repeat: expr
        repeat-expr: 256
  rgb:
    seq:
      - id: r
        type: u1
      - id: g
        type: u1
      - id: b
        type: u1
enums:
  versions:
    0: v2_5
    2: v2_8_with_palette
    3: v2_8_without_palette
    4: paintbrush_for_windows
    5: v3_0
  encodings:
    1: rle
