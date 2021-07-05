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
  ks-version: 0.9
  endian: be
doc: |
  GIMP brush format is native to the GIMP image editor for storing a brush or a texture.
  It can be used in all [Paint Tools](https://docs.gimp.org/2.10/en/gimp-tools-paint.html),
  for example Pencil and Paintbrush. It works by repeating the brush bitmap as you move
  the tool. The Spacing parameter sets the distance between the brush marks as a percentage
  of brush width. Its default value can be set in the brush file.

  You can also use GIMP to create new brushes in this format. Custom brushes can be loaded
  into GIMP for use in the paint tools by copying them into one of the Brush Folders -
  select **Edit** > **Preferences** in the menu bar, expand the **Folders** section
  and choose **Brushes** to see the recognized Brush Folders or to add new ones.
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
  bitmap:
    seq:
      - id: rows
        type: row
        repeat: expr
        repeat-expr: _root.header.height
  row:
    seq:
      - id: pixels
        type:
          switch-on: _root.header.bytes_per_pixel
          cases:
            color_depth::grayscale: pixel_gray
            color_depth::rgba: pixel_rgba
        repeat: expr
        repeat-expr: _root.header.width
    types:
      pixel_gray:
        -webide-representation: 'R={red:dec} G={green:dec} B={blue:dec} A={alpha:dec}'
        seq:
          - id: gray
            type: u1
        instances:
          red:
            value: 0
            -webide-parse-mode: eager
          green:
            value: 0
            -webide-parse-mode: eager
          blue:
            value: 0
            -webide-parse-mode: eager
          alpha:
            value: gray

      pixel_rgba:
        -webide-representation: 'R={red:dec} G={green:dec} B={blue:dec} A={alpha:dec}'
        seq:
          - id: red
            type: u1
          - id: green
            type: u1
          - id: blue
            type: u1
          - id: alpha
            type: u1
instances:
  len_body:
    value: header.width * header.height * header.bytes_per_pixel.to_i
  body:
    pos: len_header
    size: len_body
    -affected-by: 188
    # type: bitmap # The `bitmap` type works, but it might be slow and memory intensive for larger bitmaps
                   # because it creates a class instance for every pixel.
                   # So it is not suitable for production, but you can use it as a reference to create your
                   # own implementation.
enums:
  color_depth:
    1: grayscale
    4: rgba
