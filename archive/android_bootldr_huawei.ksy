meta:
  id: android_bootldr_huawei
  title: Huawei Bootloader packed image format
  file-extension: img
  tags:
    - archive
    - android
  license: CC0-1.0
  endian: le
doc: |
  Format of `bootloader-*.img` files found in factory images of certain Android devices from Huawei:

  * Nexus 6P "angler": [sample][sample-angler] ([other samples][others-angler]),
    [releasetools.py](https://android.googlesource.com/device/huawei/angler/+/cf92cd8/releasetools.py#29)

  [sample-angler]: https://androidfilehost.com/?fid=11410963190603870158 "bootloader-angler-angler-03.84.img"
  [others-angler]: https://androidfilehost.com/?w=search&s=bootloader-angler&type=files

doc-ref: https://android.googlesource.com/device/huawei/angler/+/673cfb9/releasetools.py
seq:
  - id: img_header
    type: header
  - id: entries
    type: entries
    size: img_header.image_header_size
types:
  header:
    seq:
      - id: magic
        contents: [0x3c, 0xd6, 0x1a, 0xce]
      - id: version
        type: version
      - id: image_version
        size: 64
      - id: meta_header_size
        type: u2
      - id: image_header_size
        type: u2
  version:
    seq:
      - id: major
        type: u2
      - id: minor
        type: u2
  entries:
    seq:
      - id: entries
        type: entry
        repeat: eos
  entry:
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
