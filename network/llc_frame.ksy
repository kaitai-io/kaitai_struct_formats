meta:
  id: llc_frame
  title: Logical-link control
  endian: be
  #http://www.networksorcery.com/enp/protocol/IEEE8022.htm
  imports:
    - mpls
seq:
  - id: dsap
    contents: [0xaa]
  - id: ssap
    contents: [0xaa]
  - id: control
    type: control_field
  - id: organization_code
    size: 3
  - id: ether_type
    type: u2
    enum: ether_type_enum 
  - id: body
    size-eos: true
    type:
      switch-on: ether_type
      cases:
        'ether_type_enum::mpls': mpls
types:
  control_field:
      seq:
        - id: command
          type: b6
        - id: frame_type
          type: b2
        - id: additional
          size: frame_type == 0x03 ? 0 : 1
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
    0x8847: mpls
