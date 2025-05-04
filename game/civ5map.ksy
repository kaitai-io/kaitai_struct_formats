meta:
  id: civ5map
  application: Sid Meier's Civilization V
  file-extension: civ5map
  encoding: UTF-8
  license: CC0-1.0
  endian: le
  xref:
    wikidata: Q2385
doc: |
  Many of Civilization 5's maps are in civ5map format, and encodes terrain and
  sometimes resources on the map plots. Scenario data is also encoded in some
  civ5map files, although this does not currently parse such data.

  Civ5maps can be accompanied by lua files which defines advanced behavior for
  world gen on top of what's already in the civ5map.

  There are three versions of the format identified in this file- Pre-B (e.g. 7
  and A), B, and C. The latest version of Civ can read all of them. Pre-B is
  the base version. Version B has some additional information about the map in
  the header (string3). Version C is the only one I've seen that has a mod_data
  length greater than 0.

  Examples of official Firaxis maps with these versions...
  Pre-B (7) - <Civ 5 Install Location>/steamassets/assets/maps/asia.civ5map
  B - <Civ 5 Install Location>/steamassets/assets/maps/m_ancientlake.civ5map
  C - <Civ 5 Install Location>/steamassets/assets/maps/earth_duel.civ5map
doc-ref: https://forums.civfanatics.com/threads/civ5map-file-format.418566/
seq:
  - id: header
    type: header
  - id: mapdata
    type: mapdata
types:
  header:
    seq:
      - id: has_scenario_data
        type: b4
      - id: version
        type: b4
        
      - id: width
        type: u4
      - id: height
        type: u4
      - id: players
        size: 1
        
      - id: misc_settings_head
        type: b5
        doc: 5 empty bits + 3 bits of settings = 8 bits (1 byte)
      - id: random_goodies
        type: b1
      - id: random_resources
        type: b1
      - id: world_wrap
        type: b1
      - id: misc_settings_tail
        size: 3
        doc: Empty as far as I can tell. I wonder why it's 3 bytes long?
        
      - id: terrain_list_len
        type: u4
      - id: feature1_list_len
        type: u4
      - id: feature2_list_len
        type: u4
      - id: resource_list_len
        type: u4
        
      - id: mod_data_len
        type: u4
        
      - id: map_name_len
        type: u4
      - id: map_description_len
        type: u4
        
      - id: terrain_list
        type: null_terminated_str
        size: terrain_list_len
      - id: feature1_list
        type: null_terminated_str
        size: feature1_list_len  
      - id: feature2_list
        type: null_terminated_str
        size: feature2_list_len
      - id: resource_list
        type: null_terminated_str
        size: resource_list_len
        
      - id: mod_data
        size: mod_data_len
        
      - id: map_name
        type: str
        size: map_name_len
      - id: map_description
        type: str
        size: map_description_len
        
      - id: string3_len
        type: u4
        if: version >= 0xB
      - id: string3
        type: str
        size: string3_len
        if: version >= 0xB
        
    types:
      null_terminated_str:
        seq:
          - id: values
            type: strz
            repeat: eos

  mapdata:
    seq:
      - id: plot_matrix
        type: plot_row
        repeat: expr
        repeat-expr: _root.header.height
  
    types:
      plot_row:
        seq:
          - id: plot_list
            type: plot
            repeat: expr
            repeat-expr: _root.header.width
      plot:
        doc: |
          whatever_type_id is an index into the corresponding list in 
          the header. With the exception of terrain, it can be 0xFF,
          which represents nonetype.
        seq:
          - id: terrain_type_id
            type: u1
          - id: resource_type_id
            type: u1
          - id: feature1_type_id
            type: u1
          - id: river
            type: river
            doc: if the whole byte is 0, then there's no river
          - id: elevation
            type: u1
            enum: elevation
          - id: continent
            enum: continent
            type: u1
          - id: feature2_type_id
            type: u1
          - id: resource_amount
            type: u1
        types:
          river:
            doc: |
              Represents rivers defined by a tile's hex. Rivers are
              defined by edges of hexes.
                  /\
                 |  | East
                  \/
                SW  SE
              Because hexes tesselate, defining only SW-SE-E edges
              of the rivers can define rivers for all valid river spots.
            seq:
              - id: unknown
                type: b5
                doc: Unknown, but it will be 0 if no river
              - id: southwest_edge
                type: b1
              - id: southeast_edge
                type: b1
              - id: east_edge
                type: b1
        enums:
          elevation:
            0: none
            1: hill
            2: mountain
          continent:
            0: none
            1: americas
            2: asia
            3: africa
            4: europe