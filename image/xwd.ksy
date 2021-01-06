meta:
  id: xwd
  title: xwd (X Window Dump) bitmap image
  application: xwd
  xref:
    pronom: fmt/401
  license: CC0-1.0
  endian: be
doc: |
  xwd is a file format written by eponymous X11 screen capture
  application (xwd stands for "X Window Dump"). Typically, an average
  user transforms xwd format into something more widespread by any of
  `xwdtopnm` and `pnmto...` utilities right away.

  xwd format itself provides a raw uncompressed bitmap with some
  metainformation, like pixel format, width, height, bit depth,
  etc. Note that technically format includes machine-dependent fields
  and thus is probably a poor choice for true cross-platform usage.
seq:
  - id: len_header
    type: u4
    doc: Size of the header in bytes
  - id: hdr
    size: len_header - 4
    type: header
  - id: color_map
    size: 12
    type: color_map_entry
    repeat: expr
    repeat-expr: hdr.color_map_entries
types:
  header:
    seq:
      - id: file_version
        type: u4
        doc: X11WD file version (always 07h)
      - id: pixmap_format
        type: u4
        doc: Format of the image data
        enum: pixmap_format
      - id: pixmap_depth
        type: u4
        doc: Pixmap depth in pixels - in practice, bits per pixel
      - id: pixmap_width
        type: u4
        doc: Pixmap width in pixels
      - id: pixmap_height
        type: u4
        doc: Pixmap height in pixels
      - id: x_offset
        type: u4
        doc: Bitmap X offset (number of pixels to ignore at the beginning of each scan-line)
      - id: byte_order
        type: u4
        doc: Byte order of image data
        enum: byte_order
      - id: bitmap_unit
        type: u4
        doc: Bitmap base data size
      - id: bitmap_bit_order
        type: u4
        doc: Bit-order of image data
      - id: bitmap_pad
        type: u4
        doc: Bitmap scan-line pad
      - id: bits_per_pixel
        type: u4
        doc: Bits per pixel
      - id: bytes_per_line
        type: u4
        doc: Bytes per scan-line
      - id: visual_class
        type: u4
        doc: Class of the image
        enum: visual_class
      - id: red_mask
        type: u4
        doc: Red mask
      - id: green_mask
        type: u4
        doc: Green mask
      - id: blue_mask
        type: u4
        doc: Blue mask
      - id: bits_per_rgb
        type: u4
        doc: Size of each color mask in bits
      - id: number_of_colors
        type: u4
        doc: Number of colors in image
      - id: color_map_entries
        type: u4
        doc: Number of entries in color map
      - id: window_width
        type: u4
        doc: Window width
      - id: window_height
        type: u4
        doc: Window height
      - id: window_x
        type: s4
        doc: Window upper left X coordinate
      - id: window_y
        type: s4
        doc: Window upper left Y coordinate
      - id: window_border_width
        type: u4
        doc: Window border width
      - id: creator
        type: strz
        encoding: UTF-8
        doc: Program that created this xwd file
  color_map_entry:
    seq:
      - id: entry_number
        type: u4
        doc: Number of the color map entry
      - id: red
        type: u2
      - id: green
        type: u2
      - id: blue
        type: u2
      - id: flags
        type: u1
      - id: padding
        type: u1
enums:
  pixmap_format:
    0: x_y_bitmap
    1: x_y_pixmap
    2: z_pixmap
  byte_order:
    0: le
    1: be
  visual_class:
    0: static_gray
    1: gray_scale
    2: static_color
    3: pseudo_color
    4: true_color
    5: direct_color
