meta:
  id: gimp_brush
  title: GIMP brush file version 2
  application: GIMP (GNU Image Manipulation Program)
  file-extension: gbr
  xref:
    justsolve: GIMP_Brush
    mime: image/x-gimp-gbr
    wikidata: Q28206177
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
        valid: 2
      - id: width
        type: u4
        valid:
          min: 1
          max: 10000
        doc-ref:
          - https://github.com/GNOME/gimp/blob/9b6d59f/app/core/gimpbrush-load.c#L170 # valid/min
          - https://github.com/GNOME/gimp/blob/9b6d59f/app/core/gimpbrush-header.h#L24 # valid/max
      - id: height
        type: u4
        valid:
          min: 1
          max: 10000
        doc-ref:
          - https://github.com/GNOME/gimp/blob/9b6d59f/app/core/gimpbrush-load.c#L177 # valid/min
          - https://github.com/GNOME/gimp/blob/9b6d59f/app/core/gimpbrush-header.h#L24 # valid/max
      - id: bytes_per_pixel
        type: u4
        enum: color_depth
      - id: magic
        contents: GIMP
      - id: spacing
        type: u4
        doc: Default spacing to be used for brush. Percentage of brush width.
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
