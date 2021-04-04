meta:
  id: ipv4_packet
  title: IPv4 network packet
  xref:
    rfc: 791
    wikidata: Q11103
  license: CC0-1.0
  ks-version: 0.8
  imports:
    - /network/protocol_body
seq:
  - id: b1
    type: u1
  - id: b2
    type: u1
  - id: total_length
    type: u2be
  - id: identification
    type: u2be
  - id: b67
    type: u2be
  - id: ttl
    type: u1
  - id: protocol
    type: u1
  - id: header_checksum
    type: u2be
  - id: src_ip_addr
    size: 4
  - id: dst_ip_addr
    size: 4
  - id: options
    type: ipv4_options
    size: ihl_bytes - 20
  - id: body
    size: total_length - ihl_bytes
    type: protocol_body(protocol)
instances:
  version:
    value: (b1 & 0xf0) >> 4
  ihl:
    value: b1 & 0xf
  ihl_bytes:
    value: ihl * 4
types:
  ipv4_options:
    seq:
      - id: entries
        type: ipv4_option
        repeat: eos
  ipv4_option:
    seq:
      - id: b1
        type: u1
      - id: len
        type: u1
      - id: body
        size: 'len > 2 ? len - 2 : 0'
    instances:
      copy:
        value: (b1 & 0b10000000) >> 7
      opt_class:
        value: (b1 & 0b01100000) >> 5
      number:
        value: (b1 & 0b00011111)
