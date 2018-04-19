meta:
  id: nt_mdt_color_table
  endian: le
  encoding: UTF-16
  title: NT-MDT reusable part of palette
  application:
    - Nova
    - Image Analysis
    - NanoEducator
  license: Unlicense
doc: It is a reusable part of a color scheme for visualising SPM scans.
params:
  - id: colors_count
    type: u4
  - id: title_len
    type: u2
seq:
  - id: title
    type: str
    size: title_len
  - id: colors
    type: color
    repeat: expr
    repeat-expr: colors_count
types:
  color:
    seq:
      - id: blue
        type: u1
      - id: green
        type: u1
      - id: red
        type: u1
      - id: unkn
        type: u1
