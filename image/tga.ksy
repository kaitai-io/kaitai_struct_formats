meta:
  id: tga
  title: TGA (AKA Truevision TGA, AKA TARGA) raster image file format
  xref:
    loc: fdd000180 # TGA 2.0
    pronom: fmt/402 # TGA 2.0
    wikidata: Q1063976
  file-extension:
    - tga
    - icb
    - vda
    - vst
  license: CC0-1.0
  encoding: ASCII
  endian: le
doc:
  TGA (AKA Truevision TGA, AKA TARGA), is a raster image file format
  created by Truevision. It supports up to 32 bits per pixel (three
  8-bit RGB channels + 8-bit alpha channel), color mapping and
  optional lossless RLE compression.
doc-ref: https://www.dca.fee.unicamp.br/~martino/disciplinas/ea978/tgaffs.pdf
seq:
  - id: image_id_len
    type: u1
  - id: color_map_type
    type: u1
    enum: color_map_enum
  - id: image_type
    type: u1
    enum: image_type_enum
  - id: color_map_ofs
    type: u2
  - id: num_color_map
    type: u2
    doc: Number of entries in a color map
  - id: color_map_depth
    type: u1
    doc: Number of bits in a each color maps entry
  - id: x_offset
    type: u2
  - id: y_offset
    type: u2
  - id: width
    type: u2
    doc: Width of the image, in pixels
  - id: height
    type: u2
    doc: Height of the image, in pixels
  - id: image_depth
    type: u1
  - id: img_descriptor
    type: u1
  - id: image_id
    size: image_id_len
    doc: |
      Arbitrary application-specific information that is used to
      identify image. May contain text or some binary data.
  - id: color_map
    repeat: expr
    repeat-expr: num_color_map
    size: (color_map_depth + 7) / 8
    if: color_map_type == color_map_enum::has_color_map
    doc: Color map
instances:
  footer:
    pos: _io.size - 26
    type: tga_footer
enums:
  color_map_enum:
    0: no_color_map
    1: has_color_map
  image_type_enum:
    0: no_image_data
    1: uncomp_color_mapped
    2: uncomp_true_color
    3: uncomp_bw
    9: rle_color_mapped
    10: rle_true_color
    11: rle_bw
types:
  tga_footer:
    seq:
      - id: ext_area_ofs
        type: u4
        doc: Offset to extension area
      - id: dev_dir_ofs
        type: u4
        doc: Offset to developer directory
      - id: version_magic
        size: 18
    instances:
      is_valid:
        value: 'version_magic == [0x54, 0x52, 0x55, 0x45, 0x56, 0x49, 0x53, 0x49, 0x4f, 0x4e, 0x2d, 0x58, 0x46, 0x49, 0x4c, 0x45, 0x2e, 0x00]'
      ext_area:
        pos: ext_area_ofs
        type: tga_ext_area
        if: is_valid
  tga_ext_area:
    seq:
      - id: ext_area_size
        type: u2
        doc: Extension area size in bytes (always 495)
      - id: author_name
        type: str
        size: 41
      - id: comments
        repeat: expr
        repeat-expr: 4
        type: str
        size: 81
        doc: Comments, organized as four lines, each consisting of 80 characters plus a NULL
      - id: timestamp
        size: 12
        doc: Image creation date / time
      - id: job_id
        type: str
        size: 41
        doc: Internal job ID, to be used in image workflow systems
      - id: job_time
        type: str
        size: 6
        doc: Hours, minutes and seconds spent creating the file (for billing, etc.)
      - id: software_id
        type: str
        size: 41
        doc: The application that created the file.
      - id: software_version
        size: 3
      - id: key_color
        type: u4
      - id: pixel_aspect_ratio
        type: u4
      - id: gamma_value
        type: u4
      - id: color_corr_ofs
        type: u4
        doc: Number of bytes from the beginning of the file to the color correction table if present
      - id: postage_stamp_ofs
        type: u4
        doc: Number of bytes from the beginning of the file to the postage stamp image if present
      - id: scan_line_ofs
        type: u4
        doc: Number of bytes from the beginning of the file to the scan lines table if present
      - id: attributes
        type: u1
        doc: Specifies the alpha channel
