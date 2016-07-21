meta:
  id: ftl_dat
  endian: le
  application: Faster Than Light
seq:
  - id: smth1
    type: u4
  - id: file
    type: file
    repeat: expr
    repeat-expr: smth1
types:
  file:
    seq:
      - id: meta_ofs
        type: u4
    instances:
      meta:
        pos: meta_ofs
        type: meta
  meta:
    seq:
      - id: file_size
        type: u4
      - id: filename_size
        type: u4
      - id: filename
        type: str
        size: filename_size
        encoding: UTF-8
      - id: body
        size: file_size
