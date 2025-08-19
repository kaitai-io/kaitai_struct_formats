meta:
  id: usb_pcap_endpoint_number
  license: Unlicense
  endian: le
seq:
  - id: is_input
    type: b1
    doc: if the bit is set, the direction is input (from the device to the host), otherwise it is output (from the host to the device).
  - id: endpoint
    type: b7
    doc: endpoint number used on the USB bus
