meta:
  id: vector_types
  endian: le

doc: Common vector types shared by multiple formats

types:

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

  color3:
    seq:
      - id: r
        type: f4
      - id: g
        type: f4
      - id: b
        type: f4

  color4:
    seq:
      - id: r
        type: f4
      - id: g
        type: f4
      - id: b
        type: f4
      - id: a
        type: f4
