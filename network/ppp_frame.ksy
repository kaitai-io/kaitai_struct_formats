meta:
  id: ppp_frame
  title: Point-to-Point Protocol
  xref:
    rfc: 1611
  imports:
    - ipv4_packet
    - lcp_packet
    - ipcp_packet
    - ccp_packet
seq:
  - id: address
    contents: [0xff]
  - id: control
    contents: [0x03]
  - id: protocol
    type: u2be
    enum: protocol_enum
  - id: body
    size-eos: true
    type:
      switch-on: protocol
      cases:
        'protocol_enum::ipv4': ipv4_packet
        'protocol_enum::lcp': lcp_packet
        'protocol_enum::ipcp': ipcp_packet
        'protocol_enum::ccp': ccp_packet
enums:
  # http://www.iana.org/assignments/ieee-802-numbers/ieee-802-numbers.xhtml
  protocol_enum:
    0x0021: ipv4
    0xc021: lcp
    0x8021: ipcp
    0x80fd: ccp