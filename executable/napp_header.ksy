meta:
  id: napp_header
  title: Nano App header
  file-extension: napp_header
  license: Apache-2.0
  ks-version: 0.9
  endian: le
  encoding: UTF-8
doc-ref: https://android.googlesource.com/platform/system/chre/+/a7ff61b94d6658597c63ae0a15bdee3cdfbaa8c7/build/build_template.mk#130
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
    value: flags & 0x1 == 0x1
  is_encrypted:
    value: flags & 0x2 == 0x2
  is_tcm_capable:
    value: flags & 0x4 == 0x4
