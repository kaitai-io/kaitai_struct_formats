meta:
  id: nt_mdt_pal
  file-extension: pal
  endian: be
  encoding: UTF-16
  title: NT-MDT palette format
  application:
    - Nova
    - Image Analysis
    - NanoEducator
  license: Unlicense
  imports:
    - ./nt_mdt_color_table
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
  - id: unkn
    size: 3
types:
  meta:
    seq:
      - id: unkn00
        size: 3
        doc: usually 0s
      - id: color_table_ptr
        type: u4le
      - id: colors_count
        type: u4le
      - id: unkn11
        size: 1
        doc: 'usually 4. Does it mean 4 color components?'
      - id: unkn12
        size: 2
        doc: usually 0s
      - id: title_len
        type: u2
    instances:
      color_table:
        pos: color_table_ptr
        io: _root._io
        type: 'nt_mdt_color_table(colors_count, title_len)'
