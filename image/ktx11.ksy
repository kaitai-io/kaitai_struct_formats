meta:
  id: ktx11
  title: KTX (Khronos) File Format
  license: CC0-1.0
  ks-version: 0.9
  encoding: utf-8
doc-ref: https://www.khronos.org/registry/KTX/specs/1.0/ktxspec_v1.html

seq:
  - id: magic
    contents: [0xAB, 0x4B, 0x54, 0x58, 0x20, 0x31, 0x31, 0xBB, 0x0D, 0x0A, 0x1A, 0x0A]
  - id: endian
    type: u4le
    enum: endian
  - id: endian_ktx
    type: ktx
types:
  ktx:
    meta:
      endian:
        switch-on: _root.endian
        cases:
          endian::le: le
          endian::be: be
    seq:
      - id: type
        type: u4
      - id: type_size
        type: u4
      - id: format
        type: u4
      - id: internal_format
        type: u4
        enum: format
      - id: base_internal_format
        type: u4
      - id: pixel_width
        type: u4
      - id: pixel_height
        type: u4
      - id: pixel_depth
        type: u4
      - id: array_elements_num
        type: u4
      - id: num_faces
        type: u4
      - id: mipmap_levels_num
        type: u4
      - id: len_key_value_data
        type: u4
      - id: key_value_data
        size: len_key_value_data
        type: key_value_data
      - id: mipmap_levels
        type: mipmap_level
        repeat: expr
        repeat-expr: num_mipmap_levels
    instances:
      compressed:
        value: type == 0
      num_array_elements:
        value: "array_elements_num == 0 ? 1 : array_elements_num"
      num_mipmap_levels:
        value: "mipmap_levels_num == 0 ? 1 : ((internal_format == format::palette4_rgb8_eos or internal_format == format::palette4_rgba8_eos or internal_format == format::palette4_r5_g6_b5_eos or internal_format == format::palette4_rgba4_eos or internal_format == format::palette4_rgb5_a1_eos or internal_format == format::palette8_rgb8_eos or internal_format == format::palette8_rgba8_eos or internal_format == format::palette8_r5_g6_b5_eos or internal_format == format::palette8_rgba4_eos or internal_format == format::palette8_rgb5_a1_eos) ? 1 : mipmap_levels_num)"
    types:
      key_value_data:
        seq:
          - id: key_value
            type: key_value
            repeat: eos
      key_value:
        seq:
          - id: len_key_value
            type: u4
          - id: key_value
            size: len_key_value
          - id: padding
            size: -len_key_value % 4
      mipmap_level:
        seq:
          - id: len_image
            type: u4
          - id: image
            size: len_image
          - id: padding
            size: -len_image % 4
enums:
  endian:
    0x04030201: le
    0x01020304: be
  format:
    0x1907: rgb
    0x1908: rgba
    0x1909: luminance
    0x190a: luminance_alpha
    0x80e1: bgr
    0x80e2: bgra
    0x83a0: rgb_s3tc
    0x83a1: rgb4_s3tc
    0x83a2: rgba_s3tc
    0x83a3: rgba4_s3tc
    0x83a4: rgba_dxt5_s3tc
    0x83a5: rgba4_dxt5_s3tc
    0x83f0: compressed_rgb_s3tc_dxt1_ext
    0x83f1: compressed_rgba_s3tc_dxt1_ext
    0x83f2: compressed_rgba_s3tc_dxt3_ext
    0x83f3: compressed_rgba_s3tc_dxt5_ext
    0x8b90: palette4_rgb8_eos
    0x8b91: palette4_rgba8_eos
    0x8b92: palette4_r5_g6_b5_eos
    0x8b93: palette4_rgba4_eos
    0x8b94: palette4_rgb5_a1_eos
    0x8b95: palette8_rgb8_eos
    0x8b96: palette8_rgba8_eos
    0x8b97: palette8_r5_g6_b5_eos
    0x8b98: palette8_rgba4_eos
    0x8b99: palette8_rgb5_a1_eos
    0x8d64: etc1_rgb8_oes
    0x9270: compressed_r11_eac
    0x9271: compressed_signed_r11_eac
    0x9272: compressed_rg11_eac
    0x9273: compressed_signed_rg11_eac
    0x9274: compressed_rgb8_etc2
    0x9275: compressed_srgb8_etc2
    0x9276: compressed_rgb8_punchthrough_alpha1_etc2
    0x9277: compressed_srgb8_punchthrough_alpha1_etc2
    0x9278: compressed_rgba2_etc2_eac
    0x9279: compressed_srgb8_alpha8_etc2_eac
    0x93b0: compressed_rgba_astc_4x4_khr
    0x93b1: compressed_rgba_astc_5x4_khr
    0x93b2: compressed_rgba_astc_5x5_khr
    0x93b3: compressed_rgba_astc_6x5_khr
    0x93b4: compressed_rgba_astc_6x6_khr
    0x93b5: compressed_rgba_astc_8x5_khr
    0x93b6: compressed_rgba_astc_8x6_khr
    0x93b7: compressed_rgba_astc_8x8_khr
    0x93b8: compressed_rgba_astc_10x5_khr
    0x93b9: compressed_rgba_astc_10x6_khr
    0x93ba: compressed_rgba_astc_10x8_khr
    0x93bb: compressed_rgba_astc_10x10_khr
    0x93bc: compressed_rgba_astc_12x10_khr
    0x93bd: compressed_rgba_astc_12x12_khr
    0x93d0: compressed_srgb8_alpha8_astc_4x4_khr
    0x93d1: compressed_srgb8_alpha8_astc_5x4_khr
    0x93d2: compressed_srgb8_alpha8_astc_5x5_khr
    0x93d3: compressed_srgb8_alpha8_astc_6x5_khr
    0x93d4: compressed_srgb8_alpha8_astc_6x6_khr
    0x93d5: compressed_srgb8_alpha8_astc_8x5_khr
    0x93d6: compressed_srgb8_alpha8_astc_8x6_khr
    0x93d7: compressed_srgb8_alpha8_astc_8x8_khr
    0x93d8: compressed_srgb8_alpha8_astc_10x5_khr
    0x93d9: compressed_srgb8_alpha8_astc_10x6_khr
    0x93da: compressed_srgb8_alpha8_astc_10x8_khr
    0x93db: compressed_srgb8_alpha8_astc_10x10_khr
    0x93dc: compressed_srgb8_alpha8_astc_12x10_khr
    0x93dd: compressed_srgb8_alpha8_astc_12x12_khr
