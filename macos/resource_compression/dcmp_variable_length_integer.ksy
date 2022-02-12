meta:
  id: dcmp_variable_length_integer
  title: Variable-length integer used in Apple `'dcmp' (0)` and `'dcmp' (1)` compressed resource formats
  application: Mac OS
  license: MIT
  ks-version: "0.8"
  endian: be
doc: |
  A variable-length integer,
  in the format used by the 0xfe chunks in the `'dcmp' (0)` and `'dcmp' (1)` resource compression formats.
  See the dcmp_0 and dcmp_1 specs for more information about these compression formats.

  This variable-length integer format can store an integer `x` in any of the following ways:

  * In a single byte,
    if `0 <= x <= 0x7f`
    (7-bit unsigned integer)
  * In 2 bytes,
    if `-0x4000 <= x <= 0x3eff`
    (15-bit signed integer with the highest `0x100` values unavailable)
  * In 5 bytes, if `-0x80000000 <= x <= 0x7fffffff`
    (32-bit signed integer)

  In practice,
  values are always stored in the smallest possible format,
  but technically any of the larger formats could be used as well.
doc-ref: 'https://github.com/dgelessus/python-rsrcfork/blob/f891a6e/src/rsrcfork/compress/common.py'
seq:
  - id: first
    type: u1
    doc: |
      The first byte of the variable-length integer.
      This determines which storage format is used.

      * For the 1-byte format,
        this encodes the entire value of the value.
      * For the 2-byte format,
        this encodes the high 7 bits of the value,
        minus `0xc0`.
        The highest bit of the value,
        i. e. the second-highest bit of this field,
        is the sign bit.
      * For the 5-byte format,
        this is always `0xff`.
  - id: more
    type:
      switch-on: first
      cases:
        0xff: s4
        _: u1
    if: first >= 0x80
    doc: |
      The remaining bytes of the variable-length integer.

      * For the 1-byte format,
        this is not present.
      * For the 2-byte format,
        this encodes the low 8 bits of the value.
      * For the 5-byte format,
        this encodes the entire value.
instances:
  value:
    value: |
      first == 0xff ? more
      : first >= 0x80 ? (first << 8 | more) - 0xc000
      : first
    doc: |
      The decoded value of the variable-length integer.
