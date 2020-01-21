meta:
  id: field_spec
  license: GPL-3.0-only
  endian: be
  ks-version: 0.9

doc: |
  Implementantion of ASTERIX format.

  From Eurocontrol Asterix web page at
  https://www.eurocontrol.int/asterix

  The field_spec type, is an encapsulation of the Fiel Spec field. This is also
  used in the Compound format field as a primary part of the field.

seq:
  - id: octects
    type: bits_t
    repeat: until
    repeat-until: not _.fx

types:

  bits_t:

    seq:
      - id: bits
        type: b1
        repeat: expr
        repeat-expr: 7
      - id: fx
        type: b1

instances:
  size:
    value: 7 * octects.size
