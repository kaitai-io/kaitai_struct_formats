meta:
  id: nulib_tex
  file-extension: tex
  application: Games with Namco NU library
  title: Namco Texture Archive
  license: MIT
  imports:
    - nulib_xmd
    - nulib_nut
seq:
  - id: xmd
    type: nulib_xmd
instances:
  textures:
    type: texture(_index)
    io: _root._io
    repeat: expr
    repeat-expr: xmd.header.count

types:
  texture:
    params:
      - id: i
        type: s4
    instances:
      id:
        value: _root.xmd.item_ids[i]
      len_nut:
        value: _root.xmd.lengths[i]
      nut:
        type: nulib_nut
        pos: _root.xmd.positions[i]
        size: len_nut
