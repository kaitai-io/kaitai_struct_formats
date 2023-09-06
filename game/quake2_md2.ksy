meta:
  id: quake2_md2
  title: Quake II player model (version 8)
  application: Quake II
  file-extension: md2
  xref:
    justsolve: MD2
  tags:
    - 3d
    - game
  license: CC0-1.0
  endian: le
doc: |
  The MD2 format is used for 3D animated models in id Sofware's Quake II.

  A model consists of named `frames`, each with the same number of `vertices`
  (`vertices_per_frame`). Each such vertex has a `position` and `normal` in
  model space. Each vertex has the same topological "meaning" across frames, in
  terms of triangle and texture info; it just varies in position and normal for
  animation purposes.

  How the vertices form triangles is defined via disjoint `triangles` or via
  `gl_cmds` (which allows strip and fan topology). Each triangle contains three
  `vertex_indices` into frame vertices, and three `tex_point_indices` into
  global `tex_coords`. Each texture point has pixel coords `s_px` and `t_px`
  ranging from 0 to `skin_{width,height}_px` respectively, along with
  `{s,t}_normalized` ranging from 0 to 1 for your convenience.

  A GL command has a `primitive` type (`TRIANGLE_FAN` or `TRIANGLE_STRIP`) along
  with some `vertices`. Each GL vertex contains `tex_coords_normalized` from 0
  to 1, and a `vertex_index` into frame vertices.

  A model may also contain `skins`, which are just file paths to PCX images.
  However, this is empty for many models, in which case it is up to the client
  (e.g. Q2PRO) to offer skins some other way (e.g. by similar filename in the
  current directory).

  There are 198 `frames` in total, partitioned into a fixed set of ranges used
  for different animations. Each frame has a standard `name` for humans, but the
  client just uses their index and the name can be arbitrary. The name, start
  frame index and frame count of each animation can be looked up in the arrays
  `anim_names`, `anim_start_indices`, and `anim_num_frames` respectively. This
  information is summarized in the following table:

  ```
  |   INDEX  |    NAME | SUFFIX | NOTES                                                  |
  |:--------:|--------:|:-------|:-------------------------------------------------------|
  |    0-39  |   stand | 01-40  | Idle animation                                         |
  |   40-45  |     run | 1-6    | Full run cycle                                         |
  |   46-53  |  attack | 1-8    | Shoot, reload; some weapons just repeat 1st few frames |
  |   54-57  |   pain1 | 01-04  | Q2Pro also uses this for switching weapons             |
  |   58-61  |   pain2 | 01-04  |                                                        |
  |   62-65  |   pain3 | 01-04  |                                                        |
  |   66-71  |    jump | 1-6    | Starts at height and lands on feet                     |
  |   72-83  |    flip | 01-12  | Flipoff, i.e. middle finger                            |
  |   84-94  |  salute | 01-11  |                                                        |
  |   95-111 |   taunt | 01-17  |                                                        |
  |  112-122 |    wave | 01-11  | Q2Pro plays this backwards for a handgrenade toss      |
  |  123-134 |   point | 01-12  |                                                        |
  |  135-153 |  crstnd | 01-19  | Idle while crouching                                   |
  |  154-159 |  crwalk | 1-6    |                                                        |
  |  160-168 | crattak | 1-9    |                                                        |
  |  169-172 |  crpain | 1-4    |                                                        |
  |  173-177 | crdeath | 1-5    |                                                        |
  |  178-183 |  death1 | 01-06  |                                                        |
  |  184-189 |  death2 | 01-06  |                                                        |
  |  190-197 |  death3 | 01-08  |                                                        |
  ```

  The above are filled in for player models; for the separate weapon models,
  the final frame is 173 "g_view" (unknown purpose) since weapons aren't shown
  during death animations. `a_grenades.md2`, the handgrenade weapon model, is
  the same except that the `wave` frames are blank (according to the default
  female model files). This is likely due to its dual use as a grenade throw
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
    valid: 8
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
    size: bytes_per_frame
    type: frame
    repeat: expr
    repeat-expr: num_frames
  gl_cmds:
    pos: ofs_gl_cmds
    # in http://tfc.duke.free.fr/coding/src/md2.c initially read as `int *`
    # (a pool of `int`s) => hence `s4`
    size: 4 * num_gl_cmds # FIXME: replace `4` with `sizeof<s4>` once `sizeof` is implemented for GraphViz
    type: gl_cmds_list
  anim_names:
    value: |
      ['stand', 'run', 'attack', 'pain1', 'pain2', 'pain3', 'jump', 'flip',
      'salute', 'taunt', 'wave', 'point', 'crstnd', 'crwalk', 'crattak',
      'crpain', 'crdeath', 'death1', 'death2', 'death3']
  anim_start_indices:
    value: |
      [0, 40, 46, 54, 58, 62, 66, 72,
      84, 95, 112, 123, 135, 154, 160,
      169, 173, 178, 184, 190]
  anim_num_frames:
    value: |
      [40, 6, 8, 4, 4, 4, 6, 12,
      11, 17, 11, 12, 19, 6, 9,
      4, 5, 6, 6, 8]
  anorms_table:
    doc-ref: |
      https://github.com/skullernet/q2pro/blob/f4faabd/src/common/math.c#L80
      from Quake anorms.h
    value: |
      [
        [-0.525731, 0.000000, 0.850651],
        [-0.442863, 0.238856, 0.864188],
        [-0.295242, 0.000000, 0.955423],
        [-0.309017, 0.500000, 0.809017],
        [-0.162460, 0.262866, 0.951056],
        [0.000000, 0.000000, 1.000000],
        [0.000000, 0.850651, 0.525731],
        [-0.147621, 0.716567, 0.681718],
        [0.147621, 0.716567, 0.681718],
        [0.000000, 0.525731, 0.850651],
        [0.309017, 0.500000, 0.809017],
        [0.525731, 0.000000, 0.850651],
        [0.295242, 0.000000, 0.955423],
        [0.442863, 0.238856, 0.864188],
        [0.162460, 0.262866, 0.951056],
        [-0.681718, 0.147621, 0.716567],
        [-0.809017, 0.309017, 0.500000],
        [-0.587785, 0.425325, 0.688191],
        [-0.850651, 0.525731, 0.000000],
        [-0.864188, 0.442863, 0.238856],
        [-0.716567, 0.681718, 0.147621],
        [-0.688191, 0.587785, 0.425325],
        [-0.500000, 0.809017, 0.309017],
        [-0.238856, 0.864188, 0.442863],
        [-0.425325, 0.688191, 0.587785],
        [-0.716567, 0.681718, -0.147621],
        [-0.500000, 0.809017, -0.309017],
        [-0.525731, 0.850651, 0.000000],
        [0.000000, 0.850651, -0.525731],
        [-0.238856, 0.864188, -0.442863],
        [0.000000, 0.955423, -0.295242],
        [-0.262866, 0.951056, -0.162460],
        [0.000000, 1.000000, 0.000000],
        [0.000000, 0.955423, 0.295242],
        [-0.262866, 0.951056, 0.162460],
        [0.238856, 0.864188, 0.442863],
        [0.262866, 0.951056, 0.162460],
        [0.500000, 0.809017, 0.309017],
        [0.238856, 0.864188, -0.442863],
        [0.262866, 0.951056, -0.162460],
        [0.500000, 0.809017, -0.309017],
        [0.850651, 0.525731, 0.000000],
        [0.716567, 0.681718, 0.147621],
        [0.716567, 0.681718, -0.147621],
        [0.525731, 0.850651, 0.000000],
        [0.425325, 0.688191, 0.587785],
        [0.864188, 0.442863, 0.238856],
        [0.688191, 0.587785, 0.425325],
        [0.809017, 0.309017, 0.500000],
        [0.681718, 0.147621, 0.716567],
        [0.587785, 0.425325, 0.688191],
        [0.955423, 0.295242, 0.000000],
        [1.000000, 0.000000, 0.000000],
        [0.951056, 0.162460, 0.262866],
        [0.850651, -0.525731, 0.000000],
        [0.955423, -0.295242, 0.000000],
        [0.864188, -0.442863, 0.238856],
        [0.951056, -0.162460, 0.262866],
        [0.809017, -0.309017, 0.500000],
        [0.681718, -0.147621, 0.716567],
        [0.850651, 0.000000, 0.525731],
        [0.864188, 0.442863, -0.238856],
        [0.809017, 0.309017, -0.500000],
        [0.951056, 0.162460, -0.262866],
        [0.525731, 0.000000, -0.850651],
        [0.681718, 0.147621, -0.716567],
        [0.681718, -0.147621, -0.716567],
        [0.850651, 0.000000, -0.525731],
        [0.809017, -0.309017, -0.500000],
        [0.864188, -0.442863, -0.238856],
        [0.951056, -0.162460, -0.262866],
        [0.147621, 0.716567, -0.681718],
        [0.309017, 0.500000, -0.809017],
        [0.425325, 0.688191, -0.587785],
        [0.442863, 0.238856, -0.864188],
        [0.587785, 0.425325, -0.688191],
        [0.688191, 0.587785, -0.425325],
        [-0.147621, 0.716567, -0.681718],
        [-0.309017, 0.500000, -0.809017],
        [0.000000, 0.525731, -0.850651],
        [-0.525731, 0.000000, -0.850651],
        [-0.442863, 0.238856, -0.864188],
        [-0.295242, 0.000000, -0.955423],
        [-0.162460, 0.262866, -0.951056],
        [0.000000, 0.000000, -1.000000],
        [0.295242, 0.000000, -0.955423],
        [0.162460, 0.262866, -0.951056],
        [-0.442863, -0.238856, -0.864188],
        [-0.309017, -0.500000, -0.809017],
        [-0.162460, -0.262866, -0.951056],
        [0.000000, -0.850651, -0.525731],
        [-0.147621, -0.716567, -0.681718],
        [0.147621, -0.716567, -0.681718],
        [0.000000, -0.525731, -0.850651],
        [0.309017, -0.500000, -0.809017],
        [0.442863, -0.238856, -0.864188],
        [0.162460, -0.262866, -0.951056],
        [0.238856, -0.864188, -0.442863],
        [0.500000, -0.809017, -0.309017],
        [0.425325, -0.688191, -0.587785],
        [0.716567, -0.681718, -0.147621],
        [0.688191, -0.587785, -0.425325],
        [0.587785, -0.425325, -0.688191],
        [0.000000, -0.955423, -0.295242],
        [0.000000, -1.000000, 0.000000],
        [0.262866, -0.951056, -0.162460],
        [0.000000, -0.850651, 0.525731],
        [0.000000, -0.955423, 0.295242],
        [0.238856, -0.864188, 0.442863],
        [0.262866, -0.951056, 0.162460],
        [0.500000, -0.809017, 0.309017],
        [0.716567, -0.681718, 0.147621],
        [0.525731, -0.850651, 0.000000],
        [-0.238856, -0.864188, -0.442863],
        [-0.500000, -0.809017, -0.309017],
        [-0.262866, -0.951056, -0.162460],
        [-0.850651, -0.525731, 0.000000],
        [-0.716567, -0.681718, -0.147621],
        [-0.716567, -0.681718, 0.147621],
        [-0.525731, -0.850651, 0.000000],
        [-0.500000, -0.809017, 0.309017],
        [-0.238856, -0.864188, 0.442863],
        [-0.262866, -0.951056, 0.162460],
        [-0.864188, -0.442863, 0.238856],
        [-0.809017, -0.309017, 0.500000],
        [-0.688191, -0.587785, 0.425325],
        [-0.681718, -0.147621, 0.716567],
        [-0.442863, -0.238856, 0.864188],
        [-0.587785, -0.425325, 0.688191],
        [-0.309017, -0.500000, 0.809017],
        [-0.147621, -0.716567, 0.681718],
        [-0.425325, -0.688191, 0.587785],
        [-0.162460, -0.262866, 0.951056],
        [0.442863, -0.238856, 0.864188],
        [0.162460, -0.262866, 0.951056],
        [0.309017, -0.500000, 0.809017],
        [0.147621, -0.716567, 0.681718],
        [0.000000, -0.525731, 0.850651],
        [0.425325, -0.688191, 0.587785],
        [0.587785, -0.425325, 0.688191],
        [0.688191, -0.587785, 0.425325],
        [-0.955423, 0.295242, 0.000000],
        [-0.951056, 0.162460, 0.262866],
        [-1.000000, 0.000000, 0.000000],
        [-0.850651, 0.000000, 0.525731],
        [-0.955423, -0.295242, 0.000000],
        [-0.951056, -0.162460, 0.262866],
        [-0.864188, 0.442863, -0.238856],
        [-0.951056, 0.162460, -0.262866],
        [-0.809017, 0.309017, -0.500000],
        [-0.864188, -0.442863, -0.238856],
        [-0.951056, -0.162460, -0.262866],
        [-0.809017, -0.309017, -0.500000],
        [-0.681718, 0.147621, -0.716567],
        [-0.681718, -0.147621, -0.716567],
        [-0.850651, 0.000000, -0.525731],
        [-0.688191, 0.587785, -0.425325],
        [-0.587785, 0.425325, -0.688191],
        [-0.425325, 0.688191, -0.587785],
        [-0.425325, -0.688191, -0.587785],
        [-0.587785, -0.425325, -0.688191],
        [-0.688191, -0.587785, -0.425325],
      ]
