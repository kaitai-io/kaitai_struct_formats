meta:
  id: doom_wad
  application: id Tech 1
  file-extension: wad
  xref:
    justsolve: Doom_WAD
    mime: application/x-doom
    wikidata: Q1936828
  license: CC0-1.0
  endian: le
seq:
  - id: magic
    type: str
    size: 4
    encoding: ASCII
  - id: num_index_entries
    type: s4
    doc: Number of entries in the lump index
  - id: index_offset
    type: s4
    doc: Offset to the start of the index
types:
  index_entry:
    seq:
      - id: offset
        type: s4
      - id: size
        type: s4
      - id: name
        type: str
        size: 8
        encoding: ASCII
        pad-right: 0
    instances:
      contents:
        io: _root._io
        pos: offset
        size: size
        type:
          switch-on: name
          cases:
            '"THINGS"': things
            '"LINEDEFS"': linedefs
            '"SIDEDEFS"': sidedefs
            '"VERTEXES"': vertexes
            '"BLOCKMAP"': blockmap
            '"SECTORS"': sectors
            '"TEXTURE1"': texture12
            '"TEXTURE2"': texture12
            '"PNAMES"': pnames
  things:
    seq:
      - id: entries
        type: thing
        repeat: eos
  thing:
    seq:
      - id: x
        type: s2
      - id: y
        type: s2
      - id: angle
        type: u2
      - id: type
        type: u2
      - id: flags
        type: u2
  linedefs:
    seq:
      - id: entries
        type: linedef
        repeat: eos
  linedef:
    seq:
      - id: vertex_start_idx
        type: u2
      - id: vertex_end_idx
        type: u2
      - id: flags
        type: u2
      - id: line_type
        type: u2
      - id: sector_tag
        type: u2
      - id: sidedef_right_idx
        type: u2
      - id: sidedef_left_idx
        type: u2
  sidedefs:
    seq:
      - id: entries
        type: sidedef
        repeat: eos
  sidedef:
    seq:
      - id: offset_x
        type: s2
      - id: offset_y
        type: s2
      - id: upper_texture_name
        type: str
        size: 8
        encoding: ASCII
      - id: lower_texture_name
        type: str
        size: 8
        encoding: ASCII
      - id: normal_texture_name
        type: str
        size: 8
        encoding: ASCII
      - id: sector_id
        type: s2
  vertexes:
    seq:
      - id: entries
        type: vertex
        repeat: eos
  vertex:
    seq:
      - id: x
        type: s2
      - id: y
        type: s2
  blockmap:
    seq:
      - id: origin_x
        type: s2
        doc: Grid origin, X coord
      - id: origin_y
        type: s2
        doc: Grid origin, Y coord
      - id: num_cols
        type: s2
        doc: Number of columns
      - id: num_rows
        type: s2
        doc: Number of rows
      - id: linedefs_in_block
        type: blocklist
        repeat: expr
        repeat-expr: num_cols * num_rows
        doc: Lists of linedefs for every block
    types:
      blocklist:
        seq:
          - id: offset
            type: u2
            doc: Offset to the list of linedefs
        instances:
          linedefs:
            pos: offset * 2
            type: s2
            repeat: until
            repeat-until: _ == -1
            doc: List of linedefs found in this block
  sectors:
    seq:
      - id: entries
        type: sector
        repeat: eos
  sector:
    seq:
      - id: floor_z
        type: s2
      - id: ceil_z
        type: s2
      - id: floor_flat
        type: str
        size: 8
        encoding: ASCII
      - id: ceil_flat
        type: str
        size: 8
        encoding: ASCII
      - id: light
        type: s2
        doc: |
          Light level of the sector [0..255]. Original engine uses
          COLORMAP to render lighting, so only 32 actual levels are
          available (i.e. 0..7, 8..15, etc).
      - id: special_type
        type: u2
        enum: special_sector
      - id: tag
        type: u2
        doc: |
          Tag number. When the linedef with the same tag number is
          activated, some effect will be triggered in this sector.
    enums:
      special_sector:
        0: normal
        1: d_light_flicker
        2: d_light_strobe_fast
        3: d_light_strobe_slow
        4: d_light_strobe_hurt
        5: d_damage_hellslime
        7: d_damage_nukage
        8: d_light_glow
        9: secret
        10: d_sector_door_close_in_30
        11: d_damage_end
        12: d_light_strobe_slow_sync
        13: d_light_strobe_fast_sync
        14: d_sector_door_raise_in_5_mins
        15: d_friction_low
        16: d_damage_super_hellslime
        17: d_light_fire_flicker
        18: d_damage_lava_wimpy
        19: d_damage_lava_hefty
        20: d_scroll_east_lava_damage
        21: light_phased
        22: light_sequence_start
        23: light_sequence_special1
        24: light_sequence_special2
  texture12:
    doc: |
      Used for TEXTURE1 and TEXTURE2 lumps, which designate how to
      combine wall patches to make wall textures. This essentially
      provides a very simple form of image compression, allowing
      certain elements ("patches") to be reused / recombined on
      different textures for more variety in the game.
    doc-ref: http://doom.wikia.com/wiki/TEXTURE1
    seq:
      - id: num_textures
        type: s4
        doc: Number of wall textures
      - id: textures
        type: texture_index
        repeat: expr
        repeat-expr: num_textures
    types:
      texture_index:
        seq:
          - id: offset
            type: s4
        instances:
          body:
            pos: offset
            type: texture_body
      texture_body:
        -orig-id: maptexture_t
        seq:
          - id: name
            type: str
            size: 8
            pad-right: 0
            encoding: ASCII
            doc: Name of a texture, only `A-Z`, `0-9`, `[]_-` are valid
          - id: masked
            type: u4
          - id: width
            type: u2
          - id: height
            type: u2
          - id: column_directory
            type: u4
            doc: Obsolete, ignored by all DOOM versions
          - id: num_patches
            type: u2
            doc: Number of patches that are used in a texture
          - id: patches
            type: patch
            repeat: expr
            repeat-expr: num_patches
      patch:
        -orig-id: mappatch_t
        seq:
          - id: origin_x
            type: s2
            doc: X offset to draw a patch at (pixels from left boundary of a texture)
          - id: origin_y
            type: s2
            doc: Y offset to draw a patch at (pixels from upper boundary of a texture)
          - id: patch_id
            type: u2
            doc: Identifier of a patch (as listed in PNAMES lump) to draw
          - id: step_dir
            type: u2
          - id: colormap
            type: u2
  pnames:
    doc-ref: http://doom.wikia.com/wiki/PNAMES
    seq:
      - id: num_patches
        type: u4
        doc: Number of patches registered in this global game directory
      - id: names
        type: str
        size: 8
        encoding: ASCII
        pad-right: 0
        repeat: expr
        repeat-expr: num_patches
instances:
  index:
    pos: index_offset
    type: index_entry
    repeat: expr
    repeat-expr: num_index_entries
