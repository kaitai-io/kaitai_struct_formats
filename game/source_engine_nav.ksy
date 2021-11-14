# Base NAV file format in kaitai struct.
meta:
  id: source_engine_nav
  title: NAV
  file-extension: nav
#  tags:
#    - nav_mesh
#    - source_engine
#    - valve
  license: CC0-1.0
  endian: le

doc: |
  Base file format used by the Source Engine to store nav mesh data for maps. This KSY file does *not* account for derivative implementations.

  Code for the base NAV file format can be found in `game/server/nav_file.cpp`, which is located in the Source SDK 2013 repository (located at `https://github.com/ValveSoftware/source-sdk-2013/`).

doc-ref: "https://developer.valvesoftware.com/wiki/NAV"

seq:
  - id: magic_number
    contents: [0xce, 0xfa, 0xed, 0xfe] # 0xFEEDFACE
    doc: Magic Number of the NAV file. NAV files are always generated with 0xFEEDFACE in little-endian.
  - id: version
    type: u4
    doc: |
      Version of the base NAV file format. It is present in all NAV files.

      Changelog over NAV versions:
        * 1 = hiding spots as plain vector array
        * 2 = hiding spots as HidingSpot objects
        * 3 = Encounter spots use HidingSpot ID's instead of storing vector again
        * 4 = Includes size of source bsp file to verify nav data correlation
        * ---- Beta Release at V4 -----
        * 5 = Added Place info
        * ---- Conversion to Source Engine ------
        * 6 = Added Ladder info
        * 7 = Areas store ladder ID's so ladders can have one-way connections
        * 8 = Added earliest occupy times (2 floats) to each area
        * 9 = Promoted CNavArea's attribute flags to a short
        * 10 - Added sub-version number to allow derived classes to have custom area data
        * 11 - Added light intensity to each area
        * 12 - Storing presence of unnamed areas in the PlaceDirectory
        * 13 - Widened NavArea attribute bits from unsigned short to int
        * 14 - Added a bool for if the nav needs analysis
        * 15 - removed approach areas
        * 16 - Added visibility data to the base mesh

  # NAV Subversion
  - id: subversion
    type: u4
    if: 'version >= 10'
    doc: |
      Version of the derivative implementation of the NAV file format. Added in NAV version 10.

      Subversions used by Source Games:
      * Base SDK and Garry's Mod | 0
      * Counter-Strike: Source | 1
      * Counter-Strike: Global Offensive | 1
      * Team Fortress 2 | 2
      * Left 4 Dead | 13
      * Left 4 Dead 2 | 14

  - id: bsp_size
    type: u4
    if: 'version >= 4'
    doc: BSP Size of the map the NAV file was generated for. Added in NAV version 4.

  - id: analyzed
    type: u1 # The value is interpreted as a boolean, but it is actually stored as a full byte.
    if: 'version >= 14'
    doc: |
      Value that stores if the nav mesh has been analyzed (usually through `nav_analyze`).

      True: NAV file has been analyzed (usually through `nav_analyze`).
      False: It has not been analyzed.

  # Place Data
  - id: place_count
    type: u2
    if: 'version >= 5'
    doc: Amount of place names stored. Added in NAV version 5.
  - id: place_name_array
    type: place_name
    repeat: expr
    repeat-expr: place_count
    if: 'version >= 5'
    doc: Container for $place_count place names. Added in NAV version 5.
  # Unnamed areas boolean.
  - id: has_unnamed_areas
    type: u1 # The value is interpreted as a boolean in the Source-Engine C++ code, but it is actually stored as a byte.
    if: 'version >= 12'
    doc: Determines if NAV file has unnamed areas. Added in NAV version 12.
  # Area data.
  - id: area_count
    type: u4
    doc: Amount of areas stored in the navigation mesh.
  - id: area_array
    type: nav_area
    repeat: expr
    repeat-expr: area_count
  # Ladders
  - id: ladder_count
    type: u4
    if: '_root.version >= 6'
    doc: Amount of ladders stored in the navigation mesh. Added in NAV version 6.
  - id: ladder_array
    type: nav_ladder
    repeat: expr
    repeat-expr: ladder_count
    if: '_root.version >= 6'
  - id: custom_data
    size-eos: true
    if: '_root.version >= 10 and _root.subversion != 0'
    doc: Custom data appended by a specialized implementation of the NAV format. Should only be parsed if NAV file has a subversion.

