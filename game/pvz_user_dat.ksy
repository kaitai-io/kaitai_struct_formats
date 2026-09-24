meta:
  id: pvz_user_dat
  application: Plants vs. Zombies
  file-extension: dat
  endian: le
  license: CC0-1.0
  encoding: ASCII
doc-ref: https://plantsvszombies.fandom.com/wiki/User_file_format
doc: |
  https://github.com/Freed-Wu/pvz.nvim provides tools to (de)serialize it.
seq:
  - id: version
    type: u4
    valid:
      any-of:
        - 0x0A
        - 0x0B
        - 0x0C
    doc: |
      0x0A = beta 0.1.1.1014
      0x0B = beta 0.9.9.1029
      0x0C = final (1.0.0.1051 – 1.2.0.1073)
  - id: adventure_level
    type: u4
    valid:
      max: 0x7FFFFFFF
      min: 1
    doc: |
      Current level in Adventure Mode (1–50, extended levels 51–0x7FFFFFFF)
  - id: money_div_10
    type: u4
    doc: Money divided by 10
  - id: adventure_completed_times
    type: u4
    doc: Number of times Adventure Mode completed

  # Survival flags (normal)
  - id: survival_day_flags
    type: u4
  - id: survival_night_flags
    type: u4
  - id: survival_pool_flags
    type: u4
  - id: survival_fog_flags
    type: u4
  - id: survival_roof_flags
    type: u4

  # Survival flags (hard)
  - id: survival_day_hard_flags
    type: u4
  - id: survival_night_hard_flags
    type: u4
  - id: survival_pool_hard_flags
    type: u4
  - id: survival_fog_hard_flags
    type: u4
  - id: survival_roof_hard_flags
    type: u4

  # Survival endless streaks
  - id: streak_day_endless
    type: u4
  - id: streak_night_endless
    type: u4
  - id: streak_pool_endless
    type: u4
  - id: streak_fog_endless
    type: u4
  - id: streak_roof_endless
    type: u4

  # Minigame trophies
  - id: trophy_zombotany
    type: u4
  - id: trophy_wallnut_bowling
    type: u4
  - id: trophy_slot_machine
    type: u4
  - id: trophy_raining_seeds
    type: u4
  - id: trophy_beghouled
    type: u4
  - id: trophy_invisighoul
    type: u4
  - id: trophy_seeing_stars
    type: u4
  - id: trophy_zombiquarium
    type: u4
  - id: trophy_beghouled_twist
    type: u4
  - id: trophy_big_trouble_little_zombie
    type: u4
  - id: trophy_portal_combat
    type: u4
  - id: trophy_column_like_you_see_em
    type: u4
  - id: trophy_bobsled_bonanza
    type: u4
  - id: trophy_zombie_nimble_zombie_quick
    type: u4
  - id: trophy_whack_a_zombie
    type: u4
  - id: trophy_last_stand
    type: u4
  - id: trophy_zombotany_2
    type: u4
  - id: trophy_wallnut_bowling_2
    type: u4
  - id: trophy_pogo_party
    type: u4
  - id: trophy_dr_zomboss_revenge
    type: u4

  # Hidden minigame trophies
  - id: trophy_art_challenge_wallnut
    type: u4
  - id: trophy_sunny_day
    type: u4
  - id: trophy_unsodded
    type: u4
  - id: trophy_big_time
    type: u4
  - id: trophy_art_challenge_sunflower
    type: u4
  - id: trophy_air_raid
    type: u4
  - id: trophy_ice_level
    type: u4
  - id: trophy_zen_garden_limbo
    type: u4
  - id: trophy_high_gravity
    type: u4
  - id: trophy_grave_danger
    type: u4
  - id: trophy_can_you_dig_it
    type: u4
  - id: trophy_dark_stormy_night
    type: u4
  - id: trophy_bungee_blitz
    type: u4
  - id: trophy_squirrel
    type: u4

  - id: tree_of_wisdom_height
    type: u4

  # Puzzle trophies
  - id: trophy_vasebreaker
    type: u4
  - id: trophy_to_the_left
    type: u4
  - id: trophy_third_vase
    type: u4
  - id: trophy_chain_reaction
    type: u4
  - id: trophy_m_is_for_metal
    type: u4
  - id: trophy_scary_potter
    type: u4
  - id: trophy_hokey_pokey
    type: u4
  - id: trophy_another_chain_reaction
    type: u4
  - id: trophy_ace_of_vase
    type: u4

  - id: streak_vasebreaker_endless
    type: u4

  # I, Zombie puzzles
  - id: trophy_i_zombie
    type: u4
  - id: trophy_i_zombie_too
    type: u4
  - id: trophy_can_you_dig_it_puzzle
    type: u4
  - id: trophy_totally_nuts
    type: u4
  - id: trophy_dead_zeppelin
    type: u4
  - id: trophy_me_smash
    type: u4
  - id: trophy_zomboogie
    type: u4
  - id: trophy_three_hit_wonder
    type: u4
  - id: trophy_all_your_brainz_r_belong_to_us
    type: u4

  - id: streak_i_zombie_endless
    type: u4

  - id: trophy_upsell_limbo
    type: u4
  - id: trophy_intro_limbo
    type: u4

  - id: unknown_130_19f
    size: 0x70

  # Shop plants
  - id: has_gatling_pea
    type: u4
  - id: has_twin_sunflower
    type: u4
  - id: has_gloom_shroom
    type: u4
  - id: has_cattail
    type: u4
  - id: has_winter_melon
    type: u4
  - id: has_gold_magnet
    type: u4
  - id: has_spikerock
    type: u4
  - id: has_cob_cannon
    type: u4
  - id: has_imitater
    type: u4

  - id: unknown_1c4
    type: u4

  - id: marigold_days_left
    type: u4
  - id: marigold_days_center
    type: u4
  - id: marigold_days_right
    type: u4

  - id: has_golden_watering_can
    type: u4
  - id: fertilizer_amount
    type: u4
  - id: bug_spray_amount
    type: u4
  - id: has_phonograph
    type: u4
  - id: has_gardening_glove
    type: u4
  - id: has_mushroom_garden
    type: u4
  - id: has_wheel_barrow
    type: u4

  - id: stinky_last_awoken
    type: u4
  - id: seed_slots_minus_6
    type: u4
  - id: has_pool_cleaner
    type: u4
  - id: has_roof_cleaner
    type: u4
  - id: garden_rake_uses
    type: u4
  - id: has_aquarium_garden
    type: u4
  - id: chocolate_amount
    type: u4
  - id: tree_of_wisdom_available
    type: u4
  - id: tree_food_amount
    type: u4
  - id: has_wallnut_first_aid
    type: u4

  - id: unknown_218_2ef
    size: 0xD8

  - id: almanac_flag
    type: u4
  - id: stinky_last_chocolate
    type: u4
  - id: stinky_x
    type: u4
  - id: stinky_y
    type: u4

  - id: minigames_unlocked
    type: u4
  - id: puzzle_mode_unlocked
    type: u4
  - id: animate_minigame_unlock
    type: u4
  - id: animate_vasebreaker_unlock
    type: u4
  - id: animate_i_zombie_unlock
    type: u4
  - id: animate_survival_unlock
    type: u4
  - id: animate_limbo_unlock
    type: u4
  - id: show_adventure_complete
    type: u4
  - id: has_taco
    type: u4
  - id: stinky_asleep
    type: u4

  - id: unknown_328
    type: u4
  - id: unknown_32c
    type: u4

  - id: num_zen_plants
    type: u4

  # Zen Garden plants
  - id: zen_plants
    type: zen_plant
    repeat: expr
    repeat-expr: num_zen_plants

  # Achievements
  - id: home_lawn_security
    type: u2
  - id: nobel_peas_prize
    type: u2
  - id: better_off_dead
    type: u2
  - id: china_shop
    type: u2
  - id: spudow
    type: u2
  - id: explodonator
    type: u2
  - id: morticulturalist
    type: u2
  - id: dont_pea_in_the_pool
    type: u2
  - id: roll_some_heads
    type: u2
  - id: grounded
    type: u2
  - id: zombologist
    type: u2
  - id: penny_pincher
    type: u2
  - id: sunny_days
    type: u2
  - id: popcorn_party
    type: u2
  - id: good_morning
    type: u2
  - id: no_fungus_among_us
    type: u2
  - id: beyond_the_grave
    type: u2
  - id: immortal
    type: u2
  - id: towering_wisdom
    type: u2
  - id: mustache_mode
    type: u2
  - id: zombatar_license_accepted
    type: u1
  - id: num_zombatars
    type: u4

  # Zombatars
  - id: zombatars
    type: zombatar
    repeat: expr
    repeat-expr: num_zombatars
  - id: unknown_tail
    size: 0x14
  - id: dont_display_saved_jpeg_to_desktop_message
    type: u1

