meta:
  id: renderware_binary_stream
  title: RenderWare binary stream
  application: Games based on RenderWare engine (Grand Theft Auto 3D series)
  xref:
    wikidata: Q29960668
  endian: le
doc-ref: https://gtamods.com/wiki/RenderWare_binary_stream_file
seq:
  - id: code
    type: u4
    enum: sections
  - id: size
    type: u4
  - id: library_id_stamp
    type: u4
  - id: body
    size: size
    type:
      switch-on: code
      cases:
        sections::clump: list_with_header
        sections::frame_list: list_with_header
        sections::geometry: list_with_header
        sections::geometry_list: list_with_header
        sections::texture_dictionary: list_with_header
        sections::texture_native: list_with_header
instances:
  version:
    value: 'library_id_stamp & 0xFFFF0000 != 0 ? (library_id_stamp >> 14 & 0x3FF00) + 0x30000 | (library_id_stamp >> 16 & 0x3F) : library_id_stamp << 8'
types:
  list_with_header:
    doc: |
      Typical structure used by many data types in RenderWare binary
      stream. Substream contains a list of binary stream entries,
      first entry always has type "struct" and carries some specific
      binary data it in, determined by the type of parent. All other
      entries, beside the first one, are normal, self-describing
      records.
    seq:
      - id: code
        contents: [1, 0, 0, 0]
      - id: header_size
        type: u4
      - id: library_id_stamp
        type: u4
      - id: header
        size: header_size
        type:
          switch-on: _parent.code
          cases:
            sections::clump: struct_clump
            sections::frame_list: struct_frame_list
            sections::geometry: struct_geometry
            sections::geometry_list: struct_geometry_list
            sections::texture_dictionary: struct_texture_dictionary
      - id: entries
        type: renderware_binary_stream
        repeat: eos
    instances:
      version:
        value: 'library_id_stamp & 0xFFFF0000 != 0 ? (library_id_stamp >> 14 & 0x3FF00) + 0x30000 | (library_id_stamp >> 16 & 0x3F) : library_id_stamp << 8'
  struct_texture_dictionary:
    seq:
      - id: num_textures
        type: u4
  struct_clump:
    doc-ref: https://gtamods.com/wiki/RpClump
    seq:
      - id: num_atomics
        type: u4
      - id: num_lights
        type: u4
        if: _parent.version >= 0x33000
      - id: num_cameras
        type: u4
        if: _parent.version >= 0x33000
  struct_frame_list:
    doc-ref: 'https://gtamods.com/wiki/Frame_List_(RW_Section)#Structure'
    seq:
      - id: num_frames
        type: u4
      - id: frames
        type: frame
        repeat: expr
        repeat-expr: num_frames
  frame:
    doc-ref: 'https://gtamods.com/wiki/Frame_List_(RW_Section)#Structure'
    seq:
      - id: rotation_matrix
        type: matrix
      - id: position
        type: vector_3d
      - id: cur_frame_idx
        type: s4
      - id: matrix_creation_flags
        type: u4
  matrix:
    doc-ref: 'https://gtamods.com/wiki/Frame_List_(RW_Section)#Structure'
    seq:
      - id: entries
        type: vector_3d
        repeat: expr
        repeat-expr: 3
  vector_3d:
    doc-ref: 'https://gtamods.com/wiki/Frame_List_(RW_Section)#Structure'
    seq:
      - id: x
        type: f4
      - id: y
        type: f4
      - id: z
        type: f4
  struct_geometry_list:
    doc-ref: 'https://gtamods.com/wiki/Geometry_List_(RW_Section)#Structure'
    seq:
      - id: num_geometries
        type: u4
  struct_geometry:
    doc-ref: https://gtamods.com/wiki/RpGeometry
    seq:
      - id: format
        type: u4
      - id: num_triangles
        type: u4
      - id: num_vertices
        type: u4
      - id: num_morph_targets
        type: u4
      - id: surf_prop
        type: surface_properties
        if: _parent.version < 0x34000
      - id: geometry
        type: geometry_non_native
        if: not is_native
      - id: morph_targets
        type: morph_target
        repeat: expr
        repeat-expr: num_morph_targets
    instances:
      is_textured:
        value: format & 0x00000004 != 0
      is_prelit:
        value: format & 0x00000008 != 0
      is_textured2:
        value: format & 0x00000080 != 0
      is_native:
        value: format & 0x01000000 != 0
  surface_properties:
    doc-ref: https://gtamods.com/wiki/RpGeometry
    seq:
      - id: ambient
        type: f4
      - id: specular
        type: f4
      - id: diffuse
        type: f4
  geometry_non_native:
    seq:
      - id: prelit_colors
        type: rgba
        repeat: expr
        repeat-expr: _parent.num_vertices
        if: _parent.is_prelit
      - id: tex_coords
        type: tex_coord
        repeat: expr
        repeat-expr: _parent.num_vertices
        if: _parent.is_textured or _parent.is_textured2
        # FIXME: repeated for number of texture sets
      - id: triangles
        type: triangle
        repeat: expr
        repeat-expr: _parent.num_triangles
  rgba:
    seq:
      - id: r
        type: u1
      - id: g
        type: u1
      - id: b
        type: u1
      - id: a
        type: u1
  tex_coord:
    seq:
      - id: u
        type: f4
      - id: v
        type: f4
  triangle:
    seq:
      - id: vertex2
        type: u2
      - id: vertex1
        type: u2
      - id: material_id
        type: u2
      - id: vertex3
        type: u2
  morph_target:
    seq:
      - id: bounding_sphere
        type: sphere
      - id: has_vertices
        type: u4
      - id: has_normals
        type: u4
      - id: vertices
        repeat: expr
        repeat-expr: _parent.num_vertices
        type: vector_3d
        if: has_vertices != 0
      - id: normals
        repeat: expr
        repeat-expr: _parent.num_vertices
        type: vector_3d
        if: has_normals != 0
  sphere:
    seq:
      - id: x
        type: f4
      - id: y
        type: f4
      - id: z
        type: f4
      - id: radius
        type: f4
