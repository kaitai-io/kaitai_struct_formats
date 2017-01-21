meta:
  id: pcx
  file-extension: pcx
  endian: le
seq:
  - id: hdr
    type: header
    size: 128
types:
  header:
    seq:
      # http://web.archive.org/web/20100206055706/http://www.qzx.com/pc-gpe/pcx.txt - "ZSoft .PCX FILE HEADER FORMAT"
      - id: manufacturer
        type: u1
      - id: version
        type: u1
      - id: encoding
        type: u1
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
      - id: colormap
        size: 48
      - id: reserved
        size: 1
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
