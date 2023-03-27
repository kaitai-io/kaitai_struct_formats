meta:
  id: respack
  title: respack
  license: CC0-1.0
  encoding: UTF-8
  endian: le
doc: |
  Resources file found in CPB firmware archives, mostly used on older CoolPad
  phones and/or tablets. The only observed files are called "ResPack.cfg".
seq:
  - id: header
    type: header
  - id: json
    size: header.len_json
    type: strz
types:
  header:
    seq:
      - id: magic
        contents: "RS"
      - id: unknown
        size: 8
      - id: len_json
        type: u4
      - id: md5
        size: 32
        type: str
        doc: MD5 of data that follows the header
