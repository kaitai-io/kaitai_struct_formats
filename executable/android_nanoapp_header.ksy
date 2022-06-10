meta:
  id: android_nanoapp_header
  title: Android nanoapp header
  file-extension: napp_header
  tags:
    - android
    - executable
  license: Apache-2.0
  ks-version: 0.9
  endian: le
doc-ref: https://android.googlesource.com/platform/system/chre/+/a7ff61b9/build/build_template.mk#130
seq:
  - id: header_version
    type: u4
    valid: 1
  - id: magic
    contents: "NANO"
  - id: app_id
    type: u8
  - id: app_version
    type: u4
  - id: flags
    type: u4
  - id: hub_type
    type: u8
  - id: chre_api_major_version
    type: u1
  - id: chre_api_minor_version
    type: u1
  - id: reserved
    contents: [0, 0, 0, 0, 0, 0]
instances:
  is_signed:
    value: flags & 0x1 != 0
  is_encrypted:
    value: flags & 0x2 != 0
  is_tcm_capable:
    value: flags & 0x4 != 0
