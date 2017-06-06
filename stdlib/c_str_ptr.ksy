meta:
  id: c_str_ptr
  endian: le
  license: Unlicense
seq:
  - id: ptr
    type: u2
instances:
  str:
    pos: ptr
    type: strz
    encoding: ASCII
    if: ptr != 0