meta:
  id: nt_mdt_256
  endian: le
  encoding: UTF-16
  title: NT-MDT 256 byte palettes
  application:
    - Nova
    - Image Analysis
    - NanoEducator
  file-extension: "256"
  license: Unlicense
doc: It is an old format for a color scheme for visualising SPM scans.
seq:
  - id: color_tables
    type: color_table
    repeat: eos
types:
  color_table:
    seq:
      - id: colors
        type: color
        repeat: expr
        repeat-expr: 85
      - size: 1
  color:
    seq:
      - id: blue
        type: u1
      - id: green
        type: u1
      - id: red
        type: u1
