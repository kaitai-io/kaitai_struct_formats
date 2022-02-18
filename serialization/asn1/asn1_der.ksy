meta:
  id: asn1_der
  title: ASN.1 DER (Abstract Syntax Notation One, Distinguished Encoding Rules)
  file-extension: der
  xref:
    justsolve: DER
    wikidata: Q28600469
  license: CC0-1.0
doc: |
  ASN.1 (Abstract Syntax Notation One) DER (Distinguished Encoding
  Rules) is a standard-backed serialization scheme used in many
  different use-cases. Particularly popular usage scenarios are X.509
  certificates and some telecommunication / networking protocols.

  DER is self-describing encoding scheme which allows representation
  of simple, atomic data elements, such as strings and numbers, and
  complex objects, such as sequences of other elements.

  DER is a subset of BER (Basic Encoding Rules), with an emphasis on
  being non-ambiguous: there's always exactly one canonical way to
  encode a data structure defined in terms of ASN.1 using DER.

  This spec allows full parsing of format syntax, but to understand
  the semantics, one would typically require a dictionary of Object
  Identifiers (OIDs), to match OID bodies against some human-readable
  list of constants. OIDs are covered by many different standards,
  so typically it's simpler to use a pre-compiled list of them, such
  as:

  * https://www.cs.auckland.ac.nz/~pgut001/dumpasn1.cfg
  * http://oid-info.com/
  * https://www.alvestrand.no/objectid/top.html
doc-ref: https://www.itu.int/itu-t/recommendations/rec.aspx?rec=12483&lang=en
-webide-representation: 't={type_tag}, b={body}'
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
        'type_tag::object_id': body_object_id
        'type_tag::sequence_10': body_sequence
        'type_tag::sequence_30': body_sequence
        'type_tag::set': body_sequence
        'type_tag::utf8string': body_utf8string
        'type_tag::printable_string': body_printable_string
types:
  len_encoded:
    -webide-representation: 'v={result:dec}'
    seq:
      - id: b1
        type: u1
      - id: int2
        type: u2be
        if: b1 == 0x82
      - id: int1
        type: u1
        if: b1 == 0x81
    instances:
      result:
        value: '(b1 == 0x81) ? int1 : ((b1 == 0x82) ? int2 : b1)'
        -webide-parse-mode: eager
  body_sequence:
    -webide-representation: '[...]'
    seq:
      - id: entries
        type: asn1_der
        repeat: eos
  body_utf8string:
    -webide-representation: '{str}'
    seq:
      - id: str
        type: str
        size-eos: true
        encoding: UTF-8
  body_printable_string:
    -webide-representation: '{str}'
    seq:
      - id: str
        type: str
        size-eos: true
        encoding: ASCII # actually a subset of ASCII
  body_object_id:
    -webide-representation: '{first:dec}.{second:dec}.{rest}'
    doc-ref: https://docs.microsoft.com/en-us/windows/desktop/SecCertEnroll/about-object-identifier
    seq:
      - id: first_and_second
        type: u1
      - id: rest
        size-eos: true
    instances:
      first:
        value: first_and_second / 40
      second:
        value: first_and_second % 40
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
