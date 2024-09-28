meta:
  id: f8be
  title: IEEE 754 Double-precision floating-point
  license: Unlicense
  endian: be
  xref:
    iso: "60559:2011"
    wikidata: Q1243369
  imports:
    - ./ieee754_float
doc: |
  YOU LIKELY DON'T NEED THIS. `f8` is implemented in all modern PC CPUs and programming languages natively. It is here mainly for testing purposes.
  See the doc for `float` on the drawbacks of this impl.
seq:
  - id: sign
    type: b1
  - id: biased_exponent
    type: b11
  - id: fraction
    type: b52
instances:
  value:
    pos: 0
    type: float(1023, 52, 11, sign, biased_exponent, fraction)
