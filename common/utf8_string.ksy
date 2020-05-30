meta:
  id: utf8_string
  title: UTF-8-encoded string
  license: CC0-1.0
doc: |
  UTF-8 is a popular character encoding scheme that allows to
  represent strings as sequence of code points defined in Unicode
  standard. Its features are:

  * variable width (i.e. one code point might be represented by 1 to 4
    bytes)
  * backward compatiblity with ASCII
  * basic validity checking (and thus distinguishing from other legacy
    8-bit encodings)
  * maintaining sort order of codepoints if sorted as a byte array

  WARNING: For the vast majority of practical purposes of format
  definitions in Kaitai Struct, you'd likely NOT want to use this and
  rather just use `type: str` with `encoding: utf8`. That will use
  native string implementations, which are most likely more efficient
  and will give you native language strings, rather than an array of
  individual codepoints.  This format definition is provided mostly
  for educational / research purposes.
seq:
  - id: codepoints
    type: utf8_codepoint
    repeat: eos
types:
  utf8_codepoint:
    seq:
      - id: byte1
        type: u1
      - id: byte2
        type: u1
        if: len >= 2
      - id: byte3
        type: u1
        if: len >= 3
      - id: byte4
        type: u1
        if: len >= 4
    instances:
      len:
        value: |
          (byte1 & 0b1000_0000 == 0) ? 1 :
          (byte1 & 0b1110_0000 == 0b1100_0000) ? 2 :
          (byte1 & 0b1111_0000 == 0b1110_0000) ? 3 :
          (byte1 & 0b1111_1000 == 0b1111_0000) ? 4 :
          -1
      raw1:
        value: |
          byte1 & (
            len == 1 ? 0b0111_1111 :
            len == 2 ? 0b0001_1111 :
            len == 3 ? 0b0000_1111 :
            len == 4 ? 0b0000_0111 :
            0
          )
      raw2:
        value: 'byte2 & 0b0011_1111'
        if: len >= 2
      raw3:
        value: 'byte3 & 0b0011_1111'
        if: len >= 3
      raw4:
        value: 'byte4 & 0b0011_1111'
        if: len >= 4
      value_as_int:
        value: >
          len == 1 ? raw1 :
          len == 2 ? ((raw1 << 6) | raw2) :
          len == 3 ? ((raw1 << 12) | (raw2 << 6) | raw3) :
          len == 4 ? ((raw1 << 18) | (raw2 << 12) | (raw3 << 6) | raw4) :
          -1
