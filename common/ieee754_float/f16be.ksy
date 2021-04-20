meta:
  id: f16be
  title: IEEE 754 Quadruple-precision floating-point
  license: Unlicense
  endian: be
  xref:
    iso: "60559:2011"
    wikidata: Q448573
  imports:
    - ./ieee754_float
doc: "see the doc for `ieee754_float`."
seq:
  - id: sign
    type: b1
  - id: biased_exponent
    type: b15
  - id: fraction
    type: b112
instances:
  value:
    pos: 0
    type: float(262143, 112, 15, sign, biased_exponent, fraction)
