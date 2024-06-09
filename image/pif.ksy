meta:
  id: pif
  title: Portable Image Format
  file-extension: pif
  xref:
    justsolve: PIF_(Portable_Image_Format)
  license: LGPL-2.1
  ks-version: 0.9
  endian: le
  bit-endian: le
doc: |
  The Portable Image Format (PIF) is a basic, bitmap-like image format with the
  focus on ease of use (implementation) and small size for embedded
  applications.

  See <https://github.com/gfcwfzkm/PIF-Image-Format> for more info.
doc-ref:
  - https://github.com/gfcwfzkm/PIF-Image-Format/blob/4ec261b/Specification/PIF%20Format%20Specification.pdf
  - https://github.com/gfcwfzkm/PIF-Image-Format/blob/4ec261b/C%20Library/pifdec.c#L300
seq:
  - id: file_header
    type: pif_header
  - id: info_header
    type: information_header
  - id: color_table
    size: info_header.len_color_table
    type: color_table_data
    if: info_header.uses_indexed_mode
instances:
  image_data:
    pos: file_header.ofs_image_data
    size: info_header.len_image_data
types:
  pif_header:
    seq:
      - id: magic
        contents: ["PIF", 0x00]
      - id: len_file
        type: u4
        valid:
          min: ofs_image_data_min
      - id: ofs_image_data
        type: u4
        valid:
          min: ofs_image_data_min
          max: len_file
    instances:
      ofs_image_data_min:
        value: _root.file_header._sizeof + _root.info_header._sizeof
  information_header:
    seq:
      - id: image_type
        type: u2
        enum: image_type
        valid:
          any-of:
            - image_type::rgb888
            - image_type::rgb565
            - image_type::rgb332
            - image_type::rgb16c
            - image_type::black_white
            - image_type::indexed_rgb888
            - image_type::indexed_rgb565
            - image_type::indexed_rgb332
      - id: bits_per_pixel
        type: u2
        valid:
          expr: |
            image_type == image_type::rgb888 ? _ == 24 :
            image_type == image_type::rgb565 ? _ == 16 :
            image_type == image_type::rgb332 ? _ == 8 :
            image_type == image_type::rgb16c ? _ == 4 :
            image_type == image_type::black_white ? _ == 1 :
            uses_indexed_mode ? _ <= 8 :
            true
          # ^ shouldn't get there (all cases have been covered before)
        doc: |
          See <https://github.com/gfcwfzkm/PIF-Image-Format/blob/4ec261b/Specification/PIF%20Format%20Specification.pdf>:

          > Bits per Pixel: Bit size that each Pixel occupies. Bit size for an
          > Indexed Image cannot go beyond 8 bits.
      - id: width
        type: u2
      - id: height
        type: u2
      - id: len_image_data
        type: u4
        valid:
          max: _root.file_header.len_file - _root.file_header.ofs_image_data
      - id: len_color_table
        type: u2
        valid:
          min: 'uses_indexed_mode ? len_color_table_entry * 1 : 0'
          max: |
            uses_indexed_mode ? (
              len_color_table_max < len_color_table_full
                ? len_color_table_max
                : len_color_table_full
            ) : 0
        doc: |
          See <https://github.com/gfcwfzkm/PIF-Image-Format/blob/4ec261b/Specification/PIF%20Format%20Specification.pdf>:

          > Color Table Size: (...), only used in Indexed mode, otherwise zero.
          ---
          > **Note**: The presence of the Color Table is mandatory when Bits per
          > Pixel <= 8, unless Image Type states RGB332, RGB16C or B/W
          ---
          > **Color Table** (semi-optional)
          >
          > (...) The amount of Colors has to be same or less than [Bits per
          > Pixel] allow, otherwise the image is invalid.
      - id: compression
        type: u2
        enum: compression_type
        valid:
          any-of:
            - compression_type::none
            - compression_type::rle
    instances:
      len_color_table_entry:
        value: |
          image_type == image_type::indexed_rgb888 ? 3 :
          image_type == image_type::indexed_rgb565 ? 2 :
          image_type == image_type::indexed_rgb332 ? 1 :
          0
      len_color_table_full:
        value: len_color_table_entry * (1 << bits_per_pixel)
      len_color_table_max:
        value: _root.file_header.ofs_image_data - _root.file_header.ofs_image_data_min
      uses_indexed_mode:
        value: len_color_table_entry != 0
  color_table_data:
    seq:
      - id: entries
        type:
          switch-on: _root.info_header.image_type
          cases:
            image_type::indexed_rgb888: b24
            image_type::indexed_rgb565: b16
            image_type::indexed_rgb332: b8
        repeat: eos
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
      doc-ref: https://github.com/gfcwfzkm/PIF-Image-Format/blob/4ec261b/C%20Library/pifdec.c#L233
    0x4952: indexed_rgb888
    0x4947: indexed_rgb565
    0x4942: indexed_rgb332
  compression_type:
    0x0000: none
    0x7dde: rle
