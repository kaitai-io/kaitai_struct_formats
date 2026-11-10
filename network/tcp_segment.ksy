meta:
  id: tcp_segment
  title: TCP (Transmission Control Protocol) segment
  xref:
    rfc:
      - 793
      - 1323
      - 9293
    wikidata: Q8803
  license: CC0-1.0
  endian: be
  ks-version: '0.10'
doc: |
  TCP is one of the core Internet protocols on transport layer (AKA
  OSI layer 4), providing stateful connections with error checking,
  guarantees of delivery, order of segments and avoidance of duplicate
  delivery.
seq:
  - id: src_port
    type: u2
    doc: Source port
  - id: dst_port
    type: u2
    doc: Destination port
  - id: seq_num
    type: u4
    doc: Sequence number
  - id: ack_num
    type: u4
    doc: Acknowledgment number
  - id: data_offset
    type: b4
    doc: Data offset (in 32-bit words from the beginning of this type, normally 32 or can be extended if there are any TCP options or padding is present)
  - id: reserved
    type: b4
  - id: flags
    type: flags
  - id: window_size
    type: u2
  - id: checksum
    type: u2
  - id: urgent_pointer
    type: u2
  - id: options
    size: (data_offset * 4) - 20
    if: ((data_offset * 4) - 20) != 0
  - id: body
    size-eos: true
types:
  flags:
    doc: |
      TCP header flags as defined "TCP Header Flags" registry.
    to-string: |
      (cwr ? "|CWR" : "") +
      (ece ? "|ECE" : "") +
      (urg ? "|URG" : "") +
      (ack ? "|ACK" : "") +
      (psh ? "|PSH" : "") +
      (rst ? "|RST" : "") +
      (syn ? "|SYN" : "") +
      (fin ? "|FIN" : "")
    seq:
      - id: cwr
        type: b1
        doc: Congestion Window Reduced
      - id: ece
        type: b1
        doc: ECN-Echo
      - id: urg
        type: b1
        doc: Urgent pointer field is significant
      - id: ack
        type: b1
        doc: Acknowledgment field is significant
      - id: psh
        type: b1
        doc: Push function
      - id: rst
        type: b1
        doc: Reset the connection
      - id: syn
        type: b1
        doc: Synchronize sequence numbers
      - id: fin
        type: b1
        doc: No more data from sender
