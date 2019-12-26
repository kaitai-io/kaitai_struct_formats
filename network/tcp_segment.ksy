meta:
  id: tcp_segment
  title: TCP segment
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
  - id: header_length
    type: b4
  - id: flags
    type: b12
  - id: window_size
    type: u2
  - id: checksum
    type: u2
  - id: urgent_pointer
    type: u2
  - id: body
    size-eos: true