meta:
  id: stl
  endian: le
  file-extension: stl
  application: 3D Systems Stereolithography
seq:
  - id: header
    size: 80
  - id: num_triangles
    type: u4
  - id: triangles
    type: triangle
    repeat: expr
    repeat-expr: num_triangles
types:
  triangle:
    seq:
      - id: normal
        type: vec3d
      - id: vertices
        type: vec3d
        repeat: expr
        repeat-expr: 3
  vec3d:
    seq:
      - id: x
        type: f4
      - id: y
        type: f4
      - id: z
        type: f4
