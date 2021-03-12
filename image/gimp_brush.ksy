meta:
  id: gimp_brush
  title: GIMP (GNU Image Manipulation Program) brush version 2 file
  file-extension: gbr
  license: CC0-1.0
  endian: be
doc-ref: https://gitlab.gnome.org/GNOME/gimp/-/raw/441631322be109da6489b2aad670bdba916315c0/devel-docs/gbr.txt
seq:
  - id: len_header
    type: u4
  - id: header
    type: header
    size: len_header
types:
  header:
    seq:
      - id: version
        type: u4
      - id: width
        type: u4
      - id: height
        type: u4
      - id: color_depth
        type: u4
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
    value: header.width * header.height * header.color_depth
  body:
    pos: header_size
    size: body_size
