meta:
  id: evil_islands_anm
  title: Evil Islands, ANM file (bone animation)
  application: Evil Islands
  file-extension: anm
  license: MIT
  endian: le
doc: Bone animation
doc-ref: https://github.com/aspadm/EIrepack/wiki/anm
seq:
  - id: num_rotation_frames
    type: u4
  - id: rotation_frames
    type: quat
    repeat: expr
    repeat-expr: num_rotation_frames
  - id: num_translation_frames
    type: u4
  - id: translation_frames
    type: vec3
    repeat: expr
    repeat-expr: num_translation_frames
  - id: num_morphing_frames
    type: u4
  - id: num_morphing_vertexes
    type: u4
    doc: Number of vertices with morphing
  - id: morphing_frames
    type: morphing_frame
    repeat: expr
    repeat-expr: num_morphing_frames
types:
  vec3:
    seq:
      - id: x
        type: f4
      - id: y
        type: f4
      - id: z
        type: f4
  quat:
    doc: quaternion
    seq:
      - id: w
        type: f4
      - id: x
        type: f4
      - id: y
        type: f4
      - id: z
        type: f4
  morphing_frame:
    seq:
      - id: vertex_shift
        type: vec3
        repeat: expr
        repeat-expr: _parent.num_morphing_vertexes
        doc: Morphing shift per vertex
