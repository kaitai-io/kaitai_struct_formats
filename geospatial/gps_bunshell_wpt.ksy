meta:
  id: gps_bunshell_wpt
  title: Bunshell GPS Point of Interest
  application: Bunshell receivers
  file-extension: wpt
  endian: le
  encoding: ascii
  license: GPL-2.0-or-later
  imports:
    - /log/gps/gps_bunshell_trl

doc: |
  File format used in Bunshell GPS receivers for POIs

doc-ref:
  - https://www.gpsbabel.org/htmldoc-development/fmt_bushnell.html
  - https://github.com/gpsbabel/gpsbabel/blob/master/bushnell.cc

seq:
  - id: waypoints
    type: waypoint
    repeat: eos

types:
  waypoint:
    seq:
      - id: point
        type: gps_bunshell_trl.point
      - id: type
        type: u1
        enum: type
      - id: flags
        type: flags
      - id: name
        type: strz

  flags:
    seq:
      - id: unknown
        type: b6
      - id: proximity_alarm
        type: b1
      - id: something
        type: b1


  point:
    seq:
      - id: lat
        type: fp
      - id: lon
        type: fp
    types:
      fp:
        seq:
          - id: raw
            type: s4
        instances:
          value:
            value: raw / 10000000.

enums:  # used identifiers from https://wiki.openstreetmap.org/wiki/Key:amenity and other cathegories
  type:
    0x00: unknown_yellow_square
    0x01: unknown_blue_grey_circle  # WUT?d
    0x02: unknown_yellow_diamond
    0x03: unknown_blue_asterisk
    0x04: unknown_blue_bulls_eye_pointing_ne
    0x05: unknown_red_satellite  # the original author described it as =O= rotated to 45°
    0x06: unknown_house  # maybe motel or house rental
    0x07: tourism_hotel # original author described as lodging
    0x08: amenity_hospital # red cross in square
    0x09: shop_car_repair
    0x0a: shop_doityourself  # instruments
    0x0b: amenity_fuel
    0x0c: route_hiking 
    0x0d: tourism_camp_site
    0x0e: tourism_picnic_site
    0x0f: amenity_hunting_stand  # described as deer stand
    0x10: hazard_animal_wild_animal  # described as a deer
    0x11: leisure_park
    0x11: natural_tree
    0x12: unknown_highway_exit
    0x13: bay_fjord
    0x14: bridge_yes
    0x15: unknown_waypoint
    0x16: unknown_warning
    0x17: bicycle_yes

    0x18: unknown_blue_question_circle
    0x19: unknown_blue_diamond_checkmark

    0x1a: man_made_surveillance
    0x1b: amenity_restaurant
    0x1c: amenity_toilets
    0x1d: tourism_caravan_site
    0x1e: amenity_drinking_water
    0x1f: leisure_fishing
    0x20: landuse_port
    0x21: leisure_slipway
    0x22: unknown_anchor  # originally described as just an anchor, likely a river port
    0x23: seamark_type_buoy
    0x24: sport_surfing
    0x25: sport_skiing
    0x26: natural_peak
    0x27: attraction_animal

    0x28: amenity_bank
    0x29: amenity_bar
    0x2a: man_made_lighthouse

    0x2b: amenity_shelter

    0x2c: shop_hardware

    0x2d: unknown_white_building_with_tunnel_looking_door_and_flag  # author speculated it may be a school
    0x2f: information_office  # described as just "information"
    0x30: leisure_picnic_table
    0x31: amenity_telephone
    0x32: amenity_post_office
    0x33: amenity_ranger_station
    0x34: unknown_red_square_building_with_yellow_flag # author speculated it may be a fire station

    0x35: shop_mall  # originally - shopping
    0x36: unknown_cross_hurricane

    0x37: tunnel_yes
    0x38: unknown_mountain_or_summit  # yet another mountain, how is it differnt from a peak?

    0x39: unknown_diagonally_crossed_square

    0x3a: leisure_swimming_pool
    0x3b: unknown_man_leaned_over_holding_blue_cube_1
    0x3c: amenity_parking
    0x3d: aeroway_aerodrome # airport
    0x3e: amenity_bus_station
    0x3f: amenity_doctors
    0x40: unknown_red_building_with_flag
    0x41: public_transport_stop_position_bus
    0x42: unknown_man_leaned_over_holding_blue_cube_2
    0x43: building_train_station
    0x44: amenity_ferry_terminal
