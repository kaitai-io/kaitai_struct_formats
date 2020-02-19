meta:
  id: navmesh
  file-extension: bin
  endian: le
seq:
  - id: header
    type: navmesh_set_header
  - id: tiles
    type: navmesh_tile
    repeat: expr
    repeat-expr: header.num_tiles
types:
  navmesh_set_header:
    seq:
      - id: magic
        contents: "TESM"
      - id: version
        type: s4
      - id: num_tiles
        type: s4
      - id: params
        type: dt_navmesh_params
  dt_navmesh_params:
    seq:
      - id: orig
        type: float3
      - id: tile_width
        type: f4
      - id: tile_height
        type: f4
      - id: max_tiles
        type: s4
      - id: max_polys
        type: s4
  float3:
    seq:
      - id: x
        type: f4
      - id: y
        type: f4
      - id: z
        type: f4
  dt_tile_ref:
    seq:
      - id: ref
        type: u4
  navmesh_tile_header:
    seq:
      - id: tile_ref
        type: dt_tile_ref
      - id: data_size
        type: s4
  dt_mesh_tile_header:
    seq:
      - id: magic
        contents: "VAND"
      - id: version
        type: s4
      - id: x
        type: s4
      - id: y
        type: s4
      - id: layer
        type: s4
      - id: user_id
        type: u4
      - id: poly_count
        type: s4
      - id: vert_count
        type: s4
      - id: max_link_count
        type: s4
      - id: detail_mesh_count
        type: s4
      - id: detail_vert_count
        type: s4
      - id: detail_tri_count
        type: s4
      - id: bv_node_count
        type: s4
      - id: off_mesh_con_count
        type: s4
      - id: off_mesh_base
        type: s4
      - id: walkable_height
        type: f4
      - id: walkable_radius
        type: f4
      - id: walkable_climb
        type: f4
      - id: bmin
        type: float3
      - id: bmax
        type: float3
      - id: bv_quant_factor
        type: f4
  dt_poly:
    seq:
      - id: first_link
        type: u4
      - id: verts
        type: u2
        repeat: expr
        repeat-expr: 6
      - id: neis
        type: u2
        repeat: expr
        repeat-expr: 6
      - id: flags
        type: u2
      - id: vert_count
        type: u1
      - id: area_and_type
        type: u1
  dt_link:
    seq:
      - id: ref
        type: dt_tile_ref
      - id: next
        type: u4
      - id: edge
        type: u1
      - id: size
        type: u1
      - id: bmin
        type: u1
      - id: bmax
        type: u1
  dt_poly_detail:
    seq:
      - id: vert_base
        type: u4
      - id: tri_base
        type: u4
      - id: vert_count
        type: u1
      - id: tri_count
        type: u1
      - id: align_padding
        size: 2
  dt_bv_node:
    seq:
      - id: bmin
        type: u2
        repeat: expr
        repeat-expr: 3
      - id: bmax
        type: u2
        repeat: expr
        repeat-expr: 3
      - id: i
        type: s4
  dt_off_mesh_connection:
    seq:
      - id: pos
        type: float3
        repeat: expr
        repeat-expr: 2
      - id: rad
        type: f4
      - id: poly
        type: u2
      - id: flags
        type: u1
      - id: side
        type: u1
      - id: usrr_id
        type: u4
  dt_mesh_tile:
    seq:
      - id: header
        type: dt_mesh_tile_header
      - id: verts
        type: f4
        repeat: expr
        repeat-expr: header.vert_count*3
      - id: polys
        type: dt_poly
        repeat: expr
        repeat-expr: header.poly_count
      - id: links
        type: dt_link
        repeat: expr
        repeat-expr: header.max_link_count
      - id: detail_meshes
        type: dt_poly_detail
        repeat: expr
        repeat-expr: header.detail_mesh_count
      - id: detail_verts
        type: f4
        repeat: expr
        repeat-expr: header.detail_vert_count*3
      - id: detail_tris
        type: u1
        repeat: expr
        repeat-expr: header.detail_tri_count*4
      - id: bv_tree
        type: dt_bv_node
        repeat: expr
        repeat-expr: header.bv_node_count
      - id: off_mesh_cons
        type: dt_off_mesh_connection
        repeat: expr
        repeat-expr: header.off_mesh_con_count
  navmesh_tile:
    seq:
      - id: tile_header
        type: navmesh_tile_header
      - id: dt_mesh_tile
        type: dt_mesh_tile