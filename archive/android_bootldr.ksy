meta:
  id: android_bootldr
  title: Qualcomm Snapdragon (MSM) bootloader.img format
  file-extension: img
  tags:
    - archive
    - android
  license: CC0-1.0
  endian: le
doc-ref: https://android.googlesource.com/device/lge/hammerhead/+/7618a7/releasetools.py
seq:
  - id: magic
    contents: BOOTLDR!
  - id: images
    -orig-id: num_images
    type: u4
  - id: ofs_start
    -orig-id: start_offset
    type: u4
  - id: bootloader_size
    -orig-id: bootldr_size
    type: u4
  - id: img_info
    type: img_info
    repeat: expr
    repeat-expr: images
types:
  img_info:
    -webide-representation: '{name}'
    seq:
      - id: name
        type: strz
        encoding: UTF-8
        size: 64
      - id: size
        type: u4
