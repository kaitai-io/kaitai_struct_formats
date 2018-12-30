meta:
  id: evil_islands_adb
  title: Evil Islands, ADB file (animations database)
  application: Evil Islands
  file-extension: adb
  license: MIT
  endian: le
doc: Animations database
doc-ref: https://github.com/aspadm/EIrepack/wiki/adb
seq:
  - id: magic
    contents: [0x41, 0x44, 0x42, 0x00]
  - id: num_animations
    type: u4
  - id: unit_name
    type: str
    encoding: cp1251
    size: 24
  - id: min_height
    type: f4
  - id: mid_height
    type: f4
  - id: max_height
    type: f4
  - id: animations
    type: animation
    repeat: expr
    repeat-expr: num_animations
types:
  animation:
    doc: Animation's parameters
    seq:
      - id: name
        type: str
        encoding: cp1251
        size: 16
      - id: index
        type: u4
        doc: Index in animations array
      - id: additionals
        type: additional
        doc: Packed structure with animation parameters
      - id: action_probability
        type: u4
        doc: Percents of action probability
      - id: animation_length
        type: u4
        doc: Lenght of animation in game ticks
      - id: movement_speed
        type: f4
      - id: start_show_hide1
        type: u4
      - id: start_show_hide2
        type: u4
      - id: start_step_sound1
        type: u4
      - id: start_step_sound2
        type: u4
      - id: start_step_sound3
        type: u4
      - id: start_step_sound4
        type: u4
      - id: start_hit_frame
        type: u4
      - id: start_special_sound
        type: u4
      - id: spec_sound_id1
        type: u4
      - id: spec_sound_id2
        type: u4
      - id: spec_sound_id3
        type: u4
      - id: spec_sound_id4
        type: u4
    types:
      additional:
        seq:
          - id: packed
            type: u8
        instances:
          weapons:
            value: 'packed & 127'
          allowed_states:
            value: '(packed >> 15) & 7'
          action_type:
            value: '(packed >> 18) & 15'
          action_modifyer:
            value: '(packed >> 22) & 255'
          animation_stage:
            value: '(packed >> 30) & 3'
          action_forms:
            value: '(packed >> 36) & 63'