types:
  place_name:
    doc: |
      A label of a location in a map. They are defined by the map (BSP file). Added in NAV Version 5.

      Place names are stored as Length-String value pairs.
    seq:
      - id: length
        type: u2
        doc: Length of the place name string.
      - id: name
        type: str
        size: length
        encoding: ASCII
  # Connection Pair
  area_id_array:
    seq:
      - id: count
        type: u4
      - id: area_ids
        type: u4
        repeat: expr
        repeat-expr: count
  # ApproachInfo
  approach_info:
    doc: |
      Datum point that determines the type of movement between areas. Removed in NAV version 15.

      It is only used by the Counter-Strike video game series.

    # The elements
    seq:
      - id: target_area_id
        type: u4
        doc: Area ID of area to approach to.
      - id: approach_prev
        type: u4
        doc: Area ID of the area before the current approach area.
      - id: type
        type: u1
        doc: Type of approach method.
      - id: next
        type: u4
        doc: Area ID of area to approach to next.
      - id: method
        type: u1
  # NavHidingSpot
  hiding_spot:
    seq:
      - id: area_id
        type: u4
        if: '_root.version >= 2'
        doc: Area ID of the hiding spot's parent area. Added in NAV version 2.
      - id: position
        type: f4
        repeat: expr
        repeat-expr: 3
        if: '_root.version >= 1'
        doc: The position of the Hiding spot (as a vector). Added in NAV version 1.
      - id: attribute_flag
        type: b1
        repeat: expr
        repeat-expr: 8
        if: '_root.version >= 2'
        doc: The hiding spot attribute flag. Added in NAV version 2.
    enums:
      # Hiding Spot Attributes.
      hide_spot_attribute:
        1: in_cover
        2: good_sniper_spot
        4: ideal_sniper_spot
        8: exposed
  # Class: AreaBindInfo
  area_bind:
    doc: |
      Stores the type of visibility to an area. Added in NAV version 16.

      The structure stores an area ID as an unsigned integer (32-bits) and a byte flag that determines if visibility checks should be done.
    seq:
      - id: bound_area_id
        type: u4
        doc: Identifier of the targeted area.
      - id: attribute_byte
        type: u1 # The value is used by the source engine as a number in an unsigned byte, NOT as a bit field!
        enum: visibility_type
        doc: |
            Determines type of visibility to the bound area. See the `visibility_type` enum for the values.
    enums:
      # VisibilityType enum.
      visibility_type:
        0:
          id: not_visible
          doc: No visibility checks; area is always invisible.
        1: 
          id: potentially_visible
          doc: Perform visibility checks to determine if the pointed area is visible (from the bot).
        2:
          id: completely_visible
          doc: No visibility checks; area is always visible.

  # NavEncounterSpot
  encounter_spot:
    doc: |
      Encounter spots are waypoints used in Encounter Paths to determine the path to travel.

      Encounter spots are currently only used in the Counter-Strike video game series.
    seq:
      - id: area_id
        type: u4

      - id: parametric_distance
        type: u1
        doc: Parametric distance of the navigation area as an unsigned byte.
  # NavEncounterPath
  encounter_path:
    doc: |
      A sequence of encounter spots which are used by bots to determine the route to an area.

      Encounter Paths are currently only used in the Counter-Strike video game series.
    seq:
      - id: entry_area_id
        type: u4
        doc: Uncertain.
      - id: entry_direction
        type: u1
        enum: nav_direction
      - id: destination_area_id
        type: u4
      - id: destination_direction
        type: u1
        enum: nav_direction
        doc: Direction to travel towards.
      # Encounter spots
      - id: encounter_spot_count
        type: u1
        doc: Amount of encounter spots stored in the encounter path file data.
      - id: encounter_spot_sequence
        type: encounter_spot
        repeat: expr
        repeat-expr: encounter_spot_count
        doc: Sequence of encounter spots with `encounter_spot_count` elements.
  # NavArea
  nav_area:
    doc: |
      Navigation Areas determine the boundaries AI can move within.
    seq:
      # Custom data can be prepended here.
      # Area Data.
      - id: id
        type: u4
        doc: Identifier number for the navigation area.
      - id: attribute_flag
        type:
          switch-on: _root.version
          cases: {
            0: u1,
            1: u1,
            2: u1,
            3: u1,
            4: u1,
            5: u1,
            6: u1,
            7: u1,
            8: u2,
            9: u2,
            10: u2,
            11: u2,
            12: u2,
            13: u2,
            _: u4
          }
        doc: |
          Area attribute flag. The byte-length of the flag varies across NAV versions.

          +---------+-------------+
          | Version | Byte-Length |
          +---------+-------------+
          | 0-7     | 1 byte      |
          +---------+-------------+
          | 8-13    | 2 bytes     |
          +---------+-------------+
          | >14     | 4 bytes     |
          +---------+-------------+
      - id: north_west_corner
        type: f4
        repeat: expr
        repeat-expr: 3
        doc: The north-west corner position of an area.
      - id: south_east_corner
        type: f4
        repeat: expr
        repeat-expr: 3
        doc: The south-east corner position of an area.
      - id: north_east_corner_height
        type: f4
        doc: The height (Z coordinate) of the area's north-east corner.
      - id: south_west_corner_height
        type: f4
        doc: The height (Z coordinate) of the area's south-west corner.
      # Connection data.
      - id: connection_data
        type: area_id_array
        repeat: expr
        repeat-expr: 4
        doc: Container for connections.
      # Hiding Spots sequence.
      - id: hiding_spot_count
        type: u1
        doc: Amount of hiding spots stored in the navigation area.
      - id: hiding_spot_sequence
        type: hiding_spot
        repeat: expr
        repeat-expr: hiding_spot_count
        doc: Sequence of hiding spots.
      # Approach Spots
      - id: approach_info_count
        type: u1
        if: '_root.version < 15'
        doc: |
          The amount of approach spots stored in the NAV area.

          Removed in NAV version 15 and above.
      - id: approach_info_sequence
        type: approach_info
        repeat: expr
        repeat-expr: approach_info_count
        if: '_root.version < 15'
      # Encounter Path
      - id: encounter_path_count
        type: u4
        doc: Amount of encounter paths.
      - id: encounter_path_data
        type: encounter_path
        repeat: expr
        repeat-expr: encounter_path_count
      # Place ID
      - id: place_id
        type: u2
        doc: Reference place index.
      # Ladders
      - id: ladder_data
        type: area_id_array
        repeat: expr
        repeat-expr: 2
      # Occupy times
      - id: earliest_occupation_time
        type: f4
        repeat: expr
        repeat-expr: 2
        if: '_root.version >= 8'
        doc: Earliest occupation times possible for each team. Added in NAV version 8.
      # Light Intensity
      - id: light_intensity
        type: f4
        repeat: expr
        repeat-expr: 4
        if: '_root.version >= 11'
        doc: Light Intensities (brightness) for each corner. Added in NAV version 11.
      # Visibility area-binds.
      - id: area_bind_count
        type: u4
        if: '_root.version >= 16'
        doc: Amount of area-binds stored in area data. Added in NAV version 16.
      - id: area_bind_array
        type: area_bind
        repeat: expr
        repeat-expr: area_bind_count
        if: '_root.version >= 16'
      # Inheritance
      - id: area_id_vis_inherit
        type: u4
        if: '_root.version >= 16'
        doc: ID of area to inherit visibility bind information from. Only exists in NAV version 16 and later.
      # Custom data can be appended here.
    enums:
     # Enum in code: NavAttributeType
      nav_attribute_type:
        0: nav_mesh_blank
        0x00000001: nav_mesh_crouch # Must crouch to use this node/area.
        0x00000002: nav_mesh_jump # Must jump to traverse this area (only used during generation).
        0x00000004: nav_mesh_precise # Do not adjust for obstacles, just move along area.
        0x00000008: nav_mesh_no_jump # Inhibit discontinuity jumping.
        0x00000010: nav_mesh_stop # Must stop when entering this area.
        0x00000020: nav_mesh_run # Must run to traverse this area.
        0x00000040: nav_mesh_walk # Must walk to traverse this area.
        0x00000080: nav_mesh_avoid # Avoid this area unless alternatives are too dangerous.
        0x00000100: nav_mesh_transient # Area may become blocked, and should be periodically checked.
        0x00000200: nav_mesh_dont_hide # Area should not be considered for hiding spot generation.
        0x00000400: nav_mesh_stand # Bots hiding in this area should stand.
        0x00000800: nav_mesh_no_hostages # Hostages shouldn't use this area.
        0x00001000: nav_mesh_stairs # This area represents stairs, do not attempt to climb or jump them - just walk up.
        0x00002000: nav_mesh_no_merge # Don't merge this area with adjacent areas.
        0x00004000: nav_mesh_obstacle_top # This nav area is the climb point on the tip of an obstacle.
        0x00008000: nav_mesh_cliff # This nav area is adjacent to a drop of at least CliffHeight.

        0x00010000: nav_mesh_first_custom # Apps may define custom app-specific bits starting with this value.
        0x04000000: nav_mesh_last_custom # Apps must not define custom app-specific bits higher than with this value.
        0x20000000: nav_mesh_func_cost
        0x40000000: nav_mesh_has_elevator # Area is in an elevator's path.
        0x80000000: nav_mesh_nav_blocker # Area is blocked by nav blocker ( Alas, needed to hijack a bit in the attributes to get within a cache line [7/24/2008 tom]).
  # Class: NavLadder
  nav_ladder:
    doc: |
      A subtype of a navigation area that allows NextBots to walk up it.

      Added in NAV version 6.
    seq:
      - id: ladder_id
        type: u4
        doc: Area ID of the ladder.
      - id: width
        type: f4
        doc: Width of the ladder area.
      - id: top_corner
        type: f4
        repeat: expr
        repeat-expr: 3
        doc: Top corner (vector) of the ladder.
      - id: bottom_corner
        type: f4
        repeat: expr
        repeat-expr: 3
        doc: Bottom corner (vector) of the ladder.
      - id: length
        type: f4
        doc: Length of the ladder area.
      - id: direction
        type: u4
        enum: nav_ladder_direction
        doc: Direction of the navigation area.
      - id: top_forward_area_id
        type: u4
        doc: Connects area ID to the front of the top rung.
      - id: top_left_area_id
        type: u4
      - id: top_right_area_id
        type: u4
      - id: top_behind_area_id
        type: u4
      - id: bottom_area_id
        type: u4
    enums:
      nav_ladder_direction:
        0: up
        1: down
        2: count

enums:
  # Directions defined by the Source Engine.
  nav_direction:
    0: north
    1: east
    2: south
    3: west