types:
  tex_point:
    seq:
      - id: s_px
        type: u2
      - id: t_px
        type: u2
    instances:
      s_normalized:
        value: (s_px + 0.0) / _root.skin_width_px
      t_normalized:
        value: (t_px + 0.0) / _root.skin_height_px
  triangle:
    seq:
      - id: vertex_indices
        type: u2
        repeat: expr
        repeat-expr: 3
        doc: indices to `_root.frames[i].vertices` (for each frame with index `i`)
      - id: tex_point_indices
        type: u2
        repeat: expr
        repeat-expr: 3
        doc: indices to `_root.tex_coords`
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
    instances:
      normal:
        value: _root.anorms_table[normal_index]
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
  gl_cmds_list:
    seq:
      - id: items
        type: gl_cmd
        repeat: until
        repeat-until: _.cmd_num_vertices == 0
        if: not _io.eof
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
        value: 'cmd_num_vertices < 0 ? gl_primitive::triangle_fan : gl_primitive::triangle_strip'
  gl_vertex:
    seq:
      - id: tex_coords_normalized
        type: f4
        repeat: expr
        repeat-expr: 2
      - id: vertex_index
        type: u4
        doc: index to `_root.frames[i].vertices` (for each frame with index `i`)
enums:
  gl_primitive:
    0: triangle_strip
    1: triangle_fan
