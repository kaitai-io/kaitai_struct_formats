meta:
  id: nulib_xmd
  application: Games with Namco NU library
  file-extension: bin
  title: XMD Archive
  endian: le
  license: MIT
seq:
  - id: header
    type: xmd_header
  - id: positions
    type: u4
    repeat: expr
    repeat-expr: header.aligned_count
  - id: lengths
    type: u4
    repeat: expr
    repeat-expr: header.aligned_count
  - id: item_ids
    type: u4
    repeat: expr
    repeat-expr: header.aligned_count

types:
  xmd_header:
    seq:
      - id: signature
        contents: "XMD\0001\0"
      - id: layout
        type: u4
        enum: list_counts
        #valid:
        #  any-of:
        #    - list_counts::pos_len_id
      - id: count
        type: u4
    instances:
      aligned_count:
        value: count + ((4 - count) % 4)

enums:
  list_counts:
    3: pos_len_id
