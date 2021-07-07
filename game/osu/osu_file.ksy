meta:
  id: osu_file
  endian: le
  imports:
    - datetime
    - int_double_pair
    - timing_point
    - osu_string
seq:
  - id: osu_ver
    type: u4
  - id: folder_count
    type: u4
  - id: account_status
    type: b1
  - id: account_release_date
    type: datetime
  - id: player_name
    type: osu_string
  - id: beatmap_count
    type: u4
  - id: beatmaps
    type: beatmap
    repeat: expr
    repeat-expr: beatmap_count
  - id: unknown_int
    type: u4
types:
  beatmap:
    seq:
      - id: entry_size
        type: u4
      - id: artist_name
        type: osu_string
      - id: artist_name_unicode
        type: osu_string
      - id: song_title
        type: osu_string
      - id: song_title_unicode
        type: osu_string
      - id: creator
        type: osu_string
      - id: difficulty
        type: osu_string
      - id: audio_path
        type: osu_string
      - id: md5_hash
        type: osu_string
      - id: map_path
        type: osu_string
      - id: ranking
        type: u1
      - id: hitcircles
        type: u2
      - id: sliders
        type: u2
      - id: spinners
        type: u2
      - id: modtime
        type: u8
      - id: ar
        type:
          switch-on: _root.osu_ver < 20140609
          cases:
            true: u1
            false: f4
      - id: cs
        type:
          switch-on: _root.osu_ver < 20140609
          cases:
            true: u1
            false: f4
      - id: hpd
        type:
          switch-on: _root.osu_ver < 20140609
          cases:
            true: u1
            false: f4
      - id: od
        type:
          switch-on: _root.osu_ver < 20140609
          cases:
            true: u1
            false: f4
      - id: sv
        type: f8
      - id: idp1_count
        type: u4
      - id: idp1
        type: int_double_pair
        if: _root.osu_ver >= 20140609 and idp1_count > 0
        repeat: expr
        repeat-expr: idp1_count
      - id: idp2_count
        type: u4
      - id: idp2
        type: int_double_pair
        if: _root.osu_ver >= 20140609 and idp2_count > 0
        repeat: expr
        repeat-expr: idp2_count
      - id: idp3_count
        type: u4
      - id: idp3
        type: int_double_pair
        if: _root.osu_ver >= 20140609 and idp3_count > 0
        repeat: expr
        repeat-expr: idp3_count
      - id: idp4_count
        type: u4
      - id: idp4
        type: int_double_pair
        if: _root.osu_ver >= 20140609 and idp4_count > 0
        repeat: expr
        repeat-expr: idp4_count
      - id: draintime
        type: u4
      - id: totaltime
        type: u4
      - id: audio_preview_start
        type: u4
      - id: timing_point_count
        type: u4
      - id: timing_points
        type: timing_point
        repeat: expr
        repeat-expr: timing_point_count
        if: timing_point_count > 0
      - id: beatmap_id
        type: u4
      - id: beatmapset_id
        type: u4
      - id: thread_id
        type: u4
      - id: grade_standard
        type: u1
      - id: grade_taiko
        type: u1
      - id: grade_ctb
        type: u1
      - id: grade_mania
        type: u1
      - id: local_beatmap_offset
        type: u2
      - id: stack_leniency
        type: f4
      - id: gameplay_mode
        type: u1
      - id: song_source
        type: osu_string
      - id: song_tags
        type: osu_string
      - id: online_offset
        type: u2
      - id: title_font
        type: osu_string
      - id: unplayed
        type: b1
      - id: last_play
        type: u8
      - id: osz2
        type: b1
      - id: map_dir
        type: osu_string
      - id: last_check
        type: u8
      - id: disable_sound
        type: b1
      - id: disable_skin
        type: b1
      - id: disable_storyboard
        type: b1
      - id: disable_video
        type: b1
      - id: visual_override
        type: b1
      - id: unknown_short
        type: u2
        if: _root.osu_ver < 20140609
      - id: last_mod
        type: u4
      - id: mania_scroll_speed
        type: u1
