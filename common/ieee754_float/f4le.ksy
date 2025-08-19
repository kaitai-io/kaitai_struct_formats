meta:
  id: f4le
  title: IEEE 754 Single-precision floating-point
  license: Unlicense
  endian: be
  xref:
    iso: 60559:2011
    wikidata: Q1307173
  imports:
    - ./ieee754_float
doc: |
  YOU LIKELY DON'T NEED THIS. `f4` is implemented in all modern hardware and programming languages natively. It is here mainly for testing purposes.
  See the doc for `float` on the drawbacks of this impl.
  ffffffff ffffffff efffffff s eeeeeee
seq:
  - id: fraction_lo
    type: u2le
  - id: biased_exponent_lo
    type: b1
  - id: fraction_hi
    type: b7
  - id: sign
    type: b1
  - id: biased_exponent_hi
    type: b7
instances:
  biased_exponent:
    value: biased_exponent_hi<<1 | biased_exponent_lo.to_i
  fraction:
    value: fraction_hi<<16 | fraction_lo
  value:
    pos: 0
    type: ieee754_float((1 << (8 - 1)) - 1, 23, 8, sign, biased_exponent, fraction)
