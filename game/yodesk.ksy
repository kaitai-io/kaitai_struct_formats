meta:
  id: yodesk
  application: "Star Wars: Yoda Stories"
  file-extension: dta
  license: CC0-1.0
  ks-version: 0.9
  endian: le
  encoding: ASCII
seq:
  - id: catalog
    type: catalog_entry
    repeat: until
    repeat-until: _.type == "ENDF"
types:
  catalog_entry:
    seq:
      - id: type
        type: str
        size: 4
      - id: size
        type: u4
        if: type != "VERS" and type != "ZONE"
      - id: content
        type:
          switch-on: type
          cases:
             '"VERS"': version
             '"STUP"': setup_image
             '"CHAR"': characters
             '"CAUX"': character_auxiliaries
             '"CHWP"': character_weapons
             '"PUZ2"': puzzles
             '"SNDS"': sounds
             '"TILE"': tiles
             '"TNAM"': tile_names
             '"ZONE"': zones
             '"ENDF"': endf
             _: unknown_catalog_entry
  unknown_catalog_entry:
    seq:
      - id: data
        size: _parent.size
  version:
    seq:
      - id: version
        type: u4
  setup_image:
    seq:
      - id: pixels
        size: _parent.size
  sounds:
    seq:
      - id: count
        type: s2
      - id: sounds
        type: prefixed_strz
        repeat: expr
        repeat-expr: -count
  tile_names:
    seq:
      - id: names
        type: tile_name
        repeat: until
        repeat-until:  _.tile_id == 0xFF_FF
  tile_name:
    seq:
      - id: tile_id
        type: u2
      - id: name
        type: strz
        size: 0x18
        if: tile_id != 0xFF_FF
  tiles:
    seq:
      - id: tiles
        type: tiles_entries
        size: _parent.size
  tiles_entries:
    seq:
      - id: tiles
        type: tile
        repeat: eos
  tile:
      seq:
        - id: attributes
          type: u4
        - id: pixels
          size: 32 * 32

  action:
    seq:
      - id: marker
        contents: "IACT"
      - id: size
        type: u4
      - id: condition_count
        type: u2
      - id: conditions
        type: condition
        repeat: expr
        repeat-expr: condition_count
      - id: instruction_count
        type: u2
      - id: instructions
        type: instruction
        repeat: expr
        repeat-expr: instruction_count
  condition:
    seq:
      - id: opcode
        type: u2
        enum: condition_opcode
      - id: arguments
        type: s2
        repeat: expr
        repeat-expr: 5
      - id: text_length
        type: u2
      - id: text
        type: str
        size: text_length
    enums:
      condition_opcode:
        0: zone_not_initialized
        1: zone_entered
        2: bump
        3: placed_item_is
        4: standing_on
        5: counter_is
        6: random_is
        7: random_is_greater_than
        8: random_is_less_than
        9: enter_by_plane
        10: tile_at_is
        11: monster_is_dead
        12: has_no_active_monsters
        13: has_item
        14: required_item_is
        15: ending_is
        16: zone_is_solved
        17: no_item_placed
        18: item_placed
        19: health_is_less_than
        20: health_is_greater_than
        21: unused
        22: find_item_is
        23: placed_item_is_not
        24: hero_is_at
        25: shared_counter_is
        26: shared_counter_is_less_than
        27: shared_counter_is_greater_than
        28: games_won_is
        29: drops_quest_item_at
        30: has_any_required_item
        31: counter_is_not
        32: random_is_not
        33: shared_counter_is_not
        34: is_variable
        35: games_won_is_greater_than
  instruction:
    seq:
      - id: opcode
        type: u2
        enum: instruction_opcode
      - id: arguments
        type: s2
        repeat: expr
        repeat-expr: 5
      - id: text_length
        type: u2
      - id: text
        type: str
        size: text_length
    enums:
      instruction_opcode:
        0: place_tile
        1: remove_tile
        2: move_tile
        3: draw_tile
        4: speak_hero
        5: speak_npc
        6: set_tile_needs_display
        7: set_rect_needs_display
        8: wait
        9: redraw
        10: play_sound
        11: stop_sound
        12: roll_dice
        13: set_counter
        14: add_to_counter
        15: set_variable
        16: hide_hero
        17: show_hero
        18: move_hero_to
        19: move_hero_by
        20: disable_action
        21: enable_hotspot
        22: disable_hotspot
        23: enable_monster
        24: disable_monster
        25: enable_all_monsters
        26: disable_all_monsters
        27: drop_item
        28: add_item
        29: remove_item
        30: mark_as_solved
        31: win_game
        32: lose_game
        33: change_zone
        34: set_shared_counter
        35: add_to_shared_counter
        36: set_random
        37: add_health
  monster:
    seq:
      - id: character
        type: u2
      - id: x
        type: u2
      - id: y
        type: u2
      - id: loot
        type: u2
      - id: drops_loot
        type: u4
      - id: waypoints
        type: waypoint
        repeat: expr
        repeat-expr: 4
  zone:
    seq:
      - id: planet
        type: u2
        enum: planet
      - id: size
        type: u4
      - id: index
        type: u2
      - id: marker
        contents: "IZON"
      - id: size2
        type: u4
      - id: width
        type: u2
      - id: height
        type: u2
      - id: type
        enum: zone_type
        type: u4
      - id: shared_counter
        type: u2
        valid: 0xFF_FF
      - id: planet_again
        type: u2
      - id: tile_ids
        type: zone_spot
        repeat: expr
        repeat-expr: width * height
        doc: |
          tile_ids is made up of three interleaved tile layers ordered from
          bottom (floor) to top (roof).
      - id: hotspot_count
        type: u2
      - id: hotspots
        type: hotspot
        repeat: expr
        repeat-expr: hotspot_count
      - id: izax
        type: zone_auxiliary
      - id: izx2
        type: zone_auxiliary_2
      - id: izx3
        type: zone_auxiliary_3
      - id: izx4
        type: zone_auxiliary_4
      - id: action_count
        type: u2
      - id: actions
        type: action
        repeat: expr
        repeat-expr: action_count
    enums:
      planet:
        0: none
        1: desert
        2: snow
        3: forest
        5: swamp
      zone_type:
        0: none
        1: empty
        2: blockade_north
        3: blockade_south
        4: blockade_east
        5: blockade_west
        6: travel_start
        7: travel_end
        8: room
        9: load
        10: goal
        11: town
        13: win
        14: lose
        15: trade
        16: use
        17: find
        18: find_unique_weapon
  zone_spot:
    seq:
      - id: column
        doc: from bottom to top, 0xFF FF indicates empty tiles
        type: u2
        repeat: expr
        repeat-expr: 3
  hotspot:
    seq:
      - id: type
        type: u4
        enum: hotspot_type
      - id: x
        type: u2
      - id: y
        type: u2
      - id: enabled
        type: u2
      - id: argument
        type: u2
    enums:
      hotspot_type:
        0: drop_quest_item
        1: spawn_location
        2: drop_unique_weapon
        3: vehicle_to
        4: vehicle_back
        5: drop_map
        6: drop_item
        7: npc
        8: drop_weapon
        9: door_in
        10: door_out
        11: unused
        12: lock
        13: teleporter
        14: ship_to_planet
        15: ship_from_planet
  zone_auxiliary:
    seq:
      - id: marker
        contents: "IZAX"
      - id: size
        type: u4
      - id: unknown_count
        type: u2
      - id: monster_count
        type: u2
      - id: monsters
        type: monster
        repeat: expr
        repeat-expr: monster_count
      - id: required_item_count
        type: u2
      - id: required_items
        type: u2
        repeat: expr
        repeat-expr: required_item_count
      - id: goal_item_count
        type: u2
      - id: goal_items
        type: u2
        repeat: expr
        repeat-expr: goal_item_count
  zone_auxiliary_2:
     seq:
      - id: marker
        contents: "IZX2"
      - id: size
        type: u4
      - id: provided_item_count
        type: u2
      - id: provided_items
        type: u2
        repeat: expr
        repeat-expr: provided_item_count

  zone_auxiliary_3:
     seq:
      - id: marker
        contents: "IZX3"
      - id: size
        type: u4
      - id: npc_count
        type: u2
      - id: npc
        type: u2
        repeat: expr
        repeat-expr: npc_count
  zone_auxiliary_4:
     seq:
      - id: marker
        contents: "IZX4"
      - id: size
        type: u4
      - id: unknown
        type: u2
  zones:
    seq:
      - id: zone_count
        type: u2
      - id: zones
        type: zone
        repeat: expr
        repeat-expr: zone_count
  puzzles:
    seq:
      - id: puzzles
        type: puzzle
        repeat: until
        repeat-until: _.index == 0xFF_FF
  puzzle:
    seq:
      - id: index
        type: u2
      - id: marker
        if: index != 0xFF_FF
        contents: "IPUZ"
      - id: size
        type: u4
        if: index != 0xFF_FF
      - id: type
        type: u4
        if: index != 0xFF_FF
      - id: unknown1
        type: u4
        if: index != 0xFF_FF
      - id: unknown2
        type: u4
        if: index != 0xFF_FF
      - id: unknown3
        type: u2
        if: index != 0xFF_FF
      - id: strings
        type: prefixed_str
        repeat: expr
        repeat-expr: 5
        if: index != 0xFF_FF
      - id: item_1
        type: u2
        if: index != 0xFF_FF
      - id: item_2
        type: u2
        if: index != 0xFF_FF
  endf:
    seq: []
  characters:
    seq:
      - id: characters
        type: character
        repeat: until
        repeat-until: _.index == 0xFF_FF
  character:
    seq:
      - id: index
        type: u2
      - id: marker
        contents: "ICHA"
        if: index != 0xFF_FF
      - id: size
        type: u4
        if: index != 0xFF_FF
      - id: name
        type: strz
        size: 16
        if: index != 0xFF_FF
      - id: type
        type: u2
        enum: character_type
        if: index != 0xFF_FF
      - id: movement_type
        type: u2
        enum: movement_type
        if: index != 0xFF_FF
      - id: probably_garbage_1
        type: u2
        if: index != 0xFF_FF
      - id: probably_garbage_2
        type: u4
        if: index != 0xFF_FF
      - id: frame_1
        type: char_frame
        if: index != 0xFF_FF
      - id: frame_2
        type: char_frame
        if: index != 0xFF_FF
      - id: frame_3
        type: char_frame
        if: index != 0xFF_FF
    enums:
      character_type:
        1: hero
        2: enemy
        4: weapon
      movement_type:
        0: none
        4: sit
        9: wander
        10: patrol
        12: animation
  char_frame:
    seq:
      - id: tiles
        type: u2
        repeat: expr
        repeat-expr: 0x8
  character_auxiliaries:
    seq:
      - id: auxiliaries
        type: character_auxiliary
        repeat: until
        repeat-until: _.index == 0xFF_FF
  character_auxiliary:
    seq:
      - id: index
        type: u2
      - id: damage
        type: s2
        if: index != 0xFF_FF
  character_weapons:
    seq:
      - id: weapons
        type: character_weapon
        repeat: until
        repeat-until: _.index == 0xFF_FF
  character_weapon:
    seq:
      - id: index
        type: u2
      - id: reference
        doc: |
          If character referenced by index is monster, this is a reference to
          their weapon, otherwise this is the index of the weapon's sound
        type: u2
        if: index != 0xFF_FF
      - id: health
        type: u2
        if: index != 0xFF_FF
  # Utilities
  prefixed_str:
    seq:
      - id: length
        type: u2
      - id: content
        type: str
        size: length
  prefixed_strz:
    seq:
      - id: length
        type: u2
      - id: content
        type: strz
        size: length
  waypoint:
    seq:
    - id: x
      type: u4
    - id: y
      type: u4
