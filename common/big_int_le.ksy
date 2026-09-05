meta:
  id: big_int_le
  license: Unlicense
  title: Big int type, little endian
  endian: le
doc: Works only for the languages where ints are big ints
seq:
  - id: raw
    size-eos: true
instances:
  reduction:
    pos: 0
    type: iteration(_index)
    repeat: expr
    repeat-expr: raw.length
  value:
    value: reduction[raw.length - 1].res
types:
  iteration:
    params:
      - id: idx
        type: u1
    instances:
      prev:
        value: "idx == 0 ? 0 : (_parent.reduction[idx - 1].as<iteration>.res).as<u1>"
      res:
        value: prev + (_parent.raw[idx] << (idx * 8))
