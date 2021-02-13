meta:
  id: mmd_pmx
  title: MMD model data (newer format)
  application: MikuMikuDance
  file-extension: pmx
  encoding: UTF-16LE
  endian: le
  license: MIT

seq:
  - id: header
    type: header
  - id: vertex_count
    type: u4
  - id: vertices
    type: vertex
    repeat: expr
    repeat-expr: vertex_count
  - id: face_vertex_count
    type: u4
  - id: faces
    type: face
    repeat: expr
    repeat-expr: face_vertex_count / 3
  - id: texture_count
    type: u4
  - id: textures
    type: texture
    repeat: expr
    repeat-expr: texture_count
  - id: material_count
    type: u4
  - id: materials
    type: material
    repeat: expr
    repeat-expr: material_count
  - id: bone_count
    type: u4
  - id: bones
    type: bone
    repeat: expr
    repeat-expr: bone_count
  - id: morph_count
    type: u4
  - id: morphs
    type: morph
    repeat: expr
    repeat-expr: morph_count
  - id: frame_count
    type: u4
  - id: frames
    type: frame
    repeat: expr
    repeat-expr: frame_count
  - id: rigid_body_count
    type: u4
  - id: rigid_bodies
    type: rigid_body
    repeat: expr
    repeat-expr: rigid_body_count
  - id: constraint_count
    type: u4
  - id: constraints
    type: constraint
    repeat: expr
    repeat-expr: constraint_count

