meta:
  id: utf8_string
  title: UTF-8-encoded string
  file-extension: txt
  xref:
    wikidata: Q193537
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
  rather just use `type: str` with `encoding: utf-8`. That will use
  native string implementations, which are most likely more efficient
  and will give you native language strings, rather than an array of
  individual codepoints.  This format definition is provided mostly
  for educational / research purposes.
seq:
  - id: codepoints
    type: utf8_codepoint(_io.pos)
    repeat: eos
types:
  utf8_codepoint:
    -webide-representation: 'U+{value_as_int:hex}'
    params:
      - id: ofs
        type: u8
    seq:
      - id: bytes
        size: len_bytes
    instances:
      byte0:
        pos: ofs
        type: u1
      len_bytes:
        value: |
          (byte0 & 0b1000_0000 == 0) ? 1 :
          (byte0 & 0b1110_0000 == 0b1100_0000) ? 2 :
          (byte0 & 0b1111_0000 == 0b1110_0000) ? 3 :
          (byte0 & 0b1111_1000 == 0b1111_0000) ? 4 :
          -1
      raw0:
        value: |
          bytes[0] & (
            len_bytes == 1 ? 0b0111_1111 :
            len_bytes == 2 ? 0b0001_1111 :
            len_bytes == 3 ? 0b0000_1111 :
            len_bytes == 4 ? 0b0000_0111 :
            0
          )
      raw1:
        value: 'bytes[1] & 0b0011_1111'
        if: len_bytes >= 2
      raw2:
        value: 'bytes[2] & 0b0011_1111'
        if: len_bytes >= 3
      raw3:
        value: 'bytes[3] & 0b0011_1111'
        if: len_bytes >= 4
      value_as_int:
        value: >
          len_bytes == 1 ? raw0 :
          len_bytes == 2 ? ((raw0 << 6) | raw1) :
          len_bytes == 3 ? ((raw0 << 12) | (raw1 << 6) | raw2) :
          len_bytes == 4 ? ((raw0 << 18) | (raw1 << 12) | (raw2 << 6) | raw3) :
          -1
