meta:
  id: asn1_ber_tag
  title: ASN.1 BER tag
  license: CC0-1.0
  xref:
    justsolve: BER
    wikidata: Q2738854
  
doc: Basic Encoding Rules (BER) tag formatting rules.
doc-ref: https://en.wikipedia.org/wiki/X.690#BER_encoding X.690 BER encoding

seq:
  - id: tag_first_byte
    type: u1
  - id: tag_subsequent_bytes
    type: u1
    if: ((tag_first_byte & 0b00011111) == 0b00011111)
    repeat: until
    repeat-until: (_ < 0x80)
instances:
  class:
    value: (tag_first_byte & 0b11000000) >> 6
    enum: tag_class
  form:
    value: (tag_first_byte & 0b00100000) >> 5
    enum: tag_form
  tag_type:
    value: (tag_first_byte & 0b00011111)
    enum: tag_primitive
  tag_len:
    value: ((tag_first_byte & 0b00011111) == 0b00011111) ? (1 + tag_subsequent_bytes.size) : (1)

enums:
  tag_class:
    0: universal_class # 'Universal Class - The type is native to ASN.1'
    1: application_class # 'Application Class - The type is only valid for one specific application'
    2: context_specific_class # 'Context-Specific Class - Meaning of this type depends on the context (such as within a sequence, set or choice) '
    3: private_class # 'Private Class - Defined in private specifications'
  tag_form:
    0: primitive_form # 'Primitive Form - The contents octets directly encode the value.'
    1: constructed_form # 'Constructed Form - The contents octets contain 0, 1, or more encodings.'
  tag_primitive:
    0: short_form_tag_00 # 'Short Form tag 00'
    1: short_form_tag_01 # 'Short Form tag 01'
    2: short_form_tag_02 # 'Short Form tag 02'
    3: short_form_tag_03 # 'Short Form tag 03'
    4: short_form_tag_04 # 'Short Form tag 04'
    5: short_form_tag_05 # 'Short Form tag 05'
    6: short_form_tag_06 # 'Short Form tag 06'
    7: short_form_tag_07 # 'Short Form tag 07'
    8: short_form_tag_08 # 'Short Form tag 08'
    9: short_form_tag_09 # 'Short Form tag 09'
    10: short_form_tag_10 # 'Short Form tag 10'
    11: short_form_tag_11 # 'Short Form tag 11'
    12: short_form_tag_12 # 'Short Form tag 12'
    13: short_form_tag_13 # 'Short Form tag 13'
    14: short_form_tag_14 # 'Short Form tag 14'
    15: short_form_tag_15 # 'Short Form tag 15'
    16: short_form_tag_16 # 'Short Form tag 16'
    17: short_form_tag_17 # 'Short Form tag 17'
    18: short_form_tag_18 # 'Short Form tag 18'
    19: short_form_tag_19 # 'Short Form tag 19'
    20: short_form_tag_20 # 'Short Form tag 20'
    21: short_form_tag_21 # 'Short Form tag 21'
    22: short_form_tag_22 # 'Short Form tag 22'
    23: short_form_tag_23 # 'Short Form tag 23'
    24: short_form_tag_24 # 'Short Form tag 24'
    25: short_form_tag_25 # 'Short Form tag 25'
    26: short_form_tag_26 # 'Short Form tag 26'
    27: short_form_tag_27 # 'Short Form tag 27'
    28: short_form_tag_28 # 'Short Form tag 28'
    29: short_form_tag_29 # 'Short Form tag 29'
    30: short_form_tag_30 # 'Short Form tag 30'
    31: long_form # 'Long Form tag'