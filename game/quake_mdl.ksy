meta:
  id: quake_mdl
  title: Quake 1 (idtech2) model format (MDL version 6)
  application: Quake 1 (idtech2)
  file-extension: mdl
  tags:
    - 3d
    - game
  license: CC0-1.0
  ks-version: '0.10'
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
    switched to depict various levels of damage to the
    monsters. Bitmaps are 8-bit-per-pixel, indexed in global Quake
    palette, subject to lighting and gamma adjustment when rendering
    in the game using colormap technique.
  * "Texture coordinates" — UV coordinates, mapping 3D vertices to
    skin coordinates.
  * "Triangles" — triangular faces connecting 3D vertices.
  * "Frames" — locations of vertices in 3D space; can include more
    than one frame, thus allowing representation of different frames
    for animation purposes.

  Originally, 3D geometry for models for Quake was designed in [Alias
  PowerAnimator](https://en.wikipedia.org/wiki/PowerAnimator),
  precursor of modern day Autodesk Maya and Autodesk Alias. Therefore,
  3D-related part of Quake model format followed closely Alias TRI
  format, and Quake development utilities included a converter from Alias
  TRI (`modelgen`).

  Skins (textures) where prepared as LBM bitmaps with the help from
  `texmap` utility in the same development utilities toolkit.
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
    -orig-id: vec3_t
    doc: |
      Basic 3D vector (x, y, z) using single-precision floating point
      coordnates. Can be used to specify a point in 3D space,
      direction, scaling factor, etc.
    seq:
      - id: x
        type: f4
      - id: y
        type: f4
      - id: z
        type: f4
  mdl_header:
    -orig-id: mdl_t
    doc-ref:
      - 'https://github.com/id-Software/Quake/blob/0023db327bc1db00068284b70e1db45857aeee35/WinQuake/modelgen.h#L59-L75'
      - 'https://www.gamers.org/dEngine/quake/spec/quake-spec34/qkspec_5.htm#MD0'
    seq:
      - id: ident
        contents: 'IDPO'
        doc: |
          Magic signature bytes that every Quake model must
          have. "IDPO" is short for "IDPOLYHEADER".
        doc-ref: 'https://github.com/id-Software/Quake/blob/0023db327bc1db00068284b70e1db45857aeee35/WinQuake/modelgen.h#L132-L133'
      - id: version
        type: s4
        valid:
          eq: 6
      - id: scale
        type: vec3
        doc: |
          Global scaling factors in 3 dimensions for whole model. When
          represented in 3D world, this model local coordinates will
          be multiplied by these factors.
      - id: origin
        type: vec3
      - id: radius
        type: f4
      - id: eye_position
        type: vec3
      - id: num_skins
        type: s4
        doc: |
          Number of skins (=texture bitmaps) included in this model.
      - id: skin_width
        type: s4
        doc: |
          Width (U coordinate max) of every skin (=texture) in pixels.
      - id: skin_height
        type: s4
        doc: |
          Height (V coordinate max) of every skin (=texture) in
          pixels.
      - id: num_verts
        type: s4
        doc: |
          Number of vertices in this model. Note that this is constant
          for all the animation frames and all textures.
      - id: num_tris
        type: s4
        doc: |
          Number of triangles (=triangular faces) in this model.
      - id: num_frames
        type: s4
        doc: |
          Number of animation frames included in this model.
      - id: synctype
        type: s4
      - id: flags
        type: s4
      - id: size
        type: f4
    instances:
      skin_size:
        value: skin_width * skin_height
        doc: |
          Skin size in pixels.
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
    -orig-id: stvert_t
    doc-ref:
      - 'https://github.com/id-Software/Quake/blob/0023db327bc1db00068284b70e1db45857aeee35/WinQuake/modelgen.h#L79-L83'
      - 'https://www.gamers.org/dEngine/quake/spec/quake-spec34/qkspec_5.htm#MD2'
    seq:
      - id: on_seam
        type: s4
      - id: s
        type: s4
      - id: t
        type: s4
  mdl_triangle:
    -orig-id: dtriangle_t
    doc: |
      Represents a triangular face, connecting 3 vertices, referenced
      by their indexes.
    doc-ref:
      - 'https://github.com/id-Software/Quake/blob/0023db327bc1db00068284b70e1db45857aeee35/WinQuake/modelgen.h#L85-L88'
      - 'https://www.gamers.org/dEngine/quake/spec/quake-spec34/qkspec_5.htm#MD3'
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
