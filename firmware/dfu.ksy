meta:
  id: dfu
  title: Device Firmware Upgrade
  file-extension: dfu
  license: CC0-1.0
  endian: le
doc: |
  Device Firmware Upgrade files

  Test files: <https://micropython.org/download/espruino_pico/>
doc-ref: https://raw.githubusercontent.com/micropython/micropython/247d7e2/tools/pydfu.py
seq:
  - id: magic
    size: 5
    contents: "DfuSe"
  - id: version
    type: u1
    valid: 1
  - id: len_dfu
    -orig-id: size
    type: u4
  - id: num_targets
    type: u1
  - id: targets
    type: target
    repeat: expr
    repeat-expr: num_targets
  - id: device
    doc: Firmware version
    type: u2
  - id: product
    type: u2
  - id: vendor
    type: u2
  - id: dfu_version
    type: u2
    valid: 0x11a
  - id: ufd
    size: 3
    contents: "UFD"
  - id: len_suffix
    type: u1
    valid: 16
  - id: checksum
    type: u4
types:
  target:
    seq:
      - id: signature
        size: 6
        contents: "Target"
      - id: alt_setting
        type: u1
      - id: named
        type: u4
      - id: name
        size: 255
        type: strz
        encoding: UTF-8
      - id: len_target
        -orig-id: size
        type: u4
      - id: num_elements
        type: u4
      - id: elements
        type: element
        repeat: expr
        repeat-expr: num_elements
  element:
    seq:
      - id: address
        type: u4
      - id: len_element
        -orig-id: size
        type: u4
      - id: data
        size: len_element
