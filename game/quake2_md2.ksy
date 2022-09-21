meta:
  id: quake2_md2
  title: Quake II player model (version 8)
  application: Quake II
  file-extension: md2
  license: CC0-1.0
  endian: le
doc: |
  The MD2 format is used for 3D animated models in id Sofware's Quake II.

  A model consists of named `frames`, each with the same number of `vertices`
  (`vertices_per_frame`). Each such vertex has a `position` in model space,
  and a `normal_index` which you must look up to get its normal. Each vertex
  has the same topological "meaning" across frames, in terms of triangle and
  texture info; it just varies in position and normal for animation purposes.

  How the vertices form triangles is defined via disjoint `triangles` or via
  `gl_cmds` (which allows strip and fan topology.) Each triangle contains three
  `vertex_indices` into frame vertices, and three `tex_point_indices` into
  global `tex_coords`. Each texture point has pixel coords `u_px` and `v_px`
  ranging from 0 to `skin_{width,height}_px` respectively, along with
  `{u,v}_normalized` ranging from 0 to 1 for your convenience.

  A GL command has a `primitive` type (`TRIANGLE_FAN` or `TRIANGLE_STRIP`) along
  with some `vertices`. Each GL vertex contains `tex_coords_normalized` from 0
  to 1, and a `vertex_index` into frame vertices.

  A model may also contain `skins`, which are just file paths to PCX images.
  However, this is empty for many models, in which case it is up to the client
  (e.g. Q2PRO) to offer skins some other way (e.g. by similar filename in the
  current directory.)

  There are 198 `frames` in total, partitioned into a fixed set of ranges used
  for different animations. Each frame has a standard `name` for humans, but the
  client just uses their index and the name can be arbitrary. The frames are:

  |   INDEX  |    NAME | SUFFIX | NOTES          |
  |:--------:|--------:|:-------|:---------------|
  |    0-39  |   stand | 01-40  | Idle animation |
  |   40-45  |     run | 1-6    | Full run cycle |
  |   46-53  |  attack | 1-8    | Shoot, reload; some weapons just repeat 1st few frames |
  |   54-57  |   pain1 | 01-04  | |
  |   58-61  |   pain2 | 01-04  | |
  |   62-65  |   pain3 | 01-04  | |
  |   66-71  |    jump | 1-6    | Starts at height and lands on feet |
  |   72-83  |    flip | 01-12  | Flipoff, i.e. middle finger |
  |   84-94  |  salute | 01-11  | |
  |   95-111 |   taunt | 01-17  | |
  |  112-122 |    wave | 01-11  | Q2Pro plays this backwards for a handgrenade toss |
  |  123-134 |   point | 01-12  | |
  |  135-153 |  crstnd | 01-19  | Idle while crouching |
  |  154-159 |  crwalk | 1-6    | |
  |  160-168 | crattak | 1-9    | |
  |  169-172 |  crpain | 1-4    | |
  |  173-177 | crdeath | 1-5    | |
  |  178-183 |  death1 | 01-06  | |
  |  184-189 |  death2 | 01-06  | |
  |  190-197 |  death3 | 01-08  | |

  The above are filled in for player models; for the separate weapon models,
  the final frame is 173 "g_view" (unknown purpose) since weapons aren't shown
  during death animations. `a_grenades.md2`, the handgrenade weapon model, is
  the same except that the `wave` frames are blank (according to the default
  female model files.) This is likely due to its dual use as a grenade throw
  animation where this model must leave the player's model.
doc-ref:
  - https://icculus.org/~phaethon/q3a/formats/md2-schoenblum.html
  - http://tfc.duke.free.fr/coding/md2-specs-en.html
  - http://tastyspleen.net/~panjoo/downloads/quake2_model_frames.html
  - http://wiki.polycount.com/wiki/OldSiteResourcesQuake2FramesList
