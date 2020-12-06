meta:
  id: arp_packet
  title: ARP network packet
  endian: be
seq:
  - id: hardware_type
    type: u2be
  - id: protocol_type
    type: u2
  - id: hardware_size
    type: u1
  - id: protocol_size
    type: u1
  - id: opcode
    type: u2
    enum: opcode_enum
  - id: sender_mac
    size: hardware_size
  - id: sender_ip
    size: protocol_size
  - id: target_mac
    size: hardware_size
  - id: target_ip
    size: protocol_size
enums:
  opcode_enum:
    1: request
    2: reply
