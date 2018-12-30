meta:
  id: evil_islands_mmp
  title: Evil Islands, MMP file (texture)
  application: Evil Islands
  file-extension: mmp
  license: MIT
  endian: le
doc: MIP-mapping texture
doc-ref: https://github.com/aspadm/EIrepack/wiki/mmp
seq:
  - id: magic
    contents: [0x4D, 0x4D, 0x50, 0x00]
  - id: width
    type: u4
  - id: height
    type: u4
  - id: num_mip_levels
    type: u4
  - id: fourcc
    type: u4
    enum: pixel_formats
  - id: bits_per_pixel
    type: u4
  - id: alpha_format
    type: channel_format
  - id: red_format
    type: channel_format
  - id: green_format
    type: channel_format
  - id: blue_format
    type: channel_format
  - id: ofs_base_texture
    type: u4
instances:
  base_texture:
    type:
      switch-on: fourcc
      cases:
        'pixel_formats::dxt1': block_dxt1
        'pixel_formats::dxt3': block_dxt3
        'pixel_formats::pnt3': block_pnt3
        _: block_custom
    pos: ofs_base_texture + 76
types:
  block_pnt3:
    seq:
      - id: raw
        size: _root.bits_per_pixel
  block_dxt1:
    seq:
      - id: raw
        size: _root.width * _root.height >> 1
  block_dxt3:
    seq:
      - id: raw
        size: _root.width * _root.height
  block_custom:
    seq:
      - id: lines
        type: line_custom
        repeat: expr
        repeat-expr: _root.height
    types:
      line_custom:
        seq:
          - id: pixels
            type: pixel_custom
            repeat: expr
            repeat-expr: _root.width
        types:
          pixel_custom:
            seq:
              - id: raw
                type:
                  switch-on: _root.bits_per_pixel
                  cases:
                    8: u1
                    16: u2
                    32: u4
            instances:
              alpha:
                value: '_root.alpha_format.count == 0 ? 255 : 255 * ((raw & _root.alpha_format.mask) >> _root.alpha_format.shift) / (_root.alpha_format.mask >> _root.alpha_format.shift)'
              red:
                value: '255 * ((raw & _root.red_format.mask) >> _root.red_format.shift) / (_root.red_format.mask >> _root.red_format.shift)'
              green:
                value: '255 * ((raw & _root.green_format.mask) >> _root.green_format.shift) / (_root.green_format.mask >> _root.green_format.shift)'
              blue:
                value: '255 * ((raw & _root.blue_format.mask) >> _root.blue_format.shift) / (_root.blue_format.mask >> _root.blue_format.shift)'
  channel_format:
    doc: Description of bits for color channel
    seq:
      - id: mask
        type: u4
        doc: Binary mask for channel bits
      - id: shift
        type: u4
        doc: Binary shift for channel bits
      - id: count
        type: u4
        doc: Count of channel bits
enums:
  pixel_formats:
    0x00004444: argb4
    0x31545844: dxt1
    0x33545844: dxt3
    0x33544E50: pnt3
    0x00005650: r5g6b5
    0x00005551: a1r5g5b5
    0x00008888: argb8
