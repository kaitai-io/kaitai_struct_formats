meta:
  id: bmp
  file-extension: bmp
  endian: le
seq:
  - id: file_hdr
    type: file_header
  - id: dib_hdr
    type: dib_header
types:
  file_header:
    # https://msdn.microsoft.com/en-us/library/dd183374.aspx
    seq:
      - id: file_type
        size: 2
      - id: file_size
        type: u4
      - id: reserved1
        type: u2
      - id: reserved2
        type: u2
      - id: bitmap_ofs
        type: s4
  dib_header:
    seq:
      - id: dib_header_size
        type: s4
      - id: bitmap_core_header
        type: bitmap_core_header
        size: dib_header_size - 4
        if: dib_header_size == 12
      - id: bitmap_info_header
        type: bitmap_info_header
        size: dib_header_size - 4
        if: dib_header_size == 40
      - id: bitmap_v5_header
        type: bitmap_core_header
        size: dib_header_size - 4
        if: dib_header_size == 124
      - id: dib_header_body
        size: dib_header_size - 4
        if: dib_header_size != 12 and dib_header_size != 40 and dib_header_size != 124
  bitmap_core_header:
    # https://msdn.microsoft.com/en-us/library/dd183372.aspx
    seq:
      - id: image_width
        type: u2
      - id: image_height
        type: u2
      - id: num_planes
        type: u2
      - id: bits_per_pixel
        type: u2
  bitmap_info_header:
    # https://msdn.microsoft.com/en-us/library/dd183376.aspx
    seq:
      - id: image_width
        type: u4
      - id: image_height
        type: u4
      - id: num_planes
        type: u2
      - id: bits_per_pixel
        type: u2
      - id: compression
        type: u4
      - id: size_image
        type: u4
      - id: x_px_per_m
        type: u4
      - id: y_px_per_m
        type: u4
      - id: num_colors_used
        type: u4
      - id: num_colors_important
        type: u4
instances:
  image:
    pos: file_hdr.bitmap_ofs
    size-eos: true
