meta:
  id: taisei_progress
  title: Taisei Project Progress File (uncompressed)
  application: Taisei Project
  file-extension: progress
  encoding: ASCII
  license: CC0-1.0
  endian: le
doc-ref: https://github.com/taisei-project/taisei/blob/master/src/progress.c
seq:
  - id: magic
    type: u8
    valid: 0x8483E36F66746700
  - id: checksum
    type: u4
    doc: CRC32 of the commands_raw, seed is 0xB16B00B5
  - id: cmds
    type: cmd
    repeat: eos
types:
  cmd:
    seq:
      - id: id
        type: u1
        enum: progfile_command
      - id: len_payload
        type: u2
      - id: payload
        size: len_payload
        type:
          switch-on: id
          cases:
            progfile_command::unlock_stages: u2
            progfile_command::unlock_stages_with_difficulty: header
            progfile_command::hiscore: u4
            progfile_command::stage_playinfo: playinfos
            progfile_command::endings: endings
            progfile_command::game_settings: settings
            progfile_command::game_version: version
            progfile_command::unlock_bgms: u8
            progfile_command::unlock_cutscenes: u8
            progfile_command::hiscore_64bit: u8
            progfile_command::stage_playinfo2: playinfo2s
            _: str
  version:
    seq:
      - id: major
        type: u1
      - id: minor
        type: u1
      - id: patch
        type: u1
      - id: tweak
        type: u2
  settings:
    seq:
      - id: difficulty
        type: u1
      - id: character
        type: u1
      - id: shotmode
        type: u1
  endings:
    seq:
      - id: ending
        type: u1
      - id: num_achieved
        type: u4
  header:
    seq:
      - id: stage
        type: u2
      - id: difficulty
        type: u1
  playinfos:
    seq:
      - id: playinfos
        type: playinfo
        repeat: eos
  playinfo:
    seq:
      - id: header
        type: header
      - id: num_played
        type: u4
      - id: num_cleared
        type: u4
  playinfo2s:
    seq:
      - id: playinfos
        type: playinfo2
        repeat: eos
  playinfo2:
    seq:
      - id: header
        type: header
      - id: hiscore
        type: u8
      - id: percharacters
        type: percharacter
        repeat: expr
        repeat-expr: 3
  percharacter:
    seq:
      - id: permodes
        type: permode
        repeat: expr
        repeat-expr: 2
  permode:
    seq:
      - id: num_played
        type: u4
      - id: num_cleared
        type: u4
      - id: hiscore
        type: u8
enums:
  progfile_command:
    0x00: unlock_stages
    0x01: unlock_stages_with_difficulty
    0x02: hiscore
    0x03: stage_playinfo
    0x04: endings
    0x05: game_settings
    0x06: game_version
    0x07: unlock_bgms
    0x08: unlock_cutscenes
    0x09: hiscore_64bit
    0x10: stage_playinfo2
