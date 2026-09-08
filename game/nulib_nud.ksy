meta:
  id: nulib_nud
  file-extension: nud
  application: Games with Namco NU library
  title: Namco 3D Model
  endian: le
  license: MIT
  #  switch-on: file_type
  #  cases:
  #    ndwd: le
  #    ndp3: be
seq:
  - id: magic
    type: u4le
    enum: signature
    valid:
      any-of:
        - signature::ndwd
  - id: header
    type: header
  - id: meshes
    type: mesh(_index)
    repeat: expr
    repeat-expr: header.polyset_count
  - id: parts
    type: parts(meshes[_index].part_count)
    repeat: expr
    repeat-expr: header.polyset_count

types:
  header:
    seq:
      - id: file_size
        type: u4
      - id: version
        type: u2le
        enum: version
        valid:
          any-of:
            - version::v2
      - id: polyset_count
        type: u2
      - id: bone_channels
        type: u2
      - id: bone_count
        type: u2
      - id: part_clump_size
        type: u4
      - id: indices_clump_size
        type: u4
      - id: vert_clump_size
        type: u4
      - id: vert_add_clump_size
        type: u4
      - id: bounding_sphere
        type: f4
        repeat: expr
        repeat-expr: 4
    instances:
      part_clump_start:
        value: 0x30
      indices_clump_start:
        value: part_clump_start + part_clump_size
      vert_clump_start:
        value: indices_clump_start + indices_clump_size
      vert_add_clump_start:
        value: vert_clump_start + vert_clump_size
      name_start:
        value: vert_add_clump_start + vert_add_clump_size
  parts:
    params:
      - id: num_parts
        type: u2
    seq:
      - id: parts
        type: part
        size: 0x30
        repeat: expr
        repeat-expr: num_parts
  mesh:
    params:
      - id: i
        type: u4
    seq:
      - id: bounding_sphere
        type: f4
        repeat: expr
        repeat-expr: 8
      - id: name_offset
        type: u4
      - id: empty_bytes
        doc: this is just for alignment
        contents: [0, 0]
      - id: bone_flags
        type: u2
      - id: bone_index
        type: s2
      - id: part_count
        type: u2
      - id: position_b
        type: s4
    instances:
      name:
        id: _root._io
        pos: _parent.header.name_start + name_offset
        type: strz
        encoding: UTF-8
      parts:
        value: _root.parts[i].parts
  part:
    seq:
      - id: poly_offset
        type: u4
      - id: vert_offset
        type: u4
      - id: vert_add_offset
        type: u4
      - id: num_vertices
        type: u2
      # vertex info byte
      - id: bone_size
        type: b4
        enum: bone_size
      - id: unused_bit
        type: b1
        valid:
          any-of:
            - false
      - id: normal_half_float
        type: b1
      - id: normal_type
        type: b2
        enum: normal_type
      # uv info byte
      - id: uv_channel_count
        type: b4
      - id: vertex_color_size
        type: b3
        enum: vertex_color_size
      - id: uv_float
        type: b1
      # ------------
      - id: texprop
        type: u4
        repeat: expr
        repeat-expr: 4
      - id: num_indices
        type: u2
      - id: poly_size
        type: u1
      - id: poly_flag # TODO
        doc: Need to determine what this does
        type: u1
        valid:
          any-of:
            - 0
    instances:
      indices_start:
        value: _root.header.indices_clump_start + poly_offset
      vert_start:
        value: _root.header.vert_clump_start + vert_offset
      vert_add_start:
        value: _root.header.vert_add_clump_start + vert_add_offset

      # TODO: read uv
      vertices:
        io: _root._io
        pos: vert_start
        type: vertex
        repeat: expr
        repeat-expr: num_vertices
      indices:
        io: _root._io
        pos: indices_start
        type: u2
        repeat: expr
        repeat-expr: num_indices
      materials:
        type: material_wrapper(texprop[_index])
        repeat: until
        repeat-until: _index == 4 or texprop[_index] == 0
  vertex:
    seq:
      - id: position
        type: f4
        repeat: expr
        repeat-expr: 3
      - id: padding
        size: 4
        if: _parent.normal_type == normal_type::no_normals or
          (_parent.normal_type == normal_type::normals_tan_bitan and not _parent.normal_half_float)

      - id: normal
        if: _parent.normal_type != normal_type::no_normals
        type:
          switch-on: _parent.normal_half_float
          cases:
            true: u2
            false: f4
        repeat: expr
        repeat-expr: 4

      - id: r1
        doc: 'no idea what this is'
        size: 4
        repeat: expr
        repeat-expr: '_parent.normal_type == normal_type::normals_float ? 1 : 8'
        if: (_parent.normal_type == normal_type::normals_r1 or
          _parent.normal_type == normal_type::normals_float)
          and not _parent.normal_half_float

      - id: tan
        if: _parent.normal_type == normal_type::normals_tan_bitan
        type:
          switch-on: _parent.normal_half_float
          cases:
            true: u2
            false: f4
        repeat: expr
        repeat-expr: 4
      - id: bitan
        if: _parent.normal_type == normal_type::normals_tan_bitan
        type:
          switch-on: _parent.normal_half_float
          cases:
            true: u2
            false: f4
        repeat: expr
        repeat-expr: 4

      - id: colors
        if: |
          (_parent.bone_size == bone_size::no_bones) and
          (_parent.vertex_color_size != vertex_color_size::no_vertex_colors)
        type: u1
        repeat: expr
        repeat-expr: 4

      - id: uv
        if: _parent.bone_size == bone_size::no_bones
        type:
          switch-on: _parent.uv_float
          cases:
            true: f4
            false: u2
        repeat: expr
        repeat-expr: _parent.uv_channel_count * 2

      - id: bone_id
        if: _parent.bone_size != bone_size::no_bones
        type:
          switch-on: _parent.bone_size
          cases:
            'bone_size::float': u4
            'bone_size::half_float': u2
            'bone_size::byte': u1
        repeat: expr
        repeat-expr: 4
      - id: bone_weight
        if: _parent.bone_size != bone_size::no_bones
        type:
          switch-on: _parent.bone_size
          cases:
            'bone_size::float': f4
            'bone_size::half_float': u2
            'bone_size::byte': u1
        repeat: expr
        repeat-expr: 4
  material_wrapper:
    params:
      - id: position
        type: u4
    instances:
      material:
        io: _root._io
        type: material
        pos: position
  material:
    seq:
      # TODO
      #0001 0000 0000 0000 0000 0010 0000 0001
      #0001 0000 0000 0000 0000 0010 1100 0010
      #0001 0000 0000 0000 0000 0010 1011 0010
      #0001 0000 0000 0000 0000 0010 0000 0000
      #0010 0000 0000 0000 0000 0010 0001 0101
      #0001 0000 0000 0000 0000 0010 1001 0001
      - id: flags
        type: texture_flags
      - id: unknown_byte1
        type: u1
      - id: unknown_byte2
        type: u1
      - id: material_type
        type: u1
      - id: padding
        size: 4
      - id: src_factor
        type: u2
      - id: num_material_textures
        type: u2
      - id: dst_factor
        type: u2
      - id: alpha_test
        type: b1
      - id: alpha_function
        type: u1
        enum: alpha_function
      - id: ref_alpha
        type: u2
      - id: cull_mode
        type: u2
        enum: cull_mode
      - id: padding_2
        size: 8
      - id: z_buffer_offset
        type: s4
      - id: material_textures
        type: material_texture
        repeat: expr
        repeat-expr: num_material_textures
      - id: material_attributes
        type: material_attribute
        repeat: until
        repeat-until: _.size == 0
    types:
      texture_flags:
        seq:
          - id: glow
            type: b1
          - id: shadow
            type: b1
          - id: dummy_ramp
            type: b1
          - id: sphere_map
            type: b1
          - id: stage_ao_map
            type: b1
          - id: ramp_cube_map
            type: b1
          - id: normal_map
            type: b1
          - id: diffuse_map
            type: b1
  material_attribute:
    seq:
      - id: size
        type: u4
      - id: name_offset
        type: u4
      - id: num_values
        type: u4be
      - id: padding
        size: 4
      - id: values
        type: f4
        repeat: expr
        repeat-expr: num_values
    instances:
      name:
        type: strz
        if: num_values != 0
        pos: _root.header.name_start + name_offset
        encoding: UTF-8
  material_texture:
    seq:
      - id: hash
        type: s4
      - id: unknown
        size: 6
      - id: map_mode
        type: u2
        enum: map_mode
      - id: wrap_mode_s
        type: u1
        enum: wrap_mode
      - id: wrap_mode_t
        type: u1
        enum: wrap_mode
      - id: min_filter
        type: u1
        enum: filter_mode
      - id: mag_filter
        type: u1
        enum: filter_mode
      - id: mip_detail
        type: u1
        enum: mip_detail
      - id: unknown_2
        size: 7

