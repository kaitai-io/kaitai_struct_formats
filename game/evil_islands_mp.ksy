meta:
  id: evil_islands_mp
  title: Evil Islands, MP file (map header)
  application: Evil Islands
  file-extension: mp
  license: MIT
  endian: le
doc: Map header
doc-ref: https://github.com/aspadm/EIrepack/wiki/mp
seq:
  - id: magic
    contents: [0x72, 0xF6, 0x4A, 0xCE]
  - id: max_altitude
    type: f4
    doc: Maximal height of terrain
  - id: num_x_chunks
    type: u4
    doc: Number of sectors by x
  - id: num_y_chunks
    type: u4
    doc: Number of sectors by y
  - id: num_textures
    type: u4
    doc: Number of texture files
  - id: texture_size
    type: u4
    doc: Size of texture in pixels by side
  - id: num_tiles
    type: u4
  - id: tile_size
    type: u4
    doc: Size of tile in pixels by side
  - id: num_materials
    type: u2
  - id: num_animated_tiles
    type: u4
  - id: materials
    type: material
    repeat: expr
    repeat-expr: num_materials
  - id: tiles_id
    type: u4
    repeat: expr
    repeat-expr: num_tiles
    enum: tile_type
  - id: animated_tiles
    type: animated_tile
    repeat: expr
    repeat-expr: num_animated_tiles
types:
  material:
    seq:
      - id: type
        type: u4
        enum: terrain_type
      - id: color
        type: rgba
        doc: RGBA diffuse color
      - id: self_illumination
        type: f4
        doc: Self illumination strength
      - id: wave_multiplier
        type: f4
      - id: warp_speed
        type: f4
      - id: reserved
        size: 12
    types:
      rgba:
        seq:
          - id: r
            type: f4
          - id: g
            type: f4
          - id: b
            type: f4
          - id: a
            type: f4
    enums:
      terrain_type:
        0: base
        1: water_notexture
        2: grass
        3: water
  animated_tile:
    seq:
      - id: start_tile
        type: u2
      - id: num_tiles
        type: u2
enums:
  tile_type:
    0: grass
    1: ground
    2: stone
    3: sand
    4: rock
    5: field
    6: water
    7: road
    8: empty
    9: snow
    10: ice
    11: drygrass
    12: snowballs
    13: lava
    14: swamp
    15: highrock
