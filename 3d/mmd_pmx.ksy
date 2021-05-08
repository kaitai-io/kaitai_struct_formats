meta:
  id: mmd_pmx
  title: MMD (MikuMikuDance) model data (newer format)
  application: MikuMikuDance
  file-extension: pmx
  encoding: UTF-16LE
  endian: le
  license: MIT

doc: |
  PMX is the newer format for storing MikuMikuDance (MMD) model data.
  Its main improvement over the prior PMD format was that strings are
  now encoded in UTF-16 instead of Shift_JIS, and index arrays were
  made somewhat more compact.

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
  - id: joint_count
    type: u4
  - id: joints
    type: joint
    repeat: expr
    repeat-expr: joint_count

types:

  header:
    seq:
      - id: magic
        contents: 'PMX '
      - id: version
        type: f4
        doc: |
          Tends to contain the value 2.0, which is the version of the format
          described here.
      - id: header_size
        type: u1
      - id: encoding
        type: u1
        doc: 0 for UTF-16LE, 1 for UTF-8
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
        type: vec3
      - id: normal
        type: vec3
        doc: normal vector, which is supposed to be normalized.
      - id: uv
        type: vec2
        doc: texture coordinate.
      - id: additional_uvs
        type: vec4
        repeat: expr
        repeat-expr: _root.header.additional_uv_count
      - id: type
        type: u1
        enum: bone_type
      - id: skin_weights
        type:
          switch-on: type
          cases:
            'bone_type::bdef1': bdef1_weights
            'bone_type::bdef2': bdef2_weights
            'bone_type::bdef4': bdef4_weights
            'bone_type::sdef': sdef_weights
      - id: edge_ratio
        type: f4

  bdef1_weights:
    seq:
      - id: bone_index
        type: sized_index(_root.header.bone_index_size)
        doc: The weight of the bone will be 1.0

  bdef2_weights:
    seq:
      - id: bone_index1
        type: sized_index(_root.header.bone_index_size)
        doc: Uses weight 1
      - id: bone_index2
        type: sized_index(_root.header.bone_index_size)
        doc: Uses weight 2
      - id: weight1
        type: f4
    instances:
      weight2:
        value: 1.0 - weight1

  bdef4_weights:
    seq:
      - id: bone_index1
        type: sized_index(_root.header.bone_index_size)
        doc: Uses weight 1
      - id: bone_index2
        type: sized_index(_root.header.bone_index_size)
        doc: Uses weight 2
      - id: bone_index3
        type: sized_index(_root.header.bone_index_size)
        doc: Uses weight 3
      - id: bone_index4
        type: sized_index(_root.header.bone_index_size)
        doc: Uses weight 4
      - id: weight1
        type: f4
      - id: weight2
        type: f4
      - id: weight3
        type: f4
      - id: weight4
        type: f4

  sdef_weights:
    seq:
      - id: bone_index1
        type: sized_index(_root.header.bone_index_size)
        doc: Uses weight 1
      - id: bone_index2
        type: sized_index(_root.header.bone_index_size)
        doc: Uses weight 2
      - id: weight1
        type: f4
      - id: c
        type: vec3
      - id: r0
        type: vec3
      - id: r1
        type: vec3
    instances:
      weight2:
        value: 1.0 - weight1

  face:
    seq:
      - id: indices
        type: sized_index(_root.header.vertex_index_size)
        repeat: expr
        repeat-expr: 3

  texture:
    seq:
      - id: name
        type: len_string
        doc: Indicates the filename of the texture image

  material:
    seq:
      - id: name
        type: len_string
      - id: english_name
        type: len_string
      - id: diffuse
        type: vec4
      - id: specular
        type: vec3
      - id: shininess
        type: f4
      - id: ambient
        type: vec3
      - id: flags
        type: u1
        doc: |
          0b0000_0001 - Disables back-face culling
          0b0000_0010 - Casts shadow on ground
          0b0000_0100 - Writes to shadow map
          0b0000_1000 - Reads from shadow map
          0b0001_0000 - Draws pencil outline
      - id: edge_color
        type: vec4
      - id: edge_size
        type: f4
      - id: texture_index
        type: sized_index(_root.header.texture_index_size)
      - id: sphere_texture_index
        type: sized_index(_root.header.texture_index_size)
      - id: sphere_op_mode
        type: u1
        enum: sphere_op_mode
      - id: is_common_toon
        type: u1
      - id: toon_index
        doc: |
          If using a common toon texture contains an index into one of the
          common toon textures shipped with MMD.  Otherwise, contains the
          index of a texture.
        type:
          switch-on: is_common_toon
          cases:
            0: sized_index(_root.header.texture_index_size)
            1: u1
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
        type: vec3
      - id: parent_index
        type: sized_index(_root.header.bone_index_size)
      - id: transformation_class
        type: u4
      - id: flags
        type: u2
        doc: |
          0b0000_0000_0000_0001 - Connection	
          0b0000_0000_0000_0010 - Rotatable	
          0b0000_0000_0000_0100 - Movable	
          0b0000_0000_0000_1000 - Display flag	
          0b0000_0000_0001_0000 - Can operate	
          0b0000_0000_0010_0000 - Inverse kinematics	
          0b0000_0000_0100_0000 - unused?
          0b0000_0000_1000_0000 - Add local deform	
          0b0000_0001_0000_0000 - Add rotation	
          0b0000_0010_0000_0000 - Add movement	
          0b0000_0100_0000_0000 - Fixed axis	
          0b0000_1000_0000_0000 - Local axis	
          0b0001_0000_0000_0000 - Physical transform	
          0b0010_0000_0000_0000 - External parent transform	
      - id: connect_index
        type: sized_index(_root.header.bone_index_size)
        if: flags & 0x1 != 0
      - id: offset_position
        type: vec3
        if: flags & 0x1 == 0
      - id: grant
        type: bone_grant
        if: flags & 0x100 != 0 or flags & 0x200 != 0
      - id: fix_axis
        type: vec3
        if: flags & 0x400 != 0
      - id: local_x_vector
        type: vec3
        if: flags & 0x800 != 0
      - id: local_z_vector
        type: vec3
        if: flags & 0x800 != 0
      - id: key
        type: u4
        if: flags & 0x2000 != 0
      - id: ik
        type: bone_ik
        if: flags & 0x20 != 0

  bone_grant:
    doc: |
      Another project commented that this wasn't a good name. I'm not sure
      either way. What this element _appears_ to do is grant additional motion
      to a bone based on another bone, where those bones are not otherwise
      related.
      For example, you might have a watch hand spin at 1/12 the rate
      of another watch hand, even though both hands are parented to the watch,
      neither to each other.
    seq:
      - id: parent_index
        type: sized_index(_root.header.bone_index_size)
      - id: ratio
        type: f4
    instances:
      local:
        value: (_parent.flags & 0x80) != 0
      affect_rotation:
        value: (_parent.flags & 0x100) != 0
      affect_position:
        value: (_parent.flags & 0x200) != 0

  bone_ik:
    seq:
      - id: effector
        type: sized_index(_root.header.bone_index_size)
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
        type: sized_index(_root.header.bone_index_size)
      - id: angle_limitation
        type: u1
      - id: lower_limitation_angle
        type: vec3
        if: angle_limitation == 1
      - id: upper_limitation_angle
        type: vec3
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
        enum: morph_type
      - id: element_count
        type: u4
      - id: elements
        type:
          switch-on: type
          cases:
            'morph_type::group': group_morph_element
            'morph_type::vertex': vertex_morph_element
            'morph_type::bone': bone_morph_element
            'morph_type::uv': uv_morph_element
            'morph_type::additional_uv1': uv_morph_element
            'morph_type::additional_uv2': uv_morph_element
            'morph_type::additional_uv3': uv_morph_element
            'morph_type::additional_uv4': uv_morph_element
            'morph_type::material': material_morph_element
            'morph_type::flip': group_morph_element
            'morph_type::impulse': impulse_morph_element
        repeat: expr
        repeat-expr: element_count

  group_morph_element:
    seq:
      - id: index
        type: sized_index(_root.header.morph_index_size)
      - id: ratio
        type: f4

  vertex_morph_element:
    seq:
      - id: index
        type: sized_index(_root.header.vertex_index_size)
      - id: position
        type: vec3

  bone_morph_element:
    seq:
      - id: index
        type: sized_index(_root.header.bone_index_size)
      - id: position
        type: vec3
      - id: rotation
        type: vec4

  uv_morph_element:
    seq:
      - id: index
        type: sized_index(_root.header.vertex_index_size)
      - id: uv
        type: vec4

  material_morph_element:
    seq:
      - id: index
        type: sized_index(_root.header.material_index_size)
      - id: type
        type: u1
        doc: 0 = Multiply, 1 = Additive
      - id: diffuse
        type: vec4
      - id: specular
        type: vec3
      - id: shininess
        type: f4
      - id: ambient
        type: vec3
      - id: edge_color
        type: vec4
      - id: edge_size
        type: f4
      - id: texture_color
        type: vec4
      - id: sphere_texture_color
        type: vec4
      - id: toon_color
        type: vec4

  impulse_morph_element:
    seq:
      - id: rigid_body_index
        type: sized_index(_root.header.rigid_body_index_size)
      - id: local
        type: u1
      - id: translational_velocity
        type: vec3
      - id: angular_velocity
        type: vec3
        doc: |
          another source had this as torque, but it would be odd for one
          value to represent a velocity while the other represented a force

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
        doc: 0 = target bone, 1 = target morph
      - id: index
        type:
          switch-on: target
          cases:
            0: sized_index(_root.header.bone_index_size)
            _: sized_index(_root.header.morph_index_size)

  rigid_body:
    seq:
      - id: name
        type: len_string
      - id: english_name
        type: len_string
      - id: bone_index
        type: sized_index(_root.header.bone_index_size)
        doc: index of a related bone
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
        type: vec3
      - id: rotation
        type: vec3
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
        doc: |
          0 = "Jelly" style bone follow
          1 = Real physics
          2 = Real physics affecting bone

  joint:
    seq:
      - id: name
        type: len_string
      - id: english_name
        type: len_string
      - id: type
        type: u1
        doc: Only known type is 0, springy
      - id: rigid_body_index1
        type: sized_index(_root.header.rigid_body_index_size)
      - id: rigid_body_index2
        type: sized_index(_root.header.rigid_body_index_size)
      - id: position
        type: vec3
      - id: rotation
        type: vec3
      - id: position_constraint_lower
        type: vec3
      - id: position_constraint_upper
        type: vec3
      - id: rotation_constraint_lower
        type: vec3
      - id: rotation_constraint_upper
        type: vec3
      - id: spring_position
        type: vec3
      - id: spring_rotation
        type: vec3

  sized_index:
    doc: Variable-length type storing an index of a vertex, bone, etc.
    params:
      - id: size
        type: u1
    seq:
      - id: value
        type:
          switch-on: size
          cases:
            1: u1
            2: u2
            4: u4

  vec2:
    seq:
      - id: x
        type: f4
      - id: y
        type: f4

  vec3:
    seq:
      - id: x
        type: f4
      - id: y
        type: f4
      - id: z
        type: f4

  vec4:
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

enums:

  sphere_op_mode:
    0: disabled
    1: multiply
    2: add
    3: subtexture

  index_id:
    1: vertex
    2: texture
    3: material
    4: bone
    5: morph
    6: rigid_body

  bone_type:
    0: bdef1
    1: bdef2
    2: bdef4
    3: sdef

  morph_type:
    0: group
    1: vertex
    2: bone
    3: uv
    4: additional_uv1
    5: additional_uv2
    6: additional_uv3
    7: additional_uv4
    8: material
    9: flip
    10: impulse