enums:
  normal_type:
    0: no_normals
    1: normals_float
    2: normals_r1
    3: normals_tan_bitan
  normal_size:
    0: float
    1: half_float
  bone_size:
    0: no_bones
    1: float
    2: half_float
    4: byte
  vertex_color_size:
    0: no_vertex_colors
    1: byte
    2: half_float
  signature:
    1146569806: ndwd # NDWD
    1313099827: ndp3 # NDP3
  version:
    2: v2 # TODO
  bone_flags: # these may actually be bit flags...
    0: unbound
    4: weighted
    8: single_bound
  alpha_function:
    0: no_alpha
    4: alpha_1
    6: alpha_2
  wrap_mode:
    1: repeat
    2: mirrored_repeat
    3: clamp_to_edge
  filter_mode:
    0: linear_mipmap_linear # TODO: fix this...
    1: nearest
    2: linear
    3: nearest_mipmap_linear
  cull_mode:
    0x000: none
    0x002: inside_pokken
    0x404: outside
    0x405: inside
  map_mode:
    0x00: tex_coord
    0x1d00: env_camera
    0x1e00: projection
    0x1ecd: env_light
    0x1f00: env_spec
  mip_detail:
    1: level_1
    2: level_1_off
    3: level_4
    4: level_4_anisotropic
    5: level_4_trilinear
    6: level_4_trilinear_anisotripic
