meta:
  id: evil_islands_fig
  title: Evil Islands, FIG file (figure)
  application: Evil Islands
  file-extension: fig
  license: MIT
  endian: le
doc: 3d mesh
doc-ref: https://github.com/aspadm/EIrepack/wiki/fig
seq:
  - id: magic
    contents: [0x46, 0x49, 0x47, 0x38]
  - id: num_vertex_blocks
    type: u4
  - id: num_normal_blocks
    type: u4
  - id: num_texcoords
    type: u4
  - id: num_indexes
    type: u4
  - id: num_vertex_components
    type: u4
  - id: num_morph_components
    type: u4
  - id: unused
    contents: [0, 0, 0, 0]
  - id: render_group
    type: u4
  - id: texture_index
    type: u4
  - id: center
    type: vec3
    doc: Center of mesh
    repeat: expr
    repeat-expr: 8
  - id: aabb_min
    type: vec3
    doc: AABB point of mesh
    repeat: expr
    repeat-expr: 8
  - id: aabb_max
    type: vec3
    doc: AABB point of mesh
    repeat: expr
    repeat-expr: 8
  - id: bounding_radius
    type: f4
    repeat: expr
    repeat-expr: 8
  - id: vertex_blocks
    type: vertex_block
    doc: Blocks of raw vertex data
    repeat: expr
    repeat-expr: 8
  - id: normal_blocks
    type: vec4x4
    doc: Packed normal data
    repeat: expr
    repeat-expr: num_normal_blocks
  - id: texcoord_array
    type: vec2
    repeat: expr
    repeat-expr: num_texcoords
  - id: triangles
    type: triangle
    repeat: expr
    repeat-expr: num_indexes / 3
  - id: vertex_components_array
    type: vertex_component
    repeat: expr
    repeat-expr: num_vertex_components
  - id: morph_components_array
    type: morph_component
    repeat: expr
    repeat-expr: num_morph_components
types:
  triangle:
    seq:
      - id: index
        type: u2
        repeat: expr
        repeat-expr: 3
  morph_component:
    seq:
      - id: morph_index
        type: u2
      - id: vertex_index
        type: u2
  vertex_component:
    seq:
      - id: position_index
        type: u2
      - id: normal_index
        type: u2
      - id: texture_index
        type: u2
  vec2:
    doc: 2d vector
    seq:
      - id: u
        type: f4
        doc: u axis
      - id: v
        type: f4
        doc: v axis
  vec3:
    doc: 3d vector
    seq:
      - id: x
        type: f4
        doc: x axis
      - id: y
        type: f4
        doc: y axis
      - id: z
        type: f4
        doc: z axis
  vec3x4:
    doc: 3d vector with 4 values per axis
    seq:
      - id: x
        type: f4
        repeat: expr
        repeat-expr: 4
      - id: y
        type: f4
        repeat: expr
        repeat-expr: 4
      - id: z
        type: f4
        repeat: expr
        repeat-expr: 4
  vertex_block:
    doc: Vertex raw block
    seq:
      - id: block
        type: vec3x4
        repeat: expr
        repeat-expr: _root.num_vertex_blocks
  vec4x4:
    doc: 4d vector with 4 values per axis
    seq:
      - id: x
        type: f4
        repeat: expr
        repeat-expr: 4
      - id: y
        type: f4
        repeat: expr
        repeat-expr: 4
      - id: z
        type: f4
        repeat: expr
        repeat-expr: 4
      - id: w
        type: f4
        repeat: expr
        repeat-expr: 4
