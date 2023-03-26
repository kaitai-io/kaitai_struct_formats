meta:
  id: pif
  title: Portable Image Format
  file-extension: pif
  license: LGPL-2.1
  ks-version: 0.9
  endian: le
doc-ref: https://github.com/gfcwfzkm/PIF-Image-Format/blob/cc256d5/Specification/PIF%20Format%20Specification.pdf
seq:
  - id: file_header
    type: pif_header
  - id: info_header
    type: information_header
  - id: color_table
    size: info_header.len_color_table
  - id: image_data
    size: info_header.len_image_data
types:
  pif_header:
    seq:
      - id: magic
        contents: ["PIF", 0x00]
      - id: len_file
        type: u4
      - id: ofs_image_data
        type: u4
  information_header:
    seq:
      - id: image_type
        type: u2
        enum: image_type
      - id: bits_per_pixel
        type: u2
      - id: width
        type: u2
      - id: height
        type: u2
      - id: len_image_data
        type: u4
      - id: len_color_table
        type: u2
      - id: compression
        type: u2
        enum: compression_type
        valid:
          any-of:
            - compression_type::none
            - compression_type::rle
enums:
  image_type:
    0x433c: rgb888
    0xe5c5: rgb565
    0x1e53: rgb332
    0xb895:
      id: rgb16c
      doc: |
        Formula to convert the 4-bit color value in RGB16C mode to RGB values
        (each in the range from 0 to 255):

        ```
        red   = 170 * ((color_value & 0b0100) >> 2) + 85 * ((color_value & 0b1000) >> 3)
        green = 170 * ((color_value & 0b0010) >> 1) + 85 * ((color_value & 0b1000) >> 3)
        blue  = 170 * ((color_value & 0b0001) >> 0) + 85 * ((color_value & 0b1000) >> 3)
        ```

        See also <https://en.wikipedia.org/wiki/Color_Graphics_Adapter#Color_palette>
    0x7daa:
      id: black_white
      doc: '0: black, 1: white'
      doc-ref: https://github.com/gfcwfzkm/PIF-Image-Format/blob/cc256d5/C%20Library/pifdec.c#L233
    0x4952: indexed_rgb888
    0x4947: indexed_rgb565
    0x4942: indexed_rgb332
  compression_type:
    0x0000: none
    0x7dde: rle
