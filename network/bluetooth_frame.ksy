meta:
  id: bluetooth_frame
  title: Bluetooth frame (layer 2, IEEE 802.15.1)
  xref:
    ieee: 802.15.1
  license: CC0-1.0
  ks-version: 0.8
  endian: le
  imports:
    - /network/bluetooth_att
doc: |
  Bluetooth frame is a OSI data link layer (layer 2) and higher protocol data
  unit for Bluetooth networks.
doc-ref: https://www.bluetooth.org/docman/handlers/downloaddoc.ashx?doc_id=457080
seq:
  - id: fixme_filler0
    contents: [0,0,0]
    doc: FIXME: maybe join to the "direction" field?
  - id: direction
    type: u1
    enum: direction_enum
    doc: |
      packet direction
      https://code.wireshark.org/review/gitweb?p=wireshark.git;a=blob;f=epan/dissectors/packet-bluetooth.h;hb=HEAD
  - id: hci_packet_type
    type: u1
    enum: hci_packet_type_enum
#    contents: [hci_packet_type_enum::hci_h4_type_acl] # for L2CAP
# TODO: other HCI types here
  - id: hci_acl_handle_and_flags
    type: u2
    doc: |
      FIXME: split handle_and_flags
      page 771
  - id: hci_packet_len
    type: u2
    doc: Length of the HCI payload
  - id: body
    size: hci_packet_len
    type: l2cap

enums:
  direction_enum:
    0: sent
    1: received
  hci_packet_type_enum:
    0x01: hci_h4_type_cmd
    0x02: hci_h4_type_acl
    0x03: hci_h4_type_sco
    0x04: hci_h4_type_evt

types:
  l2cap:
    doc: |
      Logical Link Control and Adaptation Protocol, page 1829
    seq:
      - id: length
        type: u2
      - id: cid
#        type: u2
        contents: [0x04,0x00] # for ATT
# TODO: other L2CAP types here
      - id: payload
        size: length
        type: bluetooth_att

