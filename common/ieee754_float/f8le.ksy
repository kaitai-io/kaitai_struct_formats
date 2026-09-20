meta:
  id: f8le
  title: IEEE 754 Double-precision floating-point
  license: Unlicense
  endian: be
  xref:
    iso: 60559:2011
    wikidata: Q1243369
  imports:
    - ./ieee754_float
doc: |
  YOU LIKELY DON'T NEED THIS. `f8` is implemented in all modern PC CPUs and programming languages natively. It is here mainly for testing purposes.
  See the doc for `float` on the drawbacks of this impl.
  ffffffff ffffffff ffffffff ffffffff ffffffff ffffffff eeeeffff seeeeeee

seq:
  - id: fraction_lo
    type: u4le
  - id: fraction_mid
    type: u2le
  - id: biased_exponent_lo
    type: b4
  - id: fraction_hi
    type: b4
  - id: sign
    type: b1
  - id: biased_exponent_hi
    type: b7

instances:
  fraction:
    value: (fraction_hi << 16 | fraction_mid) << 32 | fraction_lo
  biased_exponent:
    value: biased_exponent_hi << 4 | biased_exponent_lo
  value:
    pos: 0
    type: ieee754_float((1 << (11 - 1)) - 1, 52, 11, sign, biased_exponent, fraction)
