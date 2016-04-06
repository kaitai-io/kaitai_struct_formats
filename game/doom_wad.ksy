meta:
  id: doom_wad
  endian: le
  application: id Tech 1
seq:
  - id: magic
    type: str
    size: 4
    encoding: ASCII
  - id: qty_index_entries
    type: s4
  - id: index_offset
    type: s4
types:
  index_entry:
    seq:
      - id: offset
        type: s4
      - id: size
        type: s4
      - id: name
        type: str
        size: 8
        encoding: ASCII
    instances:
      contents:
        io: _root._io
        pos: offset
        size: size
        if: name != "THINGS\0\0" and name != "LINEDEFS"
      things_contents:
        io: _root._io
        pos: offset
        size: size
        if: name == "THINGS\0\0"
        type: thing
        repeat: eos
      linedef_contents:
        io: _root._io
        pos: offset
        size: size
        if: name == "LINEDEFS"
        type: linedef
        repeat: eos
  thing:
    seq:
      - id: x
        type: s2
      - id: y
        type: s2
      - id: angle
        type: u2
      - id: type
        type: u2
      - id: flags
        type: u2
  linedef:
    seq:
      - id: vertex_start_idx
        type: u2
      - id: vertex_end_idx
        type: u2
      - id: flags
        type: u2
      - id: line_type
        type: u2
      - id: sector_tag
        type: u2
      - id: sidedef_right_idx
        type: u2
      - id: sidedef_left_idx
        type: u2
instances:
  index:
    pos: index_offset
    type: index_entry
    repeat: expr
    repeat-expr: qty_index_entries
