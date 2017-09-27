meta:
  id: dns_packet
  title: DNS (Domain Name Service) packet
  xref:
    rfc: 1035
  license: CC0-1.0
  endian: be
doc: |
  (No support for Auth-Name + Add-Name for simplicity)
seq:
  - id: transaction_id
    doc: "ID to keep track of request/responces"
    type: u2
  - id: flags
    type: packet_flags
  - id: qdcount
    doc: "How many questions are there"
    type: u2
  - id: ancount
    doc: "Number of resource records answering the question"
    type: u2
  - id: nscount
    doc: "Number of resource records pointing toward an authority"
    type: u2
  - id: arcount
    doc: "Number of resource records holding additional information"
    type: u2
  - id: queries
    type: query
    repeat: expr
    repeat-expr: qdcount
  - id: answers
    type: answer
    repeat: expr
    repeat-expr: ancount
types:
  query:
    seq: 
      - id: name
        type: domain_name
      - id: type
        type: u2
        enum: type_type
      - id: query_class
        type: u2
        enum: class_type
  answer:
    seq:
      - id: name
        type: domain_name
      - id: type
        type: u2
        enum: type_type
      - id: answer_class
        type: u2
        enum: class_type
      - id: ttl
        doc: "Time to live (in seconds)"
        type: s4
      - id: rdlength
        doc: "Length in octets of the following payload"
        type: u2
      - id: ptrdname
        type: domain_name
        if: "type == type_type::ptr"
      - id: address
        type: address
        if: "type == type_type::a"
  domain_name:
    seq:
      - id: name
        type: label
        repeat: until
        doc: "Repeat until the length is 0 or it is a pointer (bit-hack to get around lack of OR operator)"
        repeat-until: "_.length == 0 or _.length == 0b1100_0000"
  label:
    seq:
      - id: length
        doc: "RFC1035 4.1.4: If the first two bits are raised it's a pointer-offset to a previously defined name"
        type: u1
      - id: pointer
        if: "is_pointer"
        type: pointer_struct
      - id: name
        if: "not is_pointer"
        doc: "Otherwise its a string the length of the length value"
        type: str
        encoding: "ASCII"
        size: length
    instances:
      is_pointer:
        value: length == 0b1100_0000
  pointer_struct:
    seq:
      - id: value
        doc: "Read one byte, then offset to that position, read one domain-name and return"
        type: u1
    instances:
      contents:
        io: _root._io
        pos: value
        type: domain_name
  address:
    seq:
      - id: ip
        type: u1
        repeat: expr
        repeat-expr: 4
  packet_flags:
    seq:
      - id: flag
        type: u2
    instances:
      qr:
        value: (flag & 0b1000_0000_0000_0000) >> 15
      opcode:
        value: (flag & 0b0111_1000_0000_0000) >> 11
      aa:
        value: (flag & 0b0000_0100_0000_0000) >> 10
      tc:
        value: (flag & 0b0000_0010_0000_0000) >> 9
      rd:
        value: (flag & 0b0000_0001_0000_0000) >> 8
      ra:
        value: (flag & 0b0000_0000_1000_0000) >> 7
      z:
        value: (flag & 0b0000_0000_0100_0000) >> 6
      ad:
        value: (flag & 0b0000_0000_0010_0000) >> 5
      cd:
        value: (flag & 0b0000_0000_0001_0000) >> 4
      rcode:
        value: (flag & 0b0000_0000_0000_1111) >> 0
        
enums:
  class_type:
    1: in_class
    2: cs
    3: ch
    4: hs
  type_type:
    1: a
    2: ns
    3: md
    4: mf
    5: cname
    6: soe
    7: mb
    8: mg
    9: mr
    10: "null"
    11: wks
    12: ptr
    13: hinfo
    14: minfo
    15: mx
    16: txt
