meta:
  id: f32le
  title: IEEE 754 Octuple-precision floating-point
  license: Unlicense
  endian: be
  xref:
    iso: "60559:2011"
    wikidata: Q25109769
  imports:
    - ./ieee754_float
doc: "see the doc for `ieee754_float`."
seq:
  - id: frac_lo_lo
    type: u4le
  - id: frac_lo
    type: u8le
  - id: frac_med_lo
    type: u8le
  - id: frac_med_hi
    type: u8le
  - id: frac_hi
    type: u1
  - id: biased_exponent_lo
    type: b4
  - id: frac_hi_hi
    type: b4
  - id: biased_exponent_me
    type: u1
  - id: sign
    type: b1
  - id: biased_exponent_hi
    type: b7
instances:
  fraction:
    value: "((((frac_hi_hi << 8 | frac_hi) << 64 | frac_med_hi) << 64 | frac_med_lo) << 64 | frac_lo) << 32 | frac_lo_lo"
  biased_exponent:
    value: "( biased_exponent_hi << 8 | biased_exponent_me) << 4 | biased_exponent_lo"
  value:
    pos: 0
    type: float(262143, 236, 19, sign, biased_exponent, fraction)
