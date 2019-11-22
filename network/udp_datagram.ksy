meta:
  id: udp_datagram
  title: UDP (User Datagram Protocol) datagram
  xref:
    rfc: 768
    wikidata: Q11163
  license: CC0-1.0
  endian: be
doc: |
  UDP is a simple stateless transport layer (AKA OSI layer 4)
  protocol, one of the core Internet protocols. It provides source and
  destination ports, basic checksumming, but provides not guarantees
  of delivery, order of packets, or duplicate delivery.
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
    size: length - 8
