meta:
  id: f10le
  title: IEEE 754 Extended-precision floating-point
  license: Unlicense
  endian: be
  xref:
    iso: "60559:2011"
    wikidata: Q5421900
  imports:
    - ./ieee754_float
doc: |
  see the doc for `ieee754_float`.
  ffffffff ffffffff ffffffff ffffffff ffffffff ffffffff ffffffff ifffffff eeeeeeee seeeeeee
seq:
  - id: frac_lo_lo
    type: u4le
  - id: frac_lo
    type: u2le
  - id: frac_mid
    type: u1
  - id: integer
    type: b1
  - id: frac_hi
    type: b7
  - id: biased_exponent_lo
    type: u1
  - id: sign
    type: b1
  - id: biased_exponent_hi
    type: b7
instances:
  fraction:
    value: ((frac_hi << 8 | frac_mid) << 16 | frac_lo) << 32 | frac_lo_lo
  biased_exponent:
    value: biased_exponent_hi << 8 | biased_exponent_lo
  value:
    pos: 0
    type: float(16383, 63, 15, sign, biased_exponent, fraction)
