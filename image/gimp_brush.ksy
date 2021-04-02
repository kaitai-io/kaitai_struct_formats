meta:
  id: gimp_brush
  title: GIMP (GNU Image Manipulation Program) brush version 2 file
  file-extension: gbr
  license: CC0-1.0
  endian: be
doc-ref: https://gitlab.gnome.org/GNOME/gimp/-/raw/4416313/devel-docs/gbr.txt
seq:
  - id: len_header
    type: u4
  - id: header
    type: header
    size: len_header - len_header._sizeof
types:
  header:
    seq:
      - id: version
        type: u4
      - id: width
        type: u4
      - id: height
        type: u4
      - id: bytes_per_pixel
        type: u4
        enum: color_depth
      - id: magic
        contents: GIMP
      - id: spacing
        type: u4
      - id: brush_name
        type: strz
        size-eos: true
        encoding: UTF-8
instances:
  body_size:
    value: header.width * header.height * header.bytes_per_pixel.to_i
  body:
    pos: len_header
    size: body_size
enums:
  color_depth:
    1: grayscale
    4: rgba
