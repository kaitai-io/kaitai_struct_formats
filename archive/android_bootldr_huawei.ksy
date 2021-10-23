meta:
  id: android_bootldr_huawei
  title: Huawei Bootloader packed image format
  file-extension: img
  tags:
    - archive
    - android
  license: CC0-1.0
  # The `releasetools.py` script is written for Python 2, where the default
  # encoding is ASCII.
  encoding: ASCII
  endian: le
doc: |
  Format of `bootloader-*.img` files found in factory images of certain Android devices from Huawei:

  * Nexus 6P "angler": [sample][sample-angler] ([other samples][others-angler]),
    [releasetools.py](https://android.googlesource.com/device/huawei/angler/+/cf92cd8/releasetools.py#29)

  [sample-angler]: https://androidfilehost.com/?fid=11410963190603870158 "bootloader-angler-angler-03.84.img"
  [others-angler]: https://androidfilehost.com/?w=search&s=bootloader-angler&type=files

  All image versions can be found in factory images at
  <https://developers.google.com/android/images> for the specific device. To
  avoid having to download an entire ZIP archive when you only need one file
  from it, install [remotezip](https://github.com/gtsystem/python-remotezip) and
  use its [command line
  tool](https://github.com/gtsystem/python-remotezip#command-line-tool) to list
  members in the archive and then to download only the file you want.

doc-ref:
  - https://android.googlesource.com/device/huawei/angler/+/673cfb9/releasetools.py
  - https://source.codeaurora.org/quic/la/device/qcom/common/tree/meta_image/meta_format.h?h=LA.UM.6.1.1&id=a68d284aee85
  - https://source.codeaurora.org/quic/la/device/qcom/common/tree/meta_image/meta_image.c?h=LA.UM.6.1.1&id=a68d284aee85
seq:
  - id: meta_header
    type: meta_hdr
  - id: header_ext
    size: meta_header.len_meta_header - meta_header._sizeof
  - id: image_header
    size: meta_header.len_image_header
    type: image_hdr
types:
  meta_hdr:
    seq:
      - id: magic
        contents: [0x3c, 0xd6, 0x1a, 0xce]
      - id: version
        type: version
      - id: image_version
        size: 64
        type: strz
      - id: len_meta_header
        -orig-id: meta_hdr_sz
        type: u2
      - id: len_image_header
        -orig-id: img_hdr_sz
        type: u2
  version:
    seq:
      - id: major
        type: u2
      - id: minor
        type: u2
  image_hdr:
    seq:
      - id: entries
        type: image_hdr_entry
        repeat: eos
        doc: |
          The C generator program defines `img_header` as a [fixed size
          array](https://source.codeaurora.org/quic/la/device/qcom/common/tree/meta_image/meta_image.c?h=LA.UM.6.1.1&id=a68d284aee85#n42)
          of `img_header_entry_t` structs with length `MAX_IMAGES` (which is
          defined as `16`).

          This means that technically there will always be 16 `image_hdr`
          entries, the first *n* entries being used (filled with real values)
          and the rest left unused with all bytes zero.

          To check if an entry is used, use the `is_used` attribute.
  image_hdr_entry:
    -webide-representation: '{name} - o:{ofs_body}, s:{len_body} (used: {is_used})'
    seq:
      - id: name
        size: 72
        type: strz
        doc: partition name
      - id: ofs_body
        type: u4
      - id: len_body
        type: u4
    instances:
      is_used:
        value: ofs_body != 0 and len_body != 0
        doc-ref: https://source.codeaurora.org/quic/la/device/qcom/common/tree/meta_image/meta_image.c?h=LA.UM.6.1.1&id=a68d284aee85#n119
      body:
        io: _root._io
        pos: ofs_body
        size: len_body
        if: is_used
