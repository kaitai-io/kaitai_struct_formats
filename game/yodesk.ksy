  meta:
    id: yodesk
    application: "Star Wars: Yoda Stories"
    file-extension: dta
    license: CC0-1.0
    ks-version: 0.9
    endian: le
    encoding: ASCII
  doc: |
    [Star Wars: Yoda Stories](https://en.wikipedia.org/wiki/Star_Wars:_Yoda_Stories) is a unique tile based game with procedurally
    generated worlds.
    This spec describes the file format used for all assets of the windows
    version of the game.

    The file format follows the TLV (type-length-value) pattern to build a
    central catalog containing the most important (and globally accessible)
    assets of the game (e.g. puzzles, zones, tiles, etc.). The same pattern is
    also found in some catalog entries to encode arrays of variable-length
    structures.

    With every new game, Yoda Stories generates a new world. This is done by
    picking a random sample of puzzles from `PUZ2`. One of the chosen puzzles
    will be the goal, which when solved wins the game.
    Each puzzle provides an item when solved and some require one to be completed.
    During world generation a global world map of 10x10 sectors is filled with
    zones based on the selected puzzles.

    To add variety and interactivity to each zone the game includes a simple
    scripting engine. Zones can declare actions that when executed can for
    example set, move or delete tiles, drop items or activate enemies.

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
          doc: Version of the file. This value is always set to 512.
          type: u4
    setup_image:
      doc: |
        A 288x288 bitmap to be shown while other assets are loaded and a new
        world is generated.
      seq:
        - id: pixels
          size: _parent.size
    sounds:
      doc: |
        This section declares sounds used in the game. The actual audio data is
        stored in wav files on the disk (in a directory named `sfx`) so this
        section contains paths to each sound file.
        Sounds can be referenced from the scripting language (see `play_sound`
        instruction opcode below) and from weapon (see `character` structure).
        Some sound ids (like the one when the hero is hit, or can't leave a
        zone) are hard coded in the game.
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
          doc: |
            List of tile ids and their corresponding names. These are shown in
            the inventory or used in dialogs (see `speak_hero` and `speak_npc`
            opcodes).
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
            doc: |
              Bit mask of various tile attributes. Most bits are purely
              informational and do not have any effect on game play.

              Their meaning is as follows:
               * Bit 0: Affects how tile image should be drawn. If set, the
                        value 0 in `pixels` is treated as transparent. Otherwise
                        it is drawn as black.
               * Bit 1: Floor, tile is usually placed on the lowest layer of a
                        zone
               * Bit 2: Object, tile is usually placed on the middle layer of a
                        zone
               * Bit 3: If set and the tile is placed on the object layer it can
                        be dragged and pushed around by the hero.
               * Bit 4: Tile is usually placed on the top layer (roof)

              Bits 5 - 8 declare a sub type and influence the meaning of the
              remaining bits:
                * Bit 5: Locator, tile is used in world map view overview
                * Bit 6: Identifies tiles that are mapped to weapons
                * Bit 7: Item
                * Bit 8: Character

              If the `locator` bit is set, bits 17 - 31 uniquely identify the
              tiles used to draw the map view. It's unclear whether the games
              uses this to find the tiles or if the tile ids are just hard
              coded.

              If bit 7 is set, bits 16 - 22 are used to determine the hints
              shown in map view.
              They are defined as follows:
               * Bit 16: Key card
               * Bit 17: Tool
               * Bit 18: Part
               * Bit 19: Valuable
               * Bit 20: Locator
               * Bit 21: unused
               * Bit 22: Consumable

              For tiles marked as characters (bit 8), bits 16 - 18 are defined
              as follows:
               * Bit 16: Hero
               * Bit 17: Enemy, tiles without this flag can not be hit by the
                         hero
               * Bit 18: NPC
            type: u4
          - id: pixels
            size: 32 * 32
    action:
      doc: |
        Actions are the game's way to make static tile based maps more engaging and interactive. Each action consists of zero or more conditions and instructions, once all conditions are satisfied, all instructions are executed in order.

        To facilitate state, each zone has three 16-bit registers. These registers are named `counter`, `shared-counter` and `random`. In addition to these registers hidden tiles are sometimes used to mark state.
        There are conditions and instructions to query and update these registers. The `shared-counter` register is special in that it is shared between a zone and it's rooms. Instruction `0xc` roll_dice can be used to set the `random` register to a random value.

        A naive implementation of the scripting engine could look like this:

        ```
        for action in zone.actions:
          all_conditions_statisfied = False
          for condition in action.conditions:
              all_conditions_statisfied = check(condition)
              if !all_conditions_statisfied:
                break

          if !all_conditions_statisfied:
            continue

          for instruction in action.instructions:
            execute(instruction)
        ```

        See `condition_opcode` and `instruction_opcode` enums for a list of
        available opcodes and their meanings.
      seq:
        - id: marker
          contents: "IACT"
        - id: size
          type: u4
        - id: num_conditions
          type: u2
        - id: conditions
          type: condition
          repeat: expr
          repeat-expr: num_conditions
        - id: num_instructions
          type: u2
        - id: instructions
          type: instruction
          repeat: expr
          repeat-expr: num_instructions
    condition:
      seq:
        - id: opcode
          type: u2
          enum: condition_opcode
        - id: arguments
          type: s2
          repeat: expr
          repeat-expr: 5
        - id: len_text
          type: u2
        - id: text
          type: str
          size: len_text
          doc: |
            The `text_attribute` is never used, but seems to be included to
            shared the type with instructions.
      enums:
        condition_opcode:
          0x0:
            id:  zone_not_initialised
            doc: Evaluates to true exactly once (used for initialisation)
          0x1:
            id:  zone_entered
            doc: Evaluates to true if hero just entered the zone
          0x2:
            id:  bump
          0x3:
            id:  placed_item_is
          0x4:
            id:  standing_on
            doc: |
              Check if hero is at `args[0]`x`args[1]` and the floor tile is
              `args[2]`
          0x5:
            id:  counter_is
            doc: Current zone's `counter` value is equal to `args[0]`
          0x6:
            id:  random_is
            doc: Current zone's `random` value is equal to `args[0]`
          0x7:
            id:  random_is_greater_than
            doc: Current zone's `random` value is greater than `args[0]`
          0x8:
            id:  random_is_less_than
            doc: Current zone's `random` value is less than `args[0]`
          0x9:
            id:  enter_by_plane
          0xa:
            id:  tile_at_is
            doc: |
              Check if tile at `args[0]`x`args[1]`x`args[2]` is equal to
              `args[3]`
          0xb:
            id:  monster_is_dead
            doc: True if monster `args[0]` is dead.
          0xc:
            id:  has_no_active_monsters
            doc: undefined
          0xd:
            id:  has_item
            doc: |
              True if inventory contains `args[0]`.  If `args[0]` is `0xFFFF`
              check if inventory contains the item provided by the current
              zone's puzzle
          0xe:
            id:  required_item_is
          0xf:
            id:  ending_is
            doc: True if `args[0]` is equal to current goal item id
          0x10:
            id:  zone_is_solved
            doc: True if the current zone is solved
          0x11:
            id:  no_item_placed
            doc: Returns true if the user did not place an item
          0x12:
            id:  item_placed
            doc: Returns true if the user placed an item
          0x13:
            id:  health_is_less_than
            doc: Hero's health is less than `args[0]`.
          0x14:
            id:  health_is_greater_than
            doc: Hero's health is greater than `args[0]`.
          0x15: unused
          0x16:
            id:  find_item_is
            doc: True the item provided by current zone is `args[0]`
          0x17:
            id:  placed_item_is_not
          0x18:
            id:  hero_is_at
            doc: True if hero's x/y position is `args_0`x`args_1`.
          0x19:
            id:  shared_counter_is
            doc: Current zone's `shared_counter` value is equal to `args[0]`
          0x1a:
            id:  shared_counter_is_less_than
            doc: Current zone's `shared_counter` value is less than `args[0]`
          0x1b:
            id:  shared_counter_is_greater_than
            doc: Current zone's `shared_counter` value is greater than `args[0]`
          0x1c:
            id:  games_won_is
            doc: Total games won is equal to `args[0]`
          0x1d:
            id:  drops_quest_item_at
          0x1e:
            id:  has_any_required_item
            doc: |
              Determines if inventory contains any of the required items needed
              for current zone
          0x1f:
            id:  counter_is_not
            doc: Current zone's `counter` value is not equal to `args[0]`
          0x20:
            id:  random_is_not
            doc: Current zone's `random` value is not equal to `args[0]`
          0x21:
            id:  shared_counter_is_not
            doc: Current zone's `shared_counter` value is not equal to `args[0]`
          0x22:
            id:  is_variable
            doc: |
              Check if variable identified by `args[0]`⊕`args[1]`⊕`args[2]` is
              set to `args[3]`. Internally this is implemented as opcode 0x0a,
              check if tile at `args[0]`x`args[1]`x`args[2]` is equal to
              `args[3]`
          0x23:
            id:  games_won_is_greater_than
            doc: True, if total games won is greater than `args[0]`

    instruction:
      seq:
        - id: opcode
          type: u2
          enum: instruction_opcode
        - id: arguments
          type: s2
          repeat: expr
          repeat-expr: 5
        - id: len_text
          type: u2
        - id: text
          type: str
          size: len_text
      enums:
        instruction_opcode:
          0x0:
            id:  place_tile
            doc: |
              Place tile `args[3]` at `args[0]`x`args[1]`x`args[2]`. To remove a
              tile `args[3]` can be set to `0xFFFF`.
          0x1:
            id:  remove_tile
            doc: Remove tile at `args[0]`x`args[1]`x`args[2]`
          0x2:
            id:  move_tile
            doc: |
              Move tile at `args[0]`x`args[0]`x`args[2]` to
              `args[3]`x`args[4]`x`args[2]`.  *Note that this can not be used to
              move tiles between layers!*
          0x3:
            id:  draw_tile
          0x4:
            id:  speak_hero
            doc: |
              Show speech bubble next to hero. _Uses `text` attribute_.

              Script execution is paused until the speech bubble is dismissed.
          0x5:
            id:  speak_npc
            doc: |
              Show speech bubble at `args[0]`x`args[1]`. _Uses `text`
              attribute_. The characters `¢` and `¥` are used as placeholders
              for provided and required items of the current zone, respectively.

              Script execution is paused until the speech bubble is dismissed.
          0x6:
            id:  set_tile_needs_display
            doc: Redraw tile at `args[0]`x`args[1]`
          0x7:
            id:  set_rect_needs_display
            doc: |
              Redraw the part of the current scene, specified by a rectangle
              positioned at `args[0]`x`args[1]` with width `args[2]` and height
              `args[3]`.
          0x8:
            id:  wait
            doc: Pause script execution for one tick.
          0x9:
            id:  redraw
            doc: Redraw the whole scene immediately
          0xa:
            id:  play_sound
            doc: Play sound specified by `args[0]`
          0xb:
            id:  stop_sound
            doc: Stop playing sounds
          0xc:
            id:  roll_dice
            doc: |
              Set current zone's `random` to a random value between 1 and
              `args[0]`.
          0xd:
            id:  set_counter
            doc: Set current zone's `counter` value to a `args[0]`
          0xe:
            id:  add_to_counter
            doc: Add `args[0]` to current zone's `counter` value
          0xf:
            id:  set_variable
            doc: |
              Set variable identified by `args[0]`⊕`args[1]`⊕`args[2]` to
              `args[3]`.  Internally this is implemented as opcode 0x00, setting
              tile at `args[0]`x`args[1]`x`args[2]` to `args[3]`.
          0x10:
            id:  hide_hero
            doc: Hide hero
          0x11:
            id:  show_hero
            doc: Show hero
          0x12:
            id: move_hero_to
            doc: |
              Set hero's position to `args[0]`x`args[1]` ignoring impassable
              tiles.  Execute hotspot actions, redraw the current scene and move
              camera if the hero is not hidden.
          0x13:
            id: move_hero_by
            doc: |
              Moves hero relative to the current location by `args[0]` in x and
              `args[1]` in y direction.
          0x14:
            id: disable_action
            doc: |
              Disable current action, note that there's no way to activate the
              action again.
          0x15:
            id: enable_hotspot
            doc: Enable hotspot `args[0]` so it can be triggered.
          0x16:
            id: disable_hotspot
            doc: Disable hotspot `args[0]` so it can't be triggered anymore.
          0x17:
            id:  enable_monster
            doc: Enable monster `args[0]`
          0x18:
            id: disable_monster
            doc: Disable monster `args[0]`
          0x19:
            id: enable_all_monsters
            doc: Enable all monsters
          0x1a:
            id: disable_all_monsters
            doc: Disable all monsters
          0x1b:
            id: drop_item
            doc: |
              Drops item `args[0]` for pickup at `args[1]`x`args[2]`. If the
              item is 0xFFFF, it drops the current sector's find item instead.

              Script execution is paused until the item is picked up.
          0x1c:
            id: add_item
            doc: Add tile with id `args[0]` to inventory
          0x1d:
            id: remove_item
            doc: Remove one instance of item `args[0]` from the inventory
          0x1e:
            id: mark_as_solved
            doc: |
              Marks current sector solved for the overview map.
          0x1f:
            id: win_game
            doc: Ends the current story by winning.
          0x20:
            id: lose_game
            doc: Ends the current story by losing.
          0x21:
            id: change_zone
            doc: |
              Change current zone to `args[0]`. Hero will be placed at
              `args[1]`x`args[2]` in the new zone.
          0x22:
            id:  set_shared_counter
            doc: Set current zone's `shared_counter` value to a `args[0]`
          0x23:
            id:  add_to_shared_counter
            doc: Add `args[0]` to current zone's `shared_counter` value
          0x24:
            id:  set_random
            doc: Set current zone's `random` value to a `args[0]`
          0x25:
            id:  add_health
            doc: |
              Increase hero's health by `args[0]`. New health is capped at
              hero's max health (0x300). Argument 0 can also be negative
              subtract from hero's health.
    monster:
      doc: A monster is a enemy in a zone.
      seq:
        - id: character
          type: u2
        - id: x
          type: u2
        - id: y
          type: u2
        - id: loot
          doc: |
            References the item (loot - 1) that will be dropped if the monster
            is killed. If set to `0xFFFF` the current zone's quest item will be
            dropped.
          type: u2
        - id: drops_loot
          doc: If this field is anything other than 0 the monster may drop an
            item when killed.
          type: u4
        - id: waypoints
          type: waypoint
          repeat: expr
          repeat-expr: 4
    zone:
      seq:
        - id: planet
          doc: |
            Planet this zone can be placed on.

            During world generation the goal puzzle dictates which planet is
            chosen. Apart from `swamp` zones, only the zones with type `empty`
            or the chosen type are loaded when a game is in progress.
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
          doc: Width of the zone in tiles. Either 9 or 18.
          type: u2
        - id: height
          doc: Height of the zone in tiles. Either 9 or 18.
          type: u2
        - id: type
          enum: zone_type
          type: u4
        - id: shared_counter
          doc: |
              Scripting register shared between the zone and its rooms.
          type: u2
          valid: 0xFF_FF
        - id: planet_again
          doc: Repetition of the `planet` field
          type: u2
        - id: tile_ids
          type: zone_spot
          repeat: expr
          repeat-expr: width * height
          doc: |
            `tile_ids` is made up of three interleaved tile layers ordered from
            bottom (floor) to top (roof).
            Tiles are often references via 3 coordinates (xyz), which
            corresponds to an index into this array calculated as `n = y * width
            * 3 + x * 3 = z`.
        - id: num_hotspots
          type: u2
        - id: hotspots
          type: hotspot
          repeat: expr
          repeat-expr: num_hotspots
        - id: izax
          type: zone_auxiliary
        - id: izx2
          type: zone_auxiliary_2
        - id: izx3
          type: zone_auxiliary_3
        - id: izx4
          type: zone_auxiliary_4
        - id: num_actions
          type: u2
        - id: actions
          type: action
          repeat: expr
          repeat-expr: num_actions
      enums:
        planet:
          0: none
          1: desert
          2: snow
          3: forest
          5: swamp
        zone_type:
          0:
            id: none
          1:
            id: empty
            doc: |
              Empty zones do not contain a puzzle to be solved and are used to
              fill the space between between zones that are relevant for winning
              the game.
          2:
            id: blockade_north
            doc: |
              This type of zone blocks access to sectors north of it until the
              puzzle is solved.
          3:
            id: blockade_south
            doc: |
              This type of zone blocks access to sectors south of it until the
              puzzle is solved.
          4:
            id: blockade_east
            doc: |
              This type of zone blocks access to sectors east of it until the
              puzzle is solved.
          5:
            id: blockade_west
            doc: |
              This type of zone blocks access to sectors west of it until the
              puzzle is solved.
          6:
            id: travel_start
            doc: |
              Starting point to travel to an island on the edge of the world.
              `travel_start` and `travel_end` zones are connected through
              hotspot of type `vehicle_to` and `vehicle_back`.
          7:
            id: travel_end
            doc: |
              Travel target that is only placed on an island at the edge of the
              world map during world generation.
          8:
            id: room
            doc: |
              A zone that can not be placed on the world map directly. Instead
              rooms are accessed via actions or hotspots of type `door_in`. They
              usually contain at least one `door_out` hotspot to get back to the
              other zone.
          9:
            id: load
            doc: |
              This type of zone is shown after the game has loaded all assets.
              It should resemble the image from the catalog entry of type
              `setup_image` for a smooth transition from loading to game play.
          10:
            id: goal
            doc: |
              Every world contains exactly one goal zone. Solving this zone wins
              the game.
          11:
            id: town
            doc: |
              This is the entry zone where the hero arrives after leaving the
              swamp planet. Each planet can only have one town zone.
          13:
            id: win
            doc: |
              Shown when a game is won. The score is rendered above the tiles at
              coordinates 5x7 and 6x7.
          14:
            id: lose
            doc: |
              Shown when a game is lost.
          15:
            id: trade
            doc: |
              In order to solve this zone and gain a new item the hero has to
              trade something in.
          16:
            id: use
            doc: |
              This type of zone can be solved by making applying a tool or using
              a keycard.
          17:
            id: find
            doc: |
              This type of zone can be solved without using items.
          18:
            id: find_unique_weapon
            doc: |
              This zone provides the hero with a unique weapon and will be
              placed closed to a town zone.
    zone_spot:
      seq:
        - id: column
          doc: from bottom to top, 0xFFFF indicates empty tiles
          type: u2
          repeat: expr
          repeat-expr: 3
    hotspot:
      doc: |
        In addition to actions some puzzles and events are triggered by
        hotspots. These hotspots are triggered when the hero steps on them or
        places an item at the location. Additionally, hotspots are used during
        world generation to mark places where NPCs can spawn.
      seq:
        - id: type
          type: u4
          enum: hotspot_type
        - id: x
          type: u2
        - id: y
          type: u2
        - id: enabled
          doc: |
            If disabled, hotspots can not be triggered. See instruction opcodes
            called `enable_hotspot` and `disable_hotspot`.
          type: u2
        - id: argument
          type: u2
      enums:
        hotspot_type:
          0:
            id: drop_quest_item
            doc: |
              Drops the item provided by the zone when solved. Can be set to a
              specific item, or to `0xFFFF` to use the one from the currently
              assigned puzzle.
          1:
            id: spawn_location
            doc: |
              Possible spawn location for one of the zone's NPCs.
          2:
            id: drop_unique_weapon
            doc: |
              Hotspot that drops the unique weapon found in zones of type
              `find_unique_weapon`.
          3:
            id: vehicle_to
            doc: |
              Used in `travel_start` zones as a trigger to teleport to the
              corresponding `travel_end` zone. The hotspot argument contains the
              id of the zone to teleport to.
          4:
            id: vehicle_back
            doc: |
              Counter part to `vehicle_to` hotspots. This is used to determine
              the hero's position on the zone after the `vehicle_to` hotspot has
              been triggered and to teleport back to the zone on main land.
          5:
            id: drop_map
            doc: |
              Hotspot that drops the map (aka locator) tile. One `find` zone
              with a hotspot of this type will be placed next to a town during
              world generation.
          6:
            id: drop_item
            doc: |
               Hotspot that, when triggered drops the item specified in the
               hotspot's argument. If the item is set to `0xFFFF` the zone's
               quest item will be dropped.
          7:
            id: npc
            doc: |
              This seems to be a placeholder for a pre-assigned NPC.
          8:
            id: drop_weapon
            doc: |
              Drops a weapon (specified by the hotspot argument) when triggered.
          9:
            id: door_in
            doc: |
              When triggered this hotspot type move the hero to the zone
              specified in the hotspot argument. The hero's location on the new
              zone will be determined by a corresponding `door_out` hotspot in
              the target zone.
          10:
            id: door_out
            doc:
              Determines where the hero will be placed when the zone is entered
              through a door. When triggered, this transports the player back to
              the `door_in` hotspot they game from.
          11: unused
          12: lock
          13:
            id: teleporter
            doc: |
              Teleporter hotspots can be used to instantly teleport to other
              (visited) teleporters on the map
          14:
            id: ship_to_planet
            doc: |
              Behaves similar to the `vehicle_to` hotspot type but travels
              between the town and the swamp planet.
          15:
            id: ship_from_planet
            doc: |
              Behaves similar to the `vehicle_back` hotspot type but travels
              between the town and the swamp planet.

    zone_auxiliary:
      seq:
        - id: marker
          contents: "IZAX"
        - id: size
          type: u4
        - type: u2
        - id: num_monsters
          type: u2
        - id: monsters
          type: monster
          repeat: expr
          repeat-expr: num_monsters
        - id: num_required_items
          type: u2
        - id: required_items
          doc: List of items that can be used to solve the zone.
          type: u2
          repeat: expr
          repeat-expr: num_required_items
        - id: num_goal_items
          type: u2
        - id: goal_items
          doc: |
            Additional items that are needed to solve the zone. Only used if the
            zone type is `goal`.
          type: u2
          repeat: expr
          repeat-expr: num_goal_items
    zone_auxiliary_2:
      seq:
        - id: marker
          contents: "IZX2"
        - id: size
          type: u4
        - id: num_provided_items
          type: u2
        - id: provided_items
          doc: Items that can be gained when the zone is solved.
          type: u2
          repeat: expr
          repeat-expr: num_provided_items
    zone_auxiliary_3:
      seq:
        - id: marker
          contents: "IZX3"
        - id: size
          type: u4
        - id: num_npcs
          type: u2
        - id: npcs
          doc: |
            NPCs that can be placed in the zone to trade items with the hero.
          type: u2
          repeat: expr
          repeat-expr: num_npcs
    zone_auxiliary_4:
      seq:
        - id: marker
          contents: "IZX4"
        - id: size
          type: u4
        - type: u2
    zones:
      seq:
        - id: num_zones
          type: u2
        - id: zones
          type: zone
          repeat: expr
          repeat-expr: num_zones
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
        - type: u4
          if: index != 0xFF_FF
        - type: u4
          if: index != 0xFF_FF
        - type: u2
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
            If the character referenced by index is a monster, this is a
            reference to their weapon, otherwise this is the index of the
            weapon's sound
          type: u2
          if: index != 0xFF_FF
        - id: health
          type: u2
          if: index != 0xFF_FF
    # Utilities
    prefixed_str:
      seq:
        - id: len_content
          type: u2
        - id: content
          type: str
          size: len_content
    prefixed_strz:
      seq:
        - id: len_content
          type: u2
        - id: content
          type: strz
          size: len_content
    waypoint:
      seq:
      - id: x
        type: u4
      - id: y
        type: u4
