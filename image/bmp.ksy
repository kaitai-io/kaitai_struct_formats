meta:
  id: bmp
  file-extension: bmp
  xref:
    forensicswiki: BMP
    justsolve: BMP
    loc: fdd000189
    mime: image/bmp
    pronom:
      - fmt/115
      - fmt/116
      - fmt/117
      - fmt/118
      - fmt/119
      - x-fmt/25
    wikidata: Q192869
  endian: le
  license: CC0-1.0
  ks-version: 0.8
seq:
  - id: file_hdr
    type: file_header
  - id: len_dib_header
    type: s4
  - id: dib_header
    size: len_dib_header - 4
    type:
      switch-on: len_dib_header
      cases:
        12: bitmap_core_header
        40: bitmap_info_header
        104: bitmap_core_header # FIXME, should use BITMAPV4HEADER
        124: bitmap_core_header # FIXME, should use BITMAPV5HEADER
types:
  file_header:
    -orig-id: BITMAPFILEHEADER
    doc-ref: https://msdn.microsoft.com/en-us/library/dd183374.aspx
    seq:
      - id: magic
        -orig-id: bfType
        contents: "BM"
      - id: len_file
        -orig-id: bfSize
        type: u4
      - id: reserved1
        -orig-id: bfReserved1
        type: u2
      - id: reserved2
        -orig-id: bfReserved2
        type: u2
      - id: ofs_bitmap
        -orig-id: bfOffBits
        type: s4
        doc: Offset to actual raw pixel data of the image
  bitmap_core_header:
    -orig-id: BITMAPCOREHEADER
    doc-ref: https://msdn.microsoft.com/en-us/library/dd183372.aspx
    seq:
      - id: image_width
        -orig-id: bcWidth
        type: u2
        doc: Image width, px
      - id: image_height
        -orig-id: bcHeight
        type: u2
        doc: Image height, px
      - id: num_planes
        -orig-id: bcPlanes
        type: u2
        doc: Number of planes for target device, must be 1
      - id: bits_per_pixel
        -orig-id: bcBitCount
        type: u2
        doc: Number of bits per pixel that image buffer uses (1, 4, 8, or 24)
  bitmap_info_header:
    -orig-id: BITMAPINFOHEADER
    doc-ref: https://msdn.microsoft.com/en-us/library/dd183376.aspx
    seq:
      - id: image_width
        -orig-id: biWidth
        type: u4
      - id: image_height
        -orig-id: biHeight
        type: u4
      - id: num_planes
        -orig-id: biPlanes
        type: u2
      - id: bits_per_pixel
        -orig-id: biBitCount
        type: u2
      - id: compression
        -orig-id: biCompression
        type: u4
        enum: compressions
      - id: len_image
        -orig-id: biSizeImage
        type: u4
      - id: x_px_per_m
        -orig-id: biXPelsPerMeter
        type: u4
      - id: y_px_per_m
        -orig-id: biYPelsPerMeter
        type: u4
      - id: num_colors_used
        -orig-id: biClrUsed
        type: u4
      - id: num_colors_important
        -orig-id: biClrImportant
        type: u4
instances:
  image:
    pos: file_hdr.ofs_bitmap
    size-eos: true
enums:
  compressions:
    # https://msdn.microsoft.com/en-us/library/cc250415.aspx
    0:
      id: rgb
      -orig-id: BI_RGB
      doc: Uncompressed RGB format
    1:
      id: rle8
      -orig-id: BI_RLE8
      doc: RLE compression, 8 bits per pixel
    2:
      id: rle4
      -orig-id: BI_RLE4
      doc: RLE compression, 4 bits per pixel
    3:
      id: bitfields
      -orig-id: BI_BITFIELDS
    4:
      id: jpeg
      -orig-id: BI_JPEG
      doc: BMP file includes whole JPEG file in image buffer
    5:
      id: png
      -orig-id: BI_PNG
      doc: BMP file includes whole PNG file in image buffer
    0xb:
      id: cmyk
      -orig-id: BI_CMYK
    0xc:
      id: cmyk_rle8
      -orig-id: BI_CMYKRLE8
    0xd:
      id: cmyk_rle4
      -orig-id: BI_CMYKRLE4