enums:
  sections:
    0x0001: struct
    0x0002: string
    0x0003: extension
    0x0005: camera
    0x0006: texture
    0x0007: material
    0x0008: material_list
    0x0009: atomic_section
    0x000a: plane_section
    0x000b: world
    0x000c: spline
    0x000d: matrix
    0x000e: frame_list
    0x000f: geometry
    0x0010: clump
    0x0012: light
    0x0013: unicode_string
    0x0014: atomic
    0x0015: texture_native
    0x0016: texture_dictionary
    0x0017: animation_database
    0x0018: image
    0x0019: skin_animation
    0x001a: geometry_list
    0x001b: anim_animation
    0x001c: team
    0x001d: crowd
    0x001e: delta_morph_animation
    0x001f: right_to_render
    0x0020: multitexture_effect_native
    0x0021: multitexture_effect_dictionary
    0x0022: team_dictionary
    0x0023: platform_independent_texture_dictionary
    0x0024: table_of_contents
    0x0025: particle_standard_global_data
    0x0026: altpipe
    0x0027: platform_independent_peds
    0x0028: patch_mesh
    0x0029: chunk_group_start
    0x002a: chunk_group_end
    0x002b: uv_animation_dictionary
    0x002c: coll_tree
    0x0101: metrics_plg
    0x0102: spline_plg
    0x0103: stereo_plg
    0x0104: vrml_plg
    0x0105: morph_plg
    0x0106: pvs_plg
    0x0107: memory_leak_plg
    0x0108: animation_plg
    0x0109: gloss_plg
    0x010a: logo_plg
    0x010b: memory_info_plg
    0x010c: random_plg
    0x010d: png_image_plg
    0x010e: bone_plg
    0x010f: vrml_anim_plg
    0x0110: sky_mipmap_val
    0x0111: mrm_plg
    0x0112: lod_atomic_plg
    0x0113: me_plg
    0x0114: lightmap_plg
    0x0115: refine_plg
    0x0116: skin_plg
    0x0117: label_plg
    0x0118: particles_plg
    0x0119: geomtx_plg
    0x011a: synth_core_plg
    0x011b: stqpp_plg
    0x011c: part_pp_plg
    0x011d: collision_plg
    0x011e: hanim_plg
    0x011f: user_data_plg
    0x0120: material_effects_plg
    0x0121: particle_system_plg
    0x0122: delta_morph_plg
    0x0123: patch_plg
    0x0124: team_plg
    0x0125: crowd_pp_plg
    0x0126: mip_split_plg
    0x0127: anisotropy_plg
    0x0129: gcn_material_plg
    0x012a: geometric_pvs_plg
    0x012b: xbox_material_plg
    0x012c: multi_texture_plg
    0x012d: chain_plg
    0x012e: toon_plg
    0x012f: ptank_plg
    0x0130: particle_standard_plg
    0x0131: pds_plg
    0x0132: prtadv_plg
    0x0133: normal_map_plg
    0x0134: adc_plg
    0x0135: uv_animation_plg
    0x0180: character_set_plg
    0x0181: nohs_world_plg
    0x0182: import_util_plg
    0x0183: slerp_plg
    0x0184: optim_plg
    0x0185: tl_world_plg
    0x0186: database_plg
    0x0187: raytrace_plg
    0x0188: ray_plg
    0x0189: library_plg
    0x0190: plg_2d # 2D PLG
    0x0191: tile_render_plg
    0x0192: jpeg_image_plg
    0x0193: tga_image_plg
    0x0194: gif_image_plg
    0x0195: quat_plg
    0x0196: spline_pvs_plg
    0x0197: mipmap_plg
    0x0198: mipmapk_plg
    0x0199: font_2d # 2D Font
    0x019a: intersection_plg
    0x019b: tiff_image_plg
    0x019c: pick_plg
    0x019d: bmp_image_plg
    0x019e: ras_image_plg
    0x019f: skin_fx_plg
    0x01a0: vcat_plg
    0x01a1: path_2d
    0x01a2: brush_2d
    0x01a3: object_2d
    0x01a4: shape_2d
    0x01a5: scene_2d
    0x01a6: pick_region_2d
    0x01a7: object_string_2d
    0x01a8: animation_plg_2d
    0x01a9: animation_2d
    0x01b0: keyframe_2d
    0x01b1: maestro_2d
    0x01b2: barycentric
    0x01b3: platform_independent_texture_dictionary_tk
    0x01b4: toc_tk
    0x01b5: tpl_tk
    0x01b6: altpipe_tk
    0x01b7: animation_tk
    0x01b8: skin_split_tookit
    0x01b9: compressed_key_tk
    0x01ba: geometry_conditioning_plg
    0x01bb: wing_plg
    0x01bc: generic_pipeline_tk
    0x01bd: lightmap_conversion_tk
    0x01be: filesystem_plg
    0x01bf: dictionary_tk
    0x01c0: uv_animation_linear
    0x01c1: uv_animation_parameter
    0x0253f200: atomic_visibility_distance
    0x0253f201: clump_visibility_distance
    0x0253f202: frame_visibility_distance
    0x0253f2f3: pipeline_set
    0x0253f2f4: unused_5
    0x0253f2f5: texdictionary_link
    0x0253f2f6: specular_material
    0x0253f2f7: unused_8
    0x0253f2f8: effect_2d
    0x0253f2f9: extra_vert_colour
    0x0253f2fa: collision_model
    0x0253f2fb: gta_hanim
    0x0253f2fc: reflection_material
    0x0253f2fd: breakable
    0x0253f2fe: frame
    0x0253f2ff: unused_16
    0x050e: bin_mesh_plg
    0x0510: native_data_plg
    0xf21e: zmodeler_lock
