meta:
  id: ethernet_frame
  title: Ethernet frame (layer 2, IEEE 802.3)
  xref:
    ieee: 802.3
    wikidata: Q11331406
  license: CC0-1.0
  ks-version: 0.8
  imports:
    - /network/ipv4_packet
    - /network/ipv6_packet
doc: |
  Ethernet frame is a OSI data link layer (layer 2) protocol data unit
  for Ethernet networks. In practice, many other networks and/or
  in-file dumps adopted the same format for encapsulation purposes.
doc-ref: https://ieeexplore.ieee.org/document/7428776
seq:
  - id: dst_mac
    size: 6
    doc: Destination MAC address
  - id: src_mac
    size: 6
    doc: Source MAC address
  - id: ether_type_1
    type: u2be
    enum: ether_type_enum
    doc: Either ether type or TPID if it is a IEEE 802.1Q frame
  - id: tci
    type: tag_control_info
    if: ether_type_1 == ether_type_enum::ieee_802_1q_tpid
  - id: ether_type_2
    type: u2be
    enum: ether_type_enum
    if: ether_type_1 == ether_type_enum::ieee_802_1q_tpid
  - id: body
    size-eos: true
    type:
      switch-on: ether_type
      cases:
        'ether_type_enum::ipv4': ipv4_packet
        'ether_type_enum::ipv6': ipv6_packet
instances:
  ether_type:
    value: |
      (ether_type_1 == ether_type_enum::ieee_802_1q_tpid) ? ether_type_2 : ether_type_1
    doc: |
      Ether type can be specied in several places in the frame. If
      first location bears special marker (0x8100), then it is not the
      real ether frame yet, an additional payload (`tci`) is expected
      and real ether type is upcoming next.
types:
  tag_control_info:
    doc: |
      Tag Control Information (TCI) is an extension of IEEE 802.1Q to
      support VLANs on normal IEEE 802.3 Ethernet network.
    seq:
      - id: priority
        type: b3
        doc: |
          Priority Code Point (PCP) is used to specify priority for
          different kinds of traffic.
      - id: drop_eligible
        type: b1
        doc: |
          Drop Eligible Indicator (DEI) specifies if frame is eligible
          to dropping while congestion is detected for certain classes
          of traffic.
      - id: vlan_id
        type: b12
        doc: |
          VLAN Identifier (VID) specifies which VLAN this frame
          belongs to.
enums:
  # https://www.iana.org/assignments/ieee-802-numbers/ieee-802-numbers.xhtml
  ether_type_enum:
    0x0800: ipv4
    0x0801: x_75_internet
    0x0802: nbs_internet
    0x0803: ecma_internet
    0x0804: chaosnet
    0x0805: x_25_level_3
    0x0806: arp
    0x8100: ieee_802_1q_tpid
    0x86dd: ipv6
    #0x88a8: ieee_802_1ad_tpid
