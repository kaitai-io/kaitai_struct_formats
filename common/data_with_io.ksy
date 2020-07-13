meta:
  id: data_with_io
  title: Byte array with an `_io` member
  license: MIT
  ks-version: "0.8"
doc: |
  Helper type to work around Kaitai Struct not providing an `_io` member for plain byte arrays.
seq:
  - id: data
    size-eos: true
    doc: The actual data.
