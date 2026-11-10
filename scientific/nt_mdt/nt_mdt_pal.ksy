meta:
  id: nt_mdt_pal
  file-extension: pal
  endian: be
  encoding: UTF-16LE
  title: NT-MDT palette format
  application:
    - Nova
    - Image Analysis
    - NanoEducator
  license: Unlicense
doc: It is a color scheme for visualising SPM scans.
seq:
  - id: signature
    contents: "NT-MDT Palette File  1.00!"
  - id: count #?
    type: u4
  - id: meta
    type: meta
    repeat: expr
    repeat-expr: count
  - id: something2
    size: 1
  - id: tables
    type: col_table(_index)
    repeat: expr
    repeat-expr: count
types:
  meta:
    seq:
      - id: unkn00
        size: 3
        doc: usually 0s
      - id: unkn01
        size: 2
      - id: unkn02
        size: 1
      - id: unkn03
        size: 1
        doc: usually 0s
      - id: colors_count
        type: u2le
      - id: unkn10
        size: 2
        doc: usually 0s
      - id: unkn11
        size: 1
        doc: usually 4
      - id: unkn12
        size: 2
        doc: usually 0s
      - id: name_size
        type: u2
  color:
    seq:
      - id: red
        type: u1
      - id: unkn
        type: u1
      - id: blue
        type: u1
      - id: green
        type: u1

  col_table:
    params:
      - id: index
        type: u2
    seq:
      - id: size1
        type: u1
      - id: unkn
        type: u1
      - id: title
        type: str
        size: _root.meta[index].name_size
      - id: unkn1
        type: u2
      - id: colors
        type: color
        repeat: expr
        repeat-expr: _root.meta[index].colors_count-1
