meta:
  id: f16le
  title: IEEE 754 Quadruple-precision floating-point
  license: Unlicense
  endian: be
  xref:
    iso: 60559:2011
    wikidata: Q448573
  imports:
    - ./ieee754_float
doc: |
  see the doc for `ieee754_float`.
  64fl 32fm 16fh 8el s7eh
seq:
  - id: frac_lo
    type: u8le
  - id: frac_mid
    type: u4le
  - id: frac_hi
    type: u2le
  - id: biased_exponent_lo
    type: u1
  - id: sign
    type: b1
  - id: biased_exponent_hi
    type: b7
instances:
  fraction:
    value: (frac_hi << 32 | frac_mid) << 64 | frac_lo
  biased_exponent:
    value: biased_exponent_hi << 8 | biased_exponent_lo
  value:
    pos: 0
    type: ieee754_float(262143, 112, 15, sign, biased_exponent, fraction)
