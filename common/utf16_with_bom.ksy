meta:
  id: utf16_with_bom
  title: UTF-16 string with BOM
  xref:
    wikidata: Q1018724
  license: CC0-1.0
  ks-version: 0.9
doc: |
  A simple wrapper which allows to read a UTF-16 encoded string that starts
  with a byte order mark (BOM). The BOM indicates the endianness of the UTF-16
  encoding, which can be either big-endian (BE) or little-endian (LE).

  Use:

  * `value` to get the string value with BOM stripped, regardless of endianness.
  * `is_be` and `is_le` to check the endianness indicated by the BOM.
  * `bom` to check the raw byte order mark.
doc-ref: |
  - https://en.wikipedia.org/wiki/Byte_order_mark
seq:
  - id: bom
    size: 2
    valid:
      any-of:
        - '[0xFE, 0xFF]'
        - '[0xFF, 0xFE]'
    doc: |
      The byte order mark (BOM) is a special marker at the beginning of the
      string that indicates the endianness of the UTF-16 encoding. The
      character U+FEFF is used as the BOM, and its byte representation differs
      based on endianness:

      * For big-endian (BE) UTF-16, it's `[0xFE, 0xFF]`
      * For little-endian (LE) UTF-16, it's `[0xFF, 0xFE]`

      This implementation checks for the presence of a valid BOM and strips it
      from the resulting string value.
  - id: str_be
    size-eos: true
    type: str
    encoding: UTF-16BE
    if: is_be
  - id: str_le
    size-eos: true
    type: str
    encoding: UTF-16LE
    if: is_le
instances:
  is_be:
    value: bom == [0xFE, 0xFF]
    doc: True if the byte order mark indicates big-endian UTF-16 encoding.
  is_le:
    value: bom == [0xFF, 0xFE]
    doc: True if the byte order mark indicates little-endian UTF-16 encoding.
  value:
    value: "is_be ? str_be : str_le"
    doc: The string value with BOM stripped, regardless of endianness.