types:
  zen_plant:
    seq:
      - id: plant_type
        type: u4
      - id: garden_location
        type: u4
      - id: column
        type: u4
      - id: row
        type: u4
      - id: direction
        type: u4
      - id: unknown_14
        type: u4
      - id: last_watered
        type: u4
      - id: unknown_1c
        type: u4
      - id: color
        type: u4
      - id: times_fertilized
        type: u4
      - id: times_watered
        type: u4
      - id: water_needed
        type: u4
      - id: happiness_state
        type: u4
      - id: unknown_34
        type: u4
      - id: last_phono_bugspray
        type: u4
      - id: unknown_3c
        type: u4
      - id: last_fertilized
        type: u4
      - id: unknown_44
        type: u4
      - id: last_chocolate
        type: u4
      - id: unknown_4c
        type: u4
      - id: unknown_50
        type: u4
      - id: unknown_54
        type: u4

  zombatar:
    seq:
      - id: unknown_00
        type: u4
      - id: skin_color
        type: u4
      - id: clothes_type
        type: u4
      - id: clothes_color
        type: u4
      - id: tidbits_type
        type: u4
      - id: tidbits_color
        type: u4
      - id: accessories_type
        type: u4
      - id: accessories_color
        type: u4
      - id: facial_hair_type
        type: u4
      - id: facial_hair_color
        type: u4
      - id: hair_type
        type: u4
      - id: hair_color
        type: u4
      - id: eyewear_type
        type: u4
      - id: eyewear_color
        type: u4
      - id: hat_type
        type: u4
      - id: hat_color
        type: u4
      - id: backdrop_type
        type: u4
      - id: backdrop_color
        type: u4
