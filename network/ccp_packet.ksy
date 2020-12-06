meta:
  id: ccp_packet
  title: PPP Compression Control Protocol
  xref:
    rfc: 1962
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
      - id: length
        type: u1
      - id: value
        size: length-2
enums:
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
 