meta:
  id: tcp_segment
  title: TCP (Transmission Control Protocol) segment
  xref:
    rfc:
      - 793
      - 1323
    wikidata: Q8803
  license: CC0-1.0
  endian: be
doc: |
  TCP is one of the core Internet protocols on transport layer (AKA
  OSI layer 4), providing stateful connections with error checking,
  guarantees of delivery, order of segments and avoidance of duplicate
  delivery.
seq:
  - id: src_port
    type: u2
  - id: dst_port
    type: u2
  - id: seq_num
    type: u4
  - id: ack_num
    type: u4
  - id: b12
    type: u1
  - id: b13
    type: u1
  - id: window_size
    type: u2
  - id: checksum
    type: u2
  - id: urgent_pointer
    type: u2
  - id: body
    size-eos: true
