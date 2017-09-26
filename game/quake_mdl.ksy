meta:
  id: quake_mdl
  endian: le
  title: Quake 1 (idtech2) model format (MDL version 6)
  application: Quake 1 (idtech2)
  file-extension: mdl
  license: CC0-1.0
  ks-version: 0.7
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
