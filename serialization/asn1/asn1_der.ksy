meta:
  id: asn1_der
seq:
  - id: type_tag
    type: u1
    enum: type_tag
  - id: len
    type: len_encoded
  - id: body
    size: len.result
    type:
      switch-on: type_tag
      cases:
        'type_tag::sequence_10': body_sequence
        'type_tag::sequence_30': body_sequence
        'type_tag::set': body_sequence
        'type_tag::utf8string': body_utf8string
        'type_tag::printable_string': body_printable_string
types:
  len_encoded:
    seq:
      - id: b1
        type: u1
      - id: int2
        type: u2be
        if: b1 == 0x82
    instances:
      result:
        value: '(b1 & 0x80 == 0) ? b1 : int2'
  body_sequence:
    seq:
      - id: entries
        type: asn1_der
        repeat: eos
  body_utf8string:
    seq:
      - id: str
        type: str
        size-eos: true
        encoding: UTF-8
  body_printable_string:
    seq:
      - id: str
        type: str
        size-eos: true
        encoding: ASCII # actually a subset of ASCII
enums:
  type_tag:
    0: end_of_content
    0x1: boolean
    0x2: integer
    0x3: bit_string
    0x4: octet_string
    0x5: null_value
    0x6: object_id
    0x7: object_descriptor
    0x8: external
    0x9: real
    0xa: enumerated
    0xb: embedded_pdv
    0xc: utf8string
    0xd: relative_oid
    0x10: sequence_10
    0x13: printable_string
    0x16: ia5string
    0x30: sequence_30
    0x31: set

