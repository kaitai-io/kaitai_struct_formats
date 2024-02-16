meta:
  id: f4be
  title: IEEE 754 Single-precision floating-point
  license: Unlicense
  endian: be
  xref:
    iso: "60559:2011"
    wikidata: Q1307173
  imports:
    - ./ieee754_float
doc: |
  YOU LIKELY DON'T NEED THIS. `f4` is implemented in all modern hardware and programming languages natively. It is here mainly for testing purposes.
  See the doc for `float` on the drawbacks of this impl.
seq:
  - id: sign
    type: b1
  - id: biased_exponent
    type: b8
  - id: fraction
    type: b23
instances:
  value:
    pos: 0
    type: float(127, 23, 8, sign, biased_exponent, fraction)
