meta:
  id: f2be
  title: IEEE 754 Half-precision floating-point
  license: Unlicense
  endian: be
  xref:
    iso: 60559:2011
    wikidata: Q1994657
  imports:
    - ./ieee754_float
doc: see the doc for `ieee754_float`.
seq:
  - id: sign
    type: b1
  - id: biased_exponent
    type: b5
  - id: fraction
    type: b10
instances:
  value:
    pos: 0
    type: ieee754_float(((1 << (5 - 1)) - 1), 10, 5, sign, biased_exponent, fraction)
