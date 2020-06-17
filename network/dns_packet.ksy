meta:
  id: dns_packet
  title: DNS (Domain Name Service) packet
  xref:
    rfc: 1035
  license: CC0-1.0
  endian: be
  encoding: utf-8
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
    if: flags.is_opcode_valid
    type: u2
  - id: ancount
    doc: "Number of resource records answering the question"
    if: flags.is_opcode_valid
    type: u2
  - id: nscount
    doc: "Number of resource records pointing toward an authority"
    if: flags.is_opcode_valid
    type: u2
  - id: arcount
    doc: "Number of resource records holding additional information"
    if: flags.is_opcode_valid
    type: u2
  - id: queries
    if: flags.is_opcode_valid
    type: query
    repeat: expr
    repeat-expr: qdcount
  - id: answers
    if: flags.is_opcode_valid
    type: answer
    repeat: expr
    repeat-expr: ancount
  - id: additionals
    if: flags.is_opcode_valid
    type: answer
    repeat: expr
    repeat-expr: arcount
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
      - id: payload
        size: rdlength
        type:
          switch-on: type
          cases:
            "type_type::ptr": domain_name
            "type_type::a": address
            "type_type::aaaa": address_v6
            "type_type::cname": domain_name
            "type_type::srv": service
            "type_type::txt": txt_body
  domain_name:
    seq:
      - id: name
        type: label
        repeat: until
        doc: "Repeat until the length is 0 or it is a pointer (bit-hack to get around lack of OR operator)"
        repeat-until: "_.length == 0 or _.length >= 192"
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
        size: length
    instances:
      is_pointer:
        value: length >= 192
  pointer_struct:
    seq:
      - id: value
        doc: "Read one byte, then offset to that position, read one domain-name and return"
        type: u1
    instances:
      contents:
        io: _root._io
        pos: value + ((_parent.length - 192) << 8)
        type: domain_name
  address:
    seq:
      - id: ip
        type: u1
        repeat: expr
        repeat-expr: 4
  address_v6:
    seq:
      - id: ip_v6
        type: u1
        repeat: expr
        repeat-expr: 16
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
      is_opcode_valid:
        value: opcode == 0 or opcode == 1 or opcode == 2
  service:
    seq:
      - id: priority
        type: u2
      - id: weight
        type: u2
      - id: port
        type: u2
      - id: target
        type: domain_name
  txt:
    seq:
      - id: length
        type: u1
      - id: text
        type: str
        size: length
  txt_body:
    seq:
      - id: data
        type: txt
        repeat: eos

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
    28: aaaa
    33: srv
