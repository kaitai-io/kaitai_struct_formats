meta:
  id: bcd
  title: BCD (Binary Coded Decimals)
  xref:
    justsolve: Binary-coded_decimal
    wikidata: Q276582
  license: CC0-1.0
  ks-version: 0.8
doc: |
  BCD (Binary Coded Decimals) is a common way to encode integer
  numbers in a way that makes human-readable output somewhat
  simpler. In this encoding scheme, every decimal digit is encoded as
  either a single byte (8 bits), or a nibble (half of a byte, 4
  bits). This obviously wastes a lot of bits, but it makes translation
  into human-readable string much easier than traditional
  binary-to-decimal conversion process, which includes lots of
  divisions by 10.

  For example, encoding integer 31337 in 8-digit, 8 bits per digit,
  big endian order of digits BCD format yields

  ```
  00 00 00 03 01 03 03 07
  ```

  Encoding the same integer as 8-digit, 4 bits per digit, little
  endian order BCD format would yield:

  ```
  73 31 30 00
  ```

  Using this type of encoding in Kaitai Struct is pretty
  straightforward: one calls for this type, specifying desired
  encoding parameters, and gets result using either `as_int` or
  `as_str` attributes.
params:
  - id: num_digits
    type: u1
    doc: Number of digits in this BCD representation. Only values from 1 to 8 inclusive are supported.
  - id: bits_per_digit
    type: u1
    doc: Number of bits per digit. Only values of 4 and 8 are supported.
  - id: is_le
    type: bool
    doc: Endianness used by this BCD representation. True means little-endian, false is for big-endian.
seq:
  - id: digits
    type:
      switch-on: bits_per_digit
      cases:
        4: b4
        8: u1
    repeat: expr
    repeat-expr: num_digits
instances:
  as_int:
    value: 'is_le ? as_int_le : as_int_be'
    doc: Value of this BCD number as integer. Endianness would be selected based on `is_le` parameter given.
  as_int_le:
    value: >
      digits[0] +
      (num_digits < 2 ? 0 :
       (digits[1] * 10 +
        (num_digits < 3 ? 0 :
         (digits[2] * 100 +
          (num_digits < 4 ? 0 :
           (digits[3] * 1000 +
            (num_digits < 5 ? 0 :
             (digits[4] * 10000 +
              (num_digits < 6 ? 0 :
               (digits[5] * 100000 +
                (num_digits < 7 ? 0 :
                 (digits[6] * 1000000 +
                  (num_digits < 8 ? 0 :
                   (digits[7] * 10000000)
                  )
                 )
                )
               )
              )
             )
            )
           )
          )
         )
        )
       )
      )
    doc: Value of this BCD number as integer (treating digit order as little-endian).
  last_idx:
    value: num_digits - 1
    doc: Index of last digit (0-based).
  as_int_be:
    value: >
      digits[last_idx] +
      (num_digits < 2 ? 0 :
       (digits[last_idx - 1] * 10 +
        (num_digits < 3 ? 0 :
         (digits[last_idx - 2] * 100 +
          (num_digits < 4 ? 0 :
           (digits[last_idx - 3] * 1000 +
            (num_digits < 5 ? 0 :
             (digits[last_idx - 4] * 10000 +
              (num_digits < 6 ? 0 :
               (digits[last_idx - 5] * 100000 +
                (num_digits < 7 ? 0 :
                 (digits[last_idx - 6] * 1000000 +
                  (num_digits < 8 ? 0 :
                   (digits[last_idx - 7] * 10000000)
                  )
                 )
                )
               )
              )
             )
            )
           )
          )
         )
        )
       )
      )
    doc: Value of this BCD number as integer (treating digit order as big-endian).
