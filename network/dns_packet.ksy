meta:
  id: dns_packet
  title: DNS (No support for Auth-Name + Add-Name for simplicity)
  application: https://www.ietf.org/rfc/rfc1035.txt
  endian: be
seq:
  - id: transaction_id
    doc: "ID to keep track of request/responces"
    type: u2
  - id: flags
    type: u2
    doc: "Please add support for bit-flags!"
    enum: flags_type
  - id: questions
    doc: "How many questions are there"
    type: u2
  - id: answer_rrs
    doc: "How many answers are there"
    type: u2
  - id: authority_rrs
    doc: "How many authority answers are there"
    type: u2
  - id: additional_rrs
    doc: "How many additional answers are there"
    type: u2
  - id: queries
    type: query
    repeat: expr
    repeat-expr: questions
  - id: answers
    type: answer
    repeat: expr
    repeat-expr: answer_rrs
types:
  query:
    seq:
      - id: name
        type: domain_name
      - id: type
        type: u2
        enum: type_type
      - id: class
        type: u2
        enum: class_type
  answer:
    seq:
      - id: name
        type: domain_name
      - id: type
        type: u2
        enum: type_type
      - id: class
        type: u2
        enum: class_type
      - id: ttl
        doc: "Time to live"
        type: u4
      - id: data_length
        doc: "This suggests that multiple domain-names can be returned, unsupported currently due to lack of example"
        type: u2
      - id: domain_name
        type: domain_name
  domain_name:
    seq:
      - id: name
        type: label
        repeat: until
        doc: "Repeat until the length is 0 or it is a pointer (bit-hack to get around lack of OR operator)"
        repeat-until: "(_.length & 0b00111111) == 0"
  label:
    seq:
      - id: length
        type: u1
      - id: pointer
        doc: "RFC1035 4.1.4: The OFFSET field specifies an offset from the start of the message"
        doc: "If the first two bits are raised it's a pointer-offset to a previously defined name"
        type: pointer
        if: "((length & 0b11000000)) == 192"
      - id: name
        doc: "Otherwise its a string the length of the length value"
        type: str
        encoding: "ASCII"
        size: length
        if: "((length & 0b11000000)) != 192"
  pointer:
    seq:
      - id: pointer
        doc: "Read one byte, then offset to that position, read one domain-name and return"
        type: u1
    instances:
      contents:
        io: _root._io
        pos: pointer
        type: domain_name
enums:
  flags_type:
    0x0100: "Query_Standard_Query_Not_Auth_No_Trunc_Recursive_Non_Auth_Unacceptable"
    0x8180: "Response_Standard_Query_Not_Auth_No_Trunc_Recursive_Can_Recurse_No_Auth_Non_Auth_Unacceptable_No_Error"
    0x8183: "Response_Standard_Query_Not_Auth_No_Trunc_Recursive_Can_Recurse_No_Auth_Non_Auth_Unacceptable_No_Such_Name"
  class_type:
    1: "IN"
    2: "CS"
    3: "CH"
    4: "HS"
  type_type:
    1: "A"
    2: "NS"
    3: "MD"
    4: "MF"
    5: "CNAME"
    6: "SOA"
    7: "MB"
    8: "MG"
    9: "MR"
    10: "NULL"
    11: "WKS"
    12: "PTR"
    13: "HINFO"
    14: "MINFO"
    15: "MX"
    16: "TXT"
