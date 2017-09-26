meta:
  id: ipv6_packet
  title: IPv6 network packet
  license: CC0-1.0
  ks-version: 0.7
  endian: be
  imports:
    - /network/tcp_segment
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
    type:
      switch-on: next_header_type
      cases:
        0: option_hop_by_hop
        4: ipv4_packet
        6: tcp_segment
        17: udp_datagram
        59: no_next_header
  - id: rest
    size-eos: true
types:
  no_next_header: {}
  option_hop_by_hop:
    seq:
      - id: next_header_type
        type: u1
      - id: hdr_ext_len
        type: u1
      - id: body
        size: hdr_ext_len - 1
      - id: next_header
        type:
          switch-on: next_header_type
          cases:
            0: option_hop_by_hop
            6: tcp_segment
            59: no_next_header
