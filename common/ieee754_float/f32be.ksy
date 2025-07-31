meta:
  id: f32be
  title: IEEE 754 Octuple-precision floating-point
  license: Unlicense
  endian: be
  xref:
    iso: 60559:2011
    wikidata: Q25109769
  imports:
    - ./ieee754_float
doc: see the doc for `ieee754_float`.
seq:
  - id: sign
    type: b1
  - id: biased_exponent
    type: b19
  - id: fraction
    type: b236
instances:
  value:
    pos: 0
    type: ieee754_float((1 << (19 - 1)) - 1, 236, 19, sign, biased_exponent, fraction)
