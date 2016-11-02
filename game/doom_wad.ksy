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
        type:
          switch-on: name
          cases:
            '"THINGS\0\0"': things
            '"LINEDEFS"': linedefs
            '"BLOCKMAP"': blockmap
  things:
    seq:
      - id: entries
        type: thing
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
  linedefs:
    seq:
      - id: entries
        type: linedef
        repeat: eos
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
  blockmap:
    seq:
      - id: origin_x
        type: s2
        doc: Grid origin, X coord
      - id: origin_y
        type: s2
        doc: Grid origin, Y coord
      - id: num_cols
        type: s2
        doc: Number of columns
      - id: num_rows
        type: s2
        doc: Number of rows
      - id: blocklists
        type: blocklist
        repeat: expr
        repeat-expr: num_cols * num_rows
        doc: Offsets to blocks
    types:
      blocklist:
        seq:
          - id: offset
            type: u2
        instances:
          linedefs:
            pos: offset * 2
            type: s2
            repeat: until
            repeat-until: _ == -1
instances:
  index:
    pos: index_offset
    type: index_entry
    repeat: expr
    repeat-expr: qty_index_entries
