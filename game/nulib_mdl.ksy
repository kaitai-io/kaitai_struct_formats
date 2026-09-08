meta:
  id: nulib_mdl
  file-extension: mdl
  application: Games with Namco NU library
  title: Namco 3D Model Archive
  license: MIT
  imports:
    - nulib_xmd
    - nulib_nud
seq:
  - id: xmd
    type: nulib_xmd
instances:
  models:
    type: model(_index)
    io: _root._io
    repeat: expr
    repeat-expr: xmd.header.count

types:
  model:
    params:
      - id: i
        type: s4
    instances:
      id:
        value: _root.xmd.item_ids[i]
      len_nud:
        value: _root.xmd.lengths[i]
      nud:
        type: nulib_nud
        pos: _root.xmd.positions[i]
        size: len_nud
