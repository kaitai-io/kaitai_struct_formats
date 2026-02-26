meta:
  id: lzham
  application: LZHAM
  license: Unlicense  # Also https://github.com/richgel999/lzham_codec/blob/master/LICENSE
  endian: le
doc: |
  LZHAM is an archiver that tries to implement high and slow compression and fast decompression
doc-ref: https://github.com/richgel999/lzham_codec
seq:
  - id: header
    type: header

types:
  header:
    doc-ref: https://github.com/richgel999/lzham_codec/blob/b33fd27f12a8b414ac83743b9430022054f0b291/lzhamtest/lzhamtest.cpp#L376L387
    seq:
      - id: signature
        contents: "LZH0"
      - id: dict_size_log
        type: u1
      - id: src_file_size
        type: u8
