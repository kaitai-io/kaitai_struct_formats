meta:
  id: ipcp_packet
  title: PPP Internet Protocol Control Protocol
  xref:
    rfc: 3241
seq:
  - id: code
    type: u1
    enum: code_enum
  - id: identifier
    type: u1
  - id: length
    type: u2be
  - id: options
    size: length-4
    type: options_type
types:
  options_type:
    seq:
      - id: options
        type: option
        repeat: eos
  option:
    seq:
      - id: type
        type: u1
        enum: type_enum
      - id: length
        type: u1
      - id: value
        size: length-2
enums:
  # https://blog.csdn.net/bytxl/article/details/50111971
  code_enum:
    0x01: configure_request
    0x02: configure_ack
    0x03: configure_nak
    0x04: configure_reject
    0x05: terminate_request
    0x06: terminate_ack
    0x07: code_reject
  type_enum:
    0x01: ip_addresses
    0x02: ip_compression_protocol
    0x03: ip_address
     