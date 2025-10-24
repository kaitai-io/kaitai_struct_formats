meta:
  id: bluetooth_hcd
  title: Bluetooth Host Controller Interface Control Protocol
  license: Unlicense
  file-extension: hcd
  endian: le
  imports:
    - control/bluetooth_control_command
    - bluetooth_vendors_ids
  xref:
    wikidata: Q39531
    ieee: 802.15.1
doc: |
  Bluetooth Host Controller Interface protocol.
doc-ref:
  - https://www.bluetooth.org/docman/handlers/downloaddoc.ashx?doc_id=478726
  - https://software-dl.ti.com/simplelink/esd/simplelink_cc13x2_sdk/1.60.00.29_new/exports/docs/ble5stack/vendor_specific_guide/BLE_Vendor_Specific_HCI_Guide/hci_interface.html
  - https://www.ti.com/lit/ug/swru442b/swru442b.pdf?ts=1594902336269
  - https://community.nxp.com/docs/DOC-341764
params:
  - id: vendor
    type: u2
    enum: bluetooth_vendors_ids::vendor
seq:
  - id: commands
    type: bluetooth_control_command(vendor)
    repeat: eos
