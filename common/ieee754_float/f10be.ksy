meta:
  id: f10be
  title: IEEE 754 Extended-precision floating-point
  license: Unlicense
  endian: be
  xref:
    iso: 60559:2011
    wikidata: Q5421900
  imports:
    - ./ieee754_float
doc: see the doc for `ieee754_float`.
seq:
  - id: sign
    type: b1
  - id: biased_exponent
    type: b15
  - id: integer
    type: b1
  - id: fraction
    type: b63
instances:
  value:
    pos: 0
    type: ieee754_float((1 << (15 - 1)) - 1, 63, 15, sign, biased_exponent, fraction)
