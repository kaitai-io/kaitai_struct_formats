meta:
  id: ipv6_packet
  title: IPv6 network packet
  license: CC0-1.0
  ks-version: 0.8
  endian: be
  imports:
    - /network/protocol_body
seq:
  - id: version
    type: b4
  - id: traffic_class
    type: b8
  - id: flow_label
    type: b20
  - id: payload_length
    type: u2
  - id: next_header_type
    type: u1
  - id: hop_limit
    type: u1
  - id: src_ipv6_addr
    size: 16
  - id: dst_ipv6_addr
    size: 16
  - id: next_header
    type: protocol_body(next_header_type)
  - id: rest
    size-eos: true
