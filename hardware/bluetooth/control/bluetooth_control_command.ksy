meta:
  id: bluetooth_control_command
  title: Bluetooth Host Controller Interface Control Protocol
  license: Unlicense
  endian: le
  bit-endian: le
  imports:
    - vendor_specific/bluetooth_control_group_vendor_specific
    - ../bluetooth_vendors_ids
doc: |
  Bluetooth HCI control command. Used for the stuff like managing bluetooth settings and loading firmware.
doc-ref: https://www.bluetooth.org/docman/handlers/downloaddoc.ashx?doc_id=478726
params:
  - id: vendor
    type: u2
    enum: bluetooth_vendors_ids::vendor
seq:
  - id: opcode
    type: opcode
  - id: size
    type: u1
  - id: parameters
    size: size
    type:
      switch-on: opcode.group
      cases:
        "group::vendor_specific": bluetooth_control_group_vendor_specific(vendor, opcode.command)
types:
  opcode:
    seq:
      - id: command
        -orig-id: OpCode Command Field
        type: b10
      - id: group
        -orig-id: OpCode Group Field
        type: b6
        enum: group
enums:
  group:
    0x3f: vendor_specific
