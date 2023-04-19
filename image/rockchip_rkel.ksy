meta:
  id: rkel
  title: Rockchip RKEL
  license: CC0
  endian: le
  encoding: UTF-8
doc: |
  Image format found in devices with the Rockchip RK3566, such as the PineNote
  <https://wiki.pine64.org/wiki/PineNote>

  Example files:

  <https://github.com/BPI-SINOVOIP/BPI-Rockchip-Android11/tree/master/device/rockchip/rk356x/rk3566_eink/ota>
seq:
  - id: header
    size: 64
    type: header
  - id: data
    size: header.len_data - header._sizeof
    type: images(header.num_images)
types:
  header:
    seq:
      - id: magic
        contents: "RKEL"
      - id: len_data
        type: u4
      - id: height
        type: u4
      - id: width
        type: u4
      - id: num_images
        type: u4
      - id: version
        type: strz
        size-eos: true
  images:
    params:
      - id: num_images
        type: u4
    seq:
      - id: image_entries
        size: 32
        type: image_entry
        repeat: expr
        repeat-expr: num_images
  image_entry:
    seq:
      - id: signature
        contents: ['GR04']
      - id: unknown_1
        type: u4
      - id: height
        type: u2
      - id: width
        type: u2
      - id: unknown_2
        type: u4
      - id: ofs_image_data
        type: u4
      - id: len_image_data
        type: u4
      - id: unknown_3
        size: 8
    instances:
      image_data:
        pos: ofs_image_data
        size: len_image_data
        io: _root._io
