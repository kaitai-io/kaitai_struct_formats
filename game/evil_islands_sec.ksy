meta:
  id: evil_islands_sec
  title: Evil Islands, SEC file (map sector)
  application: Evil Islands
  file-extension: sec
  license: MIT
  endian: le
doc: Map sector
doc-ref: https://github.com/aspadm/EIrepack/wiki/sec
seq:
  - id: magic
    contents: [0x74, 0xF7, 0x4B, 0xCF]
  - id: have_liquids
    type: u1
    doc: Liquids layer indicator
  - id: land_vertexes
    type: vertex
    doc: Vertex array 33x33 (terrain layer)
    repeat: expr
    repeat-expr: 1089
  - id: liquid_vertexes
    type: vertex
    doc: Vertex array 33x33 (liquids layer)
    if: have_liquids != 0
    repeat: expr
    repeat-expr: 1089
  - id: land_tiles
    type: tile
    doc: Tile array 16x16 (terrain layer)
    repeat: expr
    repeat-expr: 256
  - id: liquid_tiles
    type: tile
    doc: Tile array 16x16 (liquids layer)
    if: have_liquids == 3
    repeat: expr
    repeat-expr: 256
  - id: liquid_material
    type: s2
    doc: Index of material from MP file
    if: have_liquids == 3
    repeat: expr
    repeat-expr: 256
types:
  vertex:
    doc: Vertex data
    seq:
      - id: raw_x_shift
        type: s1
        doc: Raw vertex shift by x axis
      - id: raw_y_shift
        type: s1
        doc: Raw vertex shift by y axis
      - id: raw_altitude
        type: u2
        doc: Raw height (z position)
      - id: normal
        type: normal
        doc: Packed normal
    instances:
      x_shift:
        value: raw_x_shift / 254.0
      y_shift:
        value: raw_y_shift / 254.0
      altitude:
        value: raw_altitude / 65545.0
        doc: Normalized altitude in [0, 1]. Real z = altitude * max_altitude
  normal:
    doc: Normal (3d vector)
    seq:
      - id: packed
        type: u4
        doc: Bit-packed normal vector
    instances:
      x:
        value: (((packed >> 11) & 0x7FF) - 1000.0) / 1000.0
      y:
        value: ((packed & 0x7FF) - 1000.0) / 1000.0
      z:
        value: (packed >> 22) / 1000.0
  tile:
    doc: Tile parameters
    seq:
      - id: packed
        type: u2
        doc: Bit-packed tile information
    instances:
      index:
        doc: Tile index in texture atlas
        value: packed & 63
      texture:
        doc: Index of texture atlas
        value: (packed >> 6) & 255
      rotation:
        doc: Tile rotation in angles
        value: 90.0 * ((packed >> 14) & 3)
