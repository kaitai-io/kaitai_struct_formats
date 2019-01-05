meta:
  id: warcraft_2_pud
  title: Warcraft II map files
  file-extension: pud
  application: Warcraft II engine
  xref:
    justsolve: Warcraft_II_PUD
    wikidata: Q28009492
  license: CC0-1.0
  ks-version: 0.6
  endian: le
doc: |
  Warcraft II game engine uses this format for map files. External
  maps can be edited by official Warcraft II map editor and saved in
  .pud files. Maps supplied with the game (i.e. single player
  campaign) follow the same format, but are instead embedded inside
  the game container files.

  There are two major versions: 0x11 (original one) and 0x13 (roughly
  corresponds to v1.33 of the game engine, although some of the
  features got limited support in v1.3).

  File consists of a sequence of typed sections.
doc-ref: http://cade.datamax.bg/war2x/pudspec.html
seq:
  - id: sections
    type: section
    repeat: eos
types:
  section:
    seq:
      - id: name
        type: str
        size: 4
        encoding: ASCII
      - id: size
        type: u4
      - id: body
        size: size
        type:
          switch-on: name
          cases:
            '"TYPE"': section_type
            '"VER "': section_ver
            #'"DESC"': section_desc
            '"OWNR"': section_ownr
            '"ERA "': section_era
            '"ERAX"': section_era
            '"DIM "': section_dim
            '"SGLD"': section_starting_resource
            '"SLBR"': section_starting_resource
            '"SOIL"': section_starting_resource
            '"UNIT"': section_unit
  section_type:
    doc: |
      Section that confirms that this file is a "map file" by certain
      magic string and supplies a tag that could be used in
      multiplayer to check that all player use the same version of the
      map.
    seq:
      - id: magic
        contents: ["WAR2 MAP", 0, 0]
      - id: unused
        size: 2
        doc: unused (always set to $0a and $ff by editor, but can be anything for the game)
      - id: id_tag
        type: u4
        doc: id tag (for consistency check in multiplayer)
  section_ver:
    doc: Section that specifies format version.
    seq:
      - id: version
        type: u2
  section_ownr:
    doc: Section that specifies who controls each player.
    seq:
      - id: controller_by_player
        type: u1
        enum: controller
        repeat: eos
  section_era:
    doc: Section that specifies terrain type for this map.
    seq:
      - id: terrain
        type: u2
        enum: terrain_type
  section_dim:
    seq:
      - id: x
        type: u2
      - id: y
        type: u2
  section_starting_resource:
    seq:
      - id: resources_by_player
        type: u2
        repeat: eos
  section_unit:
    seq:
      - id: units
        type: unit
        repeat: eos
  unit:
    seq:
      - id: x
        type: u2
      - id: y
        type: u2
      - id: u_type
        type: u1
        enum: unit_type
      - id: owner
        type: u1
      - id: options
        type: u2
        doc: if gold mine or oil well, contains 2500 * this, otherwise 0 passive 1 active
    instances:
      resource:
        value: options * 2500
        if: >
          u_type == unit_type::gold_mine or
          u_type == unit_type::human_oil_well or
          u_type == unit_type::orc_oil_well or
          u_type == unit_type::oil_patch
enums:
  controller:
    # official values
    0x02: passive_computer
    0x03: nobody
    0x04: computer
    0x05: human
    0x06: rescue_passive
    0x07: rescue_active
    # also supported by game engine
    0x01: computer
    # everything else is "passive_computer"
  terrain_type:
    0x00: forest
    0x01: winter
    0x02: wasteland
    0x03: swamp
  unit_type:
    0x00: infantry
    0x01: grunt
    0x02: peasant
    0x03: peon
    0x04: ballista
    0x05: catapult
    0x06: knight
    0x07: ogre
    0x08: archer
    0x09: axethrower
    0x0a: mage
    0x0b: death_knight
    0x0c: paladin
    0x0d: ogre_mage
    0x0e: dwarves
    0x0f: goblin_sapper
    0x10: attack_peasant
    0x11: attack_peon
    0x12: ranger
    0x13: berserker
    0x14: alleria
    0x15: teron_gorefiend
    0x16: kurdan_and_sky_ree
    0x17: dentarg
    0x18: khadgar
    0x19: grom_hellscream
    0x1a: human_tanker
    0x1b: orc_tanker
    0x1c: human_transport
    0x1d: orc_transport
    0x1e: elven_destroyer
    0x1f: troll_destroyer
    0x20: battleship
    0x21: juggernaught
    0x23: deathwing
    0x26: gnomish_submarine
    0x27: giant_turtle
    0x28: gnomish_flying_machine
    0x29: goblin_zepplin
    0x2a: gryphon_rider
    0x2b: dragon
    0x2c: turalyon
    0x2d: eye_of_kilrogg
    0x2e: danath
    0x2f: khorgath_bladefist
    0x31: cho_gall
    0x32: lothar
    0x33: gul_dan
    0x34: uther_lightbringer
    0x35: zuljin
    0x37: skeleton
    0x38: daemon
    0x39: critter
    0x3a: farm
    0x3b: pig_farm
    0x3c: human_barracks
    0x3d: orc_barracks
    0x3e: church
    0x3f: altar_of_storms
    0x40: human_scout_tower
    0x41: orc_scout_tower
    0x42: stables
    0x43: ogre_mound
    0x44: gnomish_inventor
    0x45: goblin_alchemist
    0x46: gryphon_aviary
    0x47: dragon_roost
    0x48: human_shipyard
    0x49: orc_shipyard
    0x4a: town_hall
    0x4b: great_hall
    0x4c: elven_lumber_mill
    0x4d: troll_lumber_mill
    0x4e: human_foundry
    0x4f: orc_foundry
    0x50: mage_tower
    0x51: temple_of_the_damned
    0x52: human_blacksmith
    0x53: orc_blacksmith
    0x54: human_refinery
    0x55: orc_refinery
    0x56: human_oil_well
    0x57: orc_oil_well
    0x58: keep
    0x59: stronghold
    0x5a: castle
    0x5b: fortress
    0x5c: gold_mine
    0x5d: oil_patch
    0x5e: human_start
    0x5f: orc_start
    0x60: human_guard_tower
    0x61: orc_guard_tower
    0x62: human_cannon_tower
    0x63: orc_cannon_tower
    0x64: circle_of_power
    0x65: dark_portal
    0x66: runestone
    0x67: human_wall
    0x68: orc_wall
