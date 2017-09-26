meta:
  id: tcp_segment
  title: TCP segment
  license: CC0-1.0
  endian: be
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
