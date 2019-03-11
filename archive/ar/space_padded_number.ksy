meta:
  id: space_padded_number
  title: Fixed-size ASCII number field
  license: CC0-1.0
  encoding: ASCII
doc: A number that is stored as ASCII text in a fixed-size field, padded using spaces.
params:
  - id: size
    type: u1
    doc: The (maximum) size of the field, in bytes.
  - id: base
    type: u1
    doc: The base of the number stored in the field (usually 10).
seq:
  - id: text
    size: size
    type: str
    terminator: 0x20
    pad-right: 0x20
    doc: The number in text form, right-padded with spaces.
instances:
  value:
    value: text.to_i(base)
    if: text != ""
    doc: The number, parsed as an integer.
