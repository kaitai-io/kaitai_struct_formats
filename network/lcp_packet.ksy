meta:
  id: lcp_packet
  title: PPP Link Control Protocol
  xref:
    rfc: 1611
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
    0x08: protocol_reject
    0x09: echo_request
    0x0A: echo_reply
    0x0B: discard_request
    0x0C: reserved
  type_enum:
    0x00: reserved
    0x05: magic_number
    0x01: maximum_recieve_unit
    0x06: cbcp
    0x02: async_control_character_map
    0x07: protocol_field_compress
    0x03: authentication_protocol
    0x08: address_and_control_field_compress
    0x04: quality_protocol
    0x0d: multilink_protocol
 