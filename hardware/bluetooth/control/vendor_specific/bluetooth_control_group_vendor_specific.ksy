meta:
  id: bluetooth_control_group_vendor_specific
  title: Vendor-specific HCI commands
  license: Unlicense
  endian: le
  imports:
    - ../../bluetooth_vendors_ids
    - cypress_semiconductor/bluetooth_control_group_vendor_specific_cypress
params:
  - id: vendor
    type: u2
    enum: bluetooth_vendors_ids::vendor
  - id: command
    type: u2  # should be u10, bit-sized types don't work in WebIDE
seq:
  - id: payload
    size-eos: true
    type:
      switch-on: vendor
      cases:
        bluetooth_vendors_ids::vendor::cypress_semiconductor: bluetooth_control_group_vendor_specific_cypress(command)
