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
    doc: Destination MAC address.
  - id: src_mac
    size: 6
    doc: Source MAC address.
  - id: ether_type
    type: u2be
    enum: ether_type_enum
  - id: body
    size-eos: true
    type:
      switch-on: ether_type
      cases:
        'ether_type_enum::ipv4': ipv4_packet
        'ether_type_enum::ipv6': ipv6_packet
enums:
  # http://www.iana.org/assignments/ieee-802-numbers/ieee-802-numbers.xhtml
  ether_type_enum:
    0x0800: ipv4
    0x0801: x_75_internet
    0x0802: nbs_internet
    0x0803: ecma_internet
    0x0804: chaosnet
    0x0805: x_25_level_3
    0x0806: arp
    0x86dd: ipv6
