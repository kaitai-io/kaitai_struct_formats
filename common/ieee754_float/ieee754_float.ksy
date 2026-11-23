meta:
  id: ieee754_float
  title: IEEE 754 floating-point
  license: Unlicense
  xref:
    iso: 60559:2011
    wikidata: Q1994657
doc: |
  An extremily widespread format of floating-point numbers used in most of hardware implementations of floating-point numbers.
  Unfortunately not all the standardized formats are supported natively in hardware, programming languages and software, especially in old ones. For example Kaitai Struct itself doesn't support anything except `f4` and `f8` natively.
  This is an implementation of these formats purely in Kaitai Struct. It makes no guarantees of precision, correctness, efficiency or anything else. It is just something that is better than nothing.
  This file contains common logic converting integers representing different parts of floating point numbers into a floating point number implemented in your language. Typically it is `f8`.
  In order to use this, parse the parts of your floating point number and create an instance with a `pos` and `type` (at the time of this format creation KS had no support for typed value instances), passing the parsed parts, their bit-sizes and exponent bias as params.
params:
  - id: bias
    type: u2
    doc: Usually (1 << (biased_exponent_bit_size - 1)) - 1, but not always
  - id: fraction_bit_size
    type: u8
  - id: biased_exponent_bit_size
    type: u1
  - id: sign
    type: bool
  - id: biased_exponent
    type: u1
  - id: fraction
    type: u8
instances:
  only_ones_biased_exponent:
    value: (1<<biased_exponent_bit_size) - 1
  biased_exponent_is_special:
    value: biased_exponent == only_ones_biased_exponent
  is_denorm:
    value: biased_exponent == 0
  mantissa:
    value: '(is_denorm ? 0. : 1.) + fraction * 1. / (1 << fraction_bit_size)'
  exponent:
    value: (biased_exponent - bias + (is_denorm?1:0))
  pow:
    value: '(exponent >= 0) ? (1 << exponent) : (1. / (1 << (-exponent)))'
  modulus:
    value: mantissa * pow
  is_inf:
    value: biased_exponent_is_special and fraction == 0
  is_nan:
    value: biased_exponent_is_special and fraction != 0
  value:
    value: '(sign ? -modulus : modulus)'
