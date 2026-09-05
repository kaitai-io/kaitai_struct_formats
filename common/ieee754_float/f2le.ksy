meta:
  id: f2le
  title: IEEE 754 Half-precision floating-point
  license: Unlicense
  endian: be
  xref:
    iso: 60559:2011
    wikidata: Q1994657
  imports:
    - ./ieee754_float
doc: See the doc for `ieee754_float`. ffffffff seeeeeff
seq:
  - id: fraction_lo
    type: u1

  - id: sign
    type: b1
  - id: biased_exponent
    type: b5
  - id: fraction_hi
    type: b2

instances:
  fraction:
    value: fraction_hi<<8 | fraction_lo
  value:
    pos: 0
    type: ieee754_float(((1 << (5 - 1)) - 1), 10, 5, sign, biased_exponent, fraction)
