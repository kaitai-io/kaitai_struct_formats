meta:
  id: udp_datagram
  endian: be
seq:
  - id: src_port
    type: u2
  - id: dst_port
    type: u2
  - id: length
    type: u2
  - id: checksum
    type: u2
  - id: body
    size-eos: true