types:

  header:
    seq:
      - id: magic
        contents: 'PMX '
      - id: version
        type: f4
      - id: header_size
        type: u1
      - id: encoding
        type: u1
      - id: additional_uv_count
        type: u1
      - id: vertex_index_size
        type: u1
      - id: texture_index_size
        type: u1
      - id: material_index_size
        type: u1
      - id: bone_index_size
        type: u1
      - id: morph_index_size
        type: u1
      - id: rigid_body_index_size
        type: u1
      - id: model_name
        type: len_string
      - id: english_model_name
        type: len_string
      - id: comment
        type: len_string
      - id: english_comment
        type: len_string

  vertex:
    seq:
      - id: position
        type: f4_3
      - id: normal
        type: f4_3
      - id: uv
        type: f4_2
      - id: additional_uvs
        type: f4_4
        repeat: expr
        repeat-expr: _root.header.additional_uv_count
      - id: type
        type: u1
      - id: skin_indices
        type:
          switch-on: _root.header.bone_index_size
          cases:
            1: u1
            2: u2
            4: u4
        repeat: expr
        repeat-expr: 'type == 0 ? 1 : type == 1 ? 2 : type == 2 ? 4 : type == 3 ? 2 : -1'
      - id: skin_weights
        type: f4
        if: type == 1 or type == 2 or type == 3
        repeat: expr
        repeat-expr: 'type == 1 ? 1 : type == 2 ? 4 : type == 3 ? 1 : -1'
      - id: skin_c
        type: f4_3
        if: type == 3
      - id: skin_r0
        type: f4_3
        if: type == 3
      - id: skin_r1
        type: f4_3
        if: type == 3
      - id: edge_ratio
        type: f4

  face:
    seq:
      - id: indices
        type:
          switch-on: _root.header.vertex_index_size
          cases:
            1: u1
            2: u2
            4: u4
        repeat: expr
        repeat-expr: 3

  texture:
    seq:
      - id: name
        type: len_string

  material:
    seq:
      - id: name
        type: len_string
      - id: english_name
        type: len_string
      - id: diffuse
        type: f4_4
      - id: specular
        type: f4_3
      - id: shininess
        type: f4
      - id: ambient
        type: f4_3
      - id: flag
        type: u1
      - id: edge_color
        type: f4_4
      - id: edge_size
        type: f4
      - id: texture_index
        type:
          switch-on: _root.header.texture_index_size
          cases:
            1: u1
            2: u2
            4: u4
      - id: env_texture_index
        type:
          switch-on: _root.header.texture_index_size
          cases:
            1: u1
            2: u2
            4: u4
      - id: env_flag
        type: u1
      - id: toon_flag
        type: u1
      - id: toon_index
        type:
          switch-on: 'toon_flag == 1 ? 1 : toon_flag == 0 ? _root.header.texture_index_size : -1'
          cases:
            1: u1
            2: u2
            4: u4
      - id: comment
        type: len_string
      - id: face_vertex_count
        type: u4

  bone:
    seq:
      - id: name
        type: len_string
      - id: english_name
        type: len_string
      - id: position
        type: f4_3
      - id: parent_index
        type:
          switch-on: _root.header.bone_index_size
          cases:
            1: u1
            2: u2
            4: u4
      - id: transformation_class
        type: u4
      - id: flag
        type: u2
      - id: connect_index
        type:
          switch-on: _root.header.bone_index_size
          cases:
            1: u1
            2: u2
            4: u4
        if: flag & 0x1 != 0
      - id: offset_position
        type: f4_3
        if: flag & 0x1 == 0
      - id: grant
        type: bone_grant
        if: flag & 0x100 != 0 or flag & 0x200 != 0
      - id: fix_axis
        type: f4_3
        if: flag & 0x400 != 0
      - id: local_x_vector
        type: f4_3
        if: flag & 0x800 != 0
      - id: local_z_vector
        type: f4_3
        if: flag & 0x800 != 0
      - id: key
        type: u4
        if: flag & 0x2000 != 0
      - id: ik
        type: bone_ik
        if: flag & 0x20 != 0


  #TODO: Another project commented that this wasn't a good name. I'm not sure either way.
  bone_grant:
    seq:
      - id: parent_index
        type:
          switch-on: _root.header.bone_index_size
          cases:
            1: u1
            2: u2
            4: u4
      - id: ratio
        type: f4
    instances:
      local:
        value: (_parent.flag & 0x80) != 0
      affect_rotation:
        value: (_parent.flag & 0x100) != 0
      affect_position:
        value: (_parent.flag & 0x200) != 0

  bone_ik:
    seq:
      - id: effector
        type:
          switch-on: _root.header.bone_index_size
          cases:
            1: u1
            2: u2
            4: u4
      - id: iteration
        type: u4
      - id: max_angle
        type: f4
      - id: link_count
        type: u4
      - id: links
        type: bone_ik_link
        repeat: expr
        repeat-expr: link_count

  bone_ik_link:
    seq:
      - id: index
        type:
          switch-on: _root.header.bone_index_size
          cases:
            1: u1
            2: u2
            4: u4
      - id: angle_limitation
        type: u1
      - id: lower_limitation_angle
        type: f4_3
        if: angle_limitation == 1
      - id: upper_limitation_angle
        type: f4_3
        if: angle_limitation == 1

  morph:
    seq:
      - id: name
        type: len_string
      - id: english_name
        type: len_string
      - id: panel
        type: u1
      - id: type
        type: u1
      - id: element_count
        type: u4
      - id: elements
        type:
          switch-on: type
          cases:
            0: group_morph_element
            1: vertex_morph_element
            2: bone_morph_element
            3: uv_morph_element
            #TODO 4: additional_uv1_morph_element
            #TODO 5: additional_uv1_morph_element
            #TODO 6: additional_uv1_morph_element
            #TODO 7: additional_uv1_morph_element
            8: material_morph_element
        repeat: expr
        repeat-expr: element_count

  group_morph_element:
    seq:
      - id: index
        type:
          switch-on: _root.header.morph_index_size
          cases:
            1: u1
            2: u2
            4: u4
      - id: ratio
        type: f4

  vertex_morph_element:
    seq:
      - id: index
        type:
          switch-on: _root.header.vertex_index_size
          cases:
            1: u1
            2: u2
            4: u4
      - id: position
        type: f4_3

  bone_morph_element:
    seq:
      - id: index
        type:
          switch-on: _root.header.bone_index_size
          cases:
            1: u1
            2: u2
            4: u4
      - id: position
        type: f4_3
      - id: rotation
        type: f4_4

  uv_morph_element:
    seq:
      - id: index
        type:
          switch-on: _root.header.vertex_index_size
          cases:
            1: u1
            2: u2
            4: u4
      - id: uv
        type: f4_4

  material_morph_element:
    seq:
      - id: index
        type:
          switch-on: _root.header.material_index_size
          cases:
            1: u1
            2: u2
            4: u4
      - id: type
        type: u1
      - id: diffuse
        type: f4_4
      - id: specular
        type: f4_3
      - id: shininess
        type: f4
      - id: ambient
        type: f4_3
      - id: edge_color
        type: f4_4
      - id: edge_size
        type: f4
      - id: texture_color
        type: f4_4
      - id: sphere_texture_color
        type: f4_4
      - id: toon_color
        type: f4_4

  frame:
    seq:
      - id: name
        type: len_string
      - id: english_name
        type: len_string
      - id: type
        type: u1
      - id: element_count
        type: u4
      - id: elements
        type: frame_element
        repeat: expr
        repeat-expr: element_count

  frame_element:
    seq:
      - id: target
        type: u1
      - id: index
        type:
          switch-on: 'target == 0 ? _root.header.bone_index_size : _root.header.morph_index_size'
          cases:
            1: u1
            2: u2
            4: u4

  rigid_body:
    seq:

      - id: name
        type: len_string
      - id: english_name
        type: len_string
      - id: bone_index
        type:
          switch-on: _root.header.bone_index_size
          cases:
            1: u1
            2: u2
            4: u4
      - id: group_index
        type: u1
      - id: group_target
        type: u2
      - id: shape_type
        type: u1
      - id: width
        type: f4
      - id: height
        type: f4
      - id: depth
        type: f4
      - id: position
        type: f4_3
      - id: rotation
        type: f4_3
      - id: weight
        type: f4
      - id: position_damping
        type: f4
      - id: rotation_damping
        type: f4
      - id: restitution
        type: f4
      - id: friction
        type: f4
      - id: type
        type: u1

  constraint:
    seq:

      - id: name
        type: len_string
      - id: english_name
        type: len_string
      - id: type
        type: u1
      - id: rigid_body_index1
        type:
          switch-on: _root.header.rigid_body_index_size
          cases:
            1: u1
            2: u2
            4: u4
      - id: rigid_body_index2
        type:
          switch-on: _root.header.rigid_body_index_size
          cases:
            1: u1
            2: u2
            4: u4
      - id: position
        type: f4_3
      - id: rotation
        type: f4_3
      - id: translation_limitation1
        type: f4_3
      - id: translation_limitation2
        type: f4_3
      - id: rotation_limitation1
        type: f4_3
      - id: rotation_limitation2
        type: f4_3
      - id: spring_position
        type: f4_3
      - id: spring_rotation
        type: f4_3

  f4_2:
    seq:
      - id: x
        type: f4
      - id: y
        type: f4

  f4_3:
    seq:
      - id: x
        type: f4
      - id: y
        type: f4
      - id: z
        type: f4

  f4_4:
    seq:
      - id: x
        type: f4
      - id: y
        type: f4
      - id: z
        type: f4
      - id: w
        type: f4

  len_string:
    seq:
      - id: length
        type: u4
      - id: value
        type: str
        size: length
