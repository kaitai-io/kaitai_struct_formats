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
  - id: direction
    type: u4be
    enum: direction_enum
    doc-ref: https://github.com/the-tcpdump-group/libpcap/blob/master/pcap/bluetooth.h#L44
    doc: |
      packet direction
  - id: hci_packet_type
    type: u1
    enum: hci_packet_type_enum
  - id: hci_packet
    type:
      switch-on: hci_packet_type
      cases:
        # TODO add other HCI packet types
        'hci_packet_type_enum::hci_h4_type_acl': hci_acl_data
    doc-ref: https://www.bluetooth.org/docman/handlers/downloaddoc.ashx?doc_id=457080 page 769

enums:
  direction_enum:
    0: sent
    1: received
  hci_packet_type_enum:
    # https://github.com/bluez/bluez/blob/87d6b1340204cf6694aa08bc23fdb34230e5a1e7/monitor/bt.h#L490
    # https://www.bluetooth.org/docman/handlers/downloaddoc.ashx?doc_id=457080 page 771
    0x01: hci_h4_type_cmd
    0x02: hci_h4_type_acl
    0x03: hci_h4_type_sco
    0x04: hci_h4_type_evt
    0x05: hci_h4_type_iso

types:
  hci_acl_data:
    doc-ref: https://www.bluetooth.org/docman/handlers/downloaddoc.ashx?doc_id=457080 page 771
    doc: HCI ACL Data packet
    seq:
    - id: handle
      type: b12
    - id: pb_flag
      type: b2
      doc: Packet Boundary Flag
    - id: bc_flag
      type: b2
      doc: Broadcast Flag
    - id: data_len
      type: u2
      doc: Length of the HCI ACL Data payload
    - id: body
      size: data_len
      # TODO: add more ACL Data payload types
      type: l2cap

  l2cap:
    doc-ref: https://www.bluetooth.org/docman/handlers/downloaddoc.ashx?doc_id=457080 page 1829
    doc: Logical Link Control and Adaptation Protocol
    seq:
      - id: len_payload
        type: u2
      - id: cid
        type: u2
        valid:
          eq: 0x0004 # for ATT
# TODO: other L2CAP types here
      - id: payload
        size: len_payload
        type: bluetooth_att
