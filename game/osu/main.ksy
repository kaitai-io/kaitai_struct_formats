meta:
  id: osufile
  endian: le
  imports:
    - DateTime
    - String
    - Beatmap
seq:
  - id: osu_ver
    type: u4
  - id: folder_count
    type: s4
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
  - id: unkown_int
    type: u4
instances:
  float_or_int_selector:
    value: osu_ver < 20140609
types:
  float_or_int:
    seq:
      - id: value
        type:
          switch-on: _root.float_or_int_selector
          cases:
            true: u1
            false: f4
