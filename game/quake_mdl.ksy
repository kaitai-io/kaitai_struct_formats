meta:
  id: quake_mdl
  title: Quake 1 (idtech2) model format (MDL version 6)
  application: Quake 1 (idtech2)
  file-extension: mdl
  tags:
    - 3d
    - game
  license: CC0-1.0
  ks-version: 0.7
  endian: le
doc: |
  Quake 1 model format is used to store 3D models completely with
  textures and animations used in the game. Quake 1 engine
  (retroactively named "idtech2") is a popular 3D engine first used
  for Quake game by id Software in 1996.

  Model is constructed traditionally from vertices in 3D space, faces
  which connect vertices, textures ("skins", i.e. 2D bitmaps) and
  texture UV mapping information. As opposed to more modern,
  bones-based animation formats, Quake model was animated by changing
  locations of all vertices it included in 3D space, frame by frame.

  File format stores:

  * "Skins" — effectively 2D bitmaps which will be used as a
    texture. Every model can have multiple skins — e.g. these can be
    switched to depict various levels of damage to the monsters.
  * "Texture coordinates" — UV coordinates, mapping 3D vertices to
    skin coordinates.
  * "Triangles" — triangular faces connecting 3D vertices.
  * "Frames" — locations of vertices in 3D space; can include more
    than one frame, thus allowing representation of different frames
    for animation purposes.
seq:
  - id: header
    type: mdl_header
  - id: skins
    type: mdl_skin
    repeat: expr
    repeat-expr: header.num_skins
  - id: texture_coordinates
    type: mdl_texcoord
    repeat: expr
    repeat-expr: header.num_verts
  - id: triangles
    type: mdl_triangle
    repeat: expr
    repeat-expr: header.num_tris
  - id: frames
    type: mdl_frame
    repeat: expr
    repeat-expr: header.num_frames
types:
  vec3:
    seq:
      - id: x
        type: f4
      - id: y
        type: f4
      - id: z
        type: f4
  mdl_header:
    seq:
      - id: ident
        contents: 'IDPO'
      - id: version_must_be_6
        contents: [ 0x06, 0x00, 0x00, 0x00 ]
      - id: scale
        type: vec3
      - id: origin
        type: vec3
      - id: radius
        type: f4
      - id: eye_position
        type: vec3
      - id: num_skins
        type: s4
      - id: skin_width
        type: s4
      - id: skin_height
        type: s4
      - id: num_verts
        type: s4
      - id: num_tris
        type: s4
      - id: num_frames
        type: s4
      - id: synctype
        type: s4
      - id: flags
        type: s4
      - id: size
        type: f4
    instances:
      version:
        value: 6
      skin_size:
        value: skin_width * skin_height
  mdl_skin:
    seq:
      - id: group
        type: s4
      - id: single_texture_data
        size: _root.header.skin_size
        if: group == 0
      - id: num_frames
        type: u4
        if: group != 0
      - id: frame_times
        type: f4
        repeat: expr
        repeat-expr: num_frames
        if: group != 0
      - id: group_texture_data
        size: _root.header.skin_size
        repeat: expr
        repeat-expr: num_frames
        if: group != 0
  mdl_texcoord:
    seq:
      - id: on_seam
        type: s4
      - id: s
        type: s4
      - id: t
        type: s4
  mdl_triangle:
    seq:
      - id: faces_front
        type: s4
      - id: vertices
        type: s4
        repeat: expr
        repeat-expr: 3
  mdl_vertex:
    seq:
      - id: values
        type: u1
        repeat: expr
        repeat-expr: 3
      - id: normal_index
        type: u1
  mdl_simple_frame:
    seq:
      - id: bbox_min
        type: mdl_vertex
      - id: bbox_max
        type: mdl_vertex
      - id: name
        type: str
        size: 16
        encoding: ASCII
        terminator: 0x00
        pad-right: 0x00
      - id: vertices
        type: mdl_vertex
        repeat: expr
        repeat-expr: _root.header.num_verts
  mdl_frame:
    seq:
      - id: type
        type: s4
      - id: min
        type: mdl_vertex
        if: type != 0
      - id: max
        type: mdl_vertex
        if: type != 0
      - id: time
        type: f4
        repeat: expr
        repeat-expr: type
        if: type != 0
      - id: frames
        type: mdl_simple_frame
        repeat: expr
        repeat-expr: num_simple_frames
    instances:
      num_simple_frames:
        value: '(type == 0 ? 1 : type)'
