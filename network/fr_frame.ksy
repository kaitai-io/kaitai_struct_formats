meta:
  id: fr_frame
  title: frame relay 
  #http://www.rhyshaden.com/frame.htm
  imports:
    - ipv4_packet
seq:
  - id: first_address_octet
    type: u1
  - id: second_address_octet
    type: u1
  - id: type
    type: u2be
    enum: type_enum
  - id: body
    size-eos: true
    type: 
      switch-on: type
      cases:
        'type_enum::ipv4': ipv4_packet
instances:
  dlci:
    value: ((first_address_octet & 0xfc) << 2) + ((second_address_octet & 0xf0) >> 4)
types:
  address:
    seq:
      - id: first_address_octet
        type: u1
      - id: second_address_octet
        type: u1
enums:
  type_enum:
    0x0800: ipv4