seq:
  - id: magic
    contents: IDP2
  - id: version
    type: u4
    doc: Always 8, apparently.
  - id: skin_width_px
    type: u4
  - id: skin_height_px
    type: u4
  - id: bytes_per_frame
    type: u4
  - id: num_skins
    type: u4
  - id: vertices_per_frame
    type: u4
  - id: num_tex_coords
    type: u4
  - id: num_triangles
    type: u4
  - id: num_gl_cmds
    type: u4
  - id: num_frames
    type: u4
  - id: ofs_skins
    type: u4
  - id: ofs_tex_coords
    type: u4
  - id: ofs_triangles
    type: u4
  - id: ofs_frames
    type: u4
  - id: ofs_gl_cmds
    type: u4
  - id: ofs_eof
    type: u4
instances:
  skins:
    pos: ofs_skins
    size: 64
    type: strz
    encoding: ascii
    repeat: expr
    repeat-expr: num_skins
  tex_coords:
    pos: ofs_tex_coords
    type: tex_point
    repeat: expr
    repeat-expr: num_tex_coords
  triangles:
    pos: ofs_triangles
    type: triangle
    repeat: expr
    repeat-expr: num_triangles
  frames:
    pos: ofs_frames
    type: frame
    repeat: expr
    repeat-expr: num_frames
  gl_cmds:
    pos: ofs_gl_cmds
    type: gl_cmd
    repeat: until
    repeat-until: _.cmd_num_vertices == 0
types:
  tex_point:
    seq:
      - id: u_px
        type: u2
      - id: v_px
        type: u2
    instances:
      u_normalized:
        value: u_px.as<f4> / _root.skin_width_px
      v_normalized:
        value: v_px.as<f4> / _root.skin_height_px
  triangle:
    seq:
      - id: vertex_indices
        type: u2
        repeat: expr
        repeat-expr: 3
      - id: tex_point_indices
        type: u2
        repeat: expr
        repeat-expr: 3
  vec3f:
    seq:
      - id: x
        type: f4
      - id: y
        type: f4
      - id: z
        type: f4
  compressed_vec:
    seq:
      - id: x_compressed
        type: u1
      - id: y_compressed
        type: u1
      - id: z_compressed
        type: u1
    instances:
      x:
        value: x_compressed * _parent._parent.scale.x + _parent._parent.translate.x
      y:
        value: y_compressed * _parent._parent.scale.y + _parent._parent.translate.y
      z:
        value: z_compressed * _parent._parent.scale.z + _parent._parent.translate.z
  vertex:
    seq:
      - id: position
        type: compressed_vec
      - id: normal_index
        type: u1
        doc: `normal = bytedirs[normal_index]`
        doc-ref: |
          https://github.com/skullernet/q2pro/blob/master/src/common/math.c#L80
          from Quake anorms.h
  frame:
    seq:
      - id: scale
        type: vec3f
      - id: translate
        type: vec3f
      - id: name
        size: 16
        type: strz
        encoding: ascii
      - id: vertices
        type: vertex
        repeat: expr
        repeat-expr: _root.vertices_per_frame
  gl_cmd:
    seq:
      - id: cmd_num_vertices
        type: s4
      - id: vertices
        type: gl_vertex
        repeat: expr
        repeat-expr: num_vertices
    instances:
      num_vertices:
        value: 'cmd_num_vertices < 0 ? -cmd_num_vertices : cmd_num_vertices'
      primitive:
        value: 'cmd_num_vertices > 0 ? gl_primitive::triangle_strip : gl_primitive::triangle_fan'
  gl_vertex:
    seq:
      - id: tex_coords_normalized
        type: f4
        repeat: expr
        repeat-expr: 2
      - id: vertex_index
        type: u4
enums:
  gl_primitive:
    0: triangle_strip
    1: triangle_fan
  anim_start_index:
    0: stand
    40: run
    46: attack
    54: pain1
    58: pain2
    62: pain3
    66: jump
    72: flip
    84: salute
    95: taunt
    112: wave
    123: point
    135: crstnd
    154: crwalk
    160: crattak
    169: crpain
    173: crdeath
    178: death1
    184: death2
    190: death3
