meta:
  id: f1
  title: IEEE 754-like Minifloat
  license: Unlicense
  xref:
    wikidata: Q449270
  imports:
    - ./ieee754_float
doc: see the doc for `ieee754_float`.
seq:
  - id: sign
    type: b1
  - id: biased_exponent
    type: b4
  - id: fraction
    type: b3
instances:
  value:
    pos: 0
    type: ieee754_float(-2, 3, 4, sign, biased_exponent, fraction)
