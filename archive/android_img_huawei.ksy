meta:
  id: android_img_huawei
  title: Huawei Bootloader packed image format
  file-extension: img
  tags:
    - archive
    - android
  license: CC0-1.0
  endian: le
doc: |
  Format of boot files found on certain Android devices from Huawei.

  Example device: Nexus 6P
doc-ref: https://android.googlesource.com/device/huawei/angler/+/673cfb95bf3dccabae32b382bb17f2b08435b840/releasetools.py
seq:
  - id: img_header
    type: header
  - id: img_header_entries
    type: image_header_entry
    repeat: expr
    repeat-expr: img_header.image_header_size/80
types:
  header:
     seq:
        - id: magic
          contents: [0x3c, 0xd6, 0x1a, 0xce]
        - id: major_version
          type: u2
        - id: minor_version
          type: u2
        - id: image_version
          size: 64
        - id: meta_header_size
          type: u2
        - id: image_header_size
          type: u2
  image_header_entry:
    seq:
      - id: name
        type: strz
        encoding: UTF-8
        size: 72
        doc: partition name
      - id: offset
        type: u4
        doc: partition offset from the beginning of the file
      - id: size
        type: u4
        doc: partition size
