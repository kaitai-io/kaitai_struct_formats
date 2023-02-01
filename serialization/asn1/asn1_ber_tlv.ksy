meta:
  id: asn1_ber_tlv
  file-extension: tlv
  title: ASN.1 BER TLV
  license: CC0-1.0
  xref:
    justsolve: BER
    wikidata: Q2738854
  
  imports:
    - asn1_ber_tag
    - asn1_ber_length

doc: Basic Encoding Rules (BER) TLV formatting rules.
doc-ref: https://en.wikipedia.org/wiki/X.690#BER_encoding X.690 BER encoding


seq:
  - id: tag
    type: asn1_ber_tag
  - id: length
    type: asn1_ber_length
  - id: value_primitive
    type: u1
    if: (tag.form == tag_form::primitive_form)
    repeat: expr
    repeat-expr: length.val_len
  - id: value_constructed
    type: asn1_ber_tlv
    if: (tag.form == tag_form::constructed_form)
    repeat: eos

enums:
  tag_form:
    0: primitive_form # 'Primitive Form - The contents octets directly encode the value.'
    1: constructed_form # 'Constructed Form - The contents octets contain 0, 1, or more encodings.'