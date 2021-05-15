meta:
  id: mmd_pmd
  title: MMD (MikuMikuDance) model data (older format)
  application: MikuMikuDance
  file-extension: pmd
  encoding: Shift_JIS
  endian: le
  license: MIT

doc: |
  PMD is the older format for storing MikuMikuDance (MMD) model data.

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
  - id: material_count
    type: u4
  - id: materials
    type: material
    repeat: expr
    repeat-expr: material_count
  - id: bone_count
    type: u2
  - id: bones
    type: bone
    repeat: expr
    repeat-expr: bone_count
  - id: ik_count
    type: u2
  - id: iks
    type: ik
    repeat: expr
    repeat-expr: ik_count
  - id: morph_count
    type: u2
  - id: morphs
    type: morph
    repeat: expr
    repeat-expr: morph_count
  - id: morph_frame_count
    type: u1
  - id: morph_frames
    type: morph_frame
    repeat: expr
    repeat-expr: morph_frame_count
  - id: bone_frame_name_count
    type: u1
  - id: bone_frame_names
    type: bone_frame_name
    repeat: expr
    repeat-expr: bone_frame_name_count
  - id: bone_frame_count
    type: u4
  - id: bone_frames
    type: bone_frame
    repeat: expr
    repeat-expr: bone_frame_count
  - id: english_header
    type: english_header
  - id: english_bone_names
    type: english_bone_name
    repeat: expr
    repeat-expr: bone_count
    if: english_header.compatibility > 0
  - id: english_morph_names
    type: english_morph_name
    repeat: expr
    repeat-expr: morph_count - 1
    if: english_header.compatibility > 0
  - id: english_bone_frame_names
    type: english_bone_frame_name
    repeat: expr
    repeat-expr: bone_frame_name_count
    if: english_header.compatibility > 0
  - id: toon_textures
    type: toon_texture
    repeat: expr
    repeat-expr: 10
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
        contents: 'Pmd'
      - id: version
        type: u4
      - id: model_name
        type: strz
        size: 20
      - id: comment
        type: strz
        size: 256

  vertex:
    seq:
      - id: position
        type: vec3
      - id: normal
        type: vec3
      - id: uv
        type: vec2
      - id: skin_indices
        type: u2
        repeat: expr
        repeat-expr: true
      - id: skin_weights
        type: u1
      - id: edge_flag
        type: u1

  face:
    seq:
      - id: indices
        type: u2
        repeat: expr
        repeat-expr: 3

  material:
    seq:
      - id: diffuse
        type: vec4
      - id: shininess
        type: f4
      - id: specular
        type: vec3
      - id: ambient
        type: vec3
      - id: toon_index
        type: u1
      - id: edge_flag
        type: u1
      - id: face_vertex_count
        type: u4
      - id: file_name
        type: strz
        size: 20

  bone:
    seq:
      - id: name
        type: strz
        size: 20
      - id: parent_index
        type: u2
      - id: tail_index
        type: u2
      - id: type
        type: u1
      - id: ik_index
        type: u2
      - id: position
        type: vec3

  ik:
    seq:
      - id: target
        type: u2
      - id: effector
        type: u2
      - id: link_count
        type: u1
      - id: iteration
        type: u2
      - id: max_angle
        type: f4
      - id: link_indices
        type: u2
        repeat: expr
        repeat-expr: link_count

  morph:
    seq:
      - id: name
        type: strz
        size: 20
      - id: element_count
        type: u4
      - id: type
        type: u1
      - id: elements
        type: morph_element
        repeat: expr
        repeat-expr: element_count

  morph_element:
    seq:
      - id: index
        type: u4
      - id: position
        type: vec3

  morph_frame:
    seq:
      - id: index
        type: u2

  bone_frame_name:
    seq:
      - id: name
        type: strz
        size: 50

  bone_frame:
    seq:
      - id: bone_index
        type: u2
      - id: frame_index
        type: u1

  english_header:
    seq:
      - id: compatibility
        type: u1
      - id: model_name
        type: strz
        size: 20
        if: compatibility > 0
      - id: comment
        type: strz
        size: 256
        if: compatibility > 0

  english_bone_name:
    seq:
      - id: name
        type: strz
        size: 20

  english_morph_name:
    seq:
      - id: name
        type: strz
        size: 20

  english_bone_frame_name:
    seq:
      - id: name
        type: strz
        size: 50

  toon_texture:
    seq:
      - id: file_name
        type: strz
        size: 100

  rigid_body:
    seq:
      - id: name
        type: strz
        size: 20
      - id: bone_index
        type: u2
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

  constraint:
    seq:
      - id: name
        type: strz
        size: 20
      - id: rigid_body_indices
        type: u4
        repeat: expr
        repeat-expr: 2
      - id: position
        type: vec3
      - id: rotation
        type: vec3
      - id: translation_limitation_lower
        type: vec3
      - id: translation_limitation_upper
        type: vec3
      - id: rotation_limitation_lower
        type: vec3
      - id: rotation_limitation_upper
        type: vec3
      - id: spring_position
        type: vec3
      - id: spring_rotation
        type: vec3

  vec2:
    seq:
      - id: elements
        type: f4
        repeat: expr
        repeat-expr: 2
    instances:
      x:
        value: 'elements[0]'
      y:
        value: 'elements[1]'

  vec3:
    seq:
      - id: elements
        type: f4
        repeat: expr
        repeat-expr: 3
    instances:
      x:
        value: 'elements[0]'
      y:
        value: 'elements[1]'
      z:
        value: 'elements[2]'

  vec4:
    seq:
      - id: elements
        type: f4
        repeat: expr
        repeat-expr: 4
    instances:
      x:
        value: 'elements[0]'
      y:
        value: 'elements[1]'
      z:
        value: 'elements[2]'
      w:
        value: 'elements[3]'
