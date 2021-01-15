meta:
  id: gen2_wiiu_3ds_miitomo_mii
  file-extension:
    - cfsd
    - ffsd
  endian: le
seq:
  -
    type: u1
    doc: Always 3? May be an internal version identifier?
  - id: character_set
    type: b2
    enum: character_set
  - id: region_lock
    type: b2
    enum: region_lock
  - id: is_profanity_flag_enabled
    type: b1
  - id: is_copying_enabled
    type: b1
  -
    type: b2
  - id: mii_position_slot_index
    type: b4
  - id: mii_position_page_index
    type: b4
  - id: version
    type: b4
  -
    type: b4
  - id: system_id
    type: u1
    repeat: expr
    repeat-expr: 8
  - id: avatar_id
    type: u1
    repeat: expr
    repeat-expr: 4
  - id: client_id
    type: u1
    repeat: expr
    repeat-expr: 6
  - id: padding
    type: u2
  - id: data_1
    type: u2
  - id: mii_name
    type: str
    size: 20
    encoding: utf-16
  - id: body_height
    type: u1
  - id: body_weight
    type: u1
  - id: face_color
    type: b3
  - id: face_type
    type: b4
  - id: mingle
    type: b1
    doc: More info needed. Does this mean IS Mingled or IS NOT Mingled, such as on the Wii?
  - id: face_makeup
    type: b4
  - id: face_wrinkles
    type: b4
  - id: hair_type
    type: u1
  -
    type: b4
  - id: is_hair_flipped
    type: b1
  - id: hair_color
    type: b3
  - id: eye
    type: u4
  - id: eyebrow
    type: u4
  - id: nose
    type: u2
  - id: mouth
    type: u2
  - id: mouth2
    type: u2
  - id: beard
    type: u2
  - id: glasses
    type: u2
  - id: mole
    type: u2
  - id: creator_name
    type: str
    size: 20
    encoding: utf-16
  - id: padding2
    type: u2
  - id: checksum
    type: u2
enums:
  character_set:
    0: jpn_usa_eur
    1: chn
    2: kor
    3: twn
  region_lock:
    0: no_lock
    1: jpn
    2: usa
    3: eur
  gender:
    0: male
    1: female
instances:
  favorite:
    value: data_1 >> 14 & 1
  favorite_color:
    value: data_1 >> 10 & 15
  birth_day:
    value: data_1 >> 5 & 31
  birth_month:
    value: data_1 >> 1 & 15
  gender:
    value: data_1 & 1
    enum: gender
  eye_vertical:
    value: eye >> 25 & 31
  eye_horizontal:
    value: eye >> 21 & 15
  eye_rotation:
    value: eye >> 16 & 31
  eye_stretch:
    value: eye >> 13 & 7
  eye_size:
    value: eye >> 9 & 7
  eye_color:
    value: eye >> 6 & 7
  eye_type:
    value: eye & 63
  eyebrow_vertical:
    value: eyebrow >> 25 & 31
  eyebrow_horizontal:
    value: eyebrow >> 21 & 15
  eyebrow_rotation:
    value: eyebrow >> 16 & 15
  eyebrow_stretch:
    value: eyebrow >> 12 & 7
  eyebrow_size:
    value: eyebrow >> 8 & 15
  eyebrow_color:
    value: eyebrow >> 5 & 7
  eyebrow_type:
    value: eyebrow & 31
  nose_vertical:
    value: nose >> 9 & 31
  nose_size:
    value: nose >> 5 & 15
  nose_type:
    value: nose & 31
  mouth_stretch:
    value: mouth >> 13 & 7
  mouth_size:
    value: mouth >> 9 & 15
  mouth_color:
    value: mouth >> 6 & 7
  mouth_type:
    value: mouth & 63
  mouth_vertical:
    value: mouth2 & 31
  facial_hair_mustache:
    value: mouth2 >> 5 & 7
  facial_hair_vertical:
    value: beard >> 10 & 31
  facial_hair_size:
    value: beard >> 6 & 15
  facial_hair_color:
    value: beard >> 3 & 7
  facial_hair_beard:
    value: beard & 7
  glasses_vertical:
    value: glasses >> 11 & 15
  glasses_size:
    value: glasses >> 7 & 15
  glasses_color:
    value: glasses >> 4 & 7
  glasses_type:
    value: glasses & 15
  mole_vertical:
    value: mole >> 10 & 31
  mole_horizontal:
    value: mole >> 5 & 31
  mole_size:
    value: mole >> 1 & 15
  mole_enable:
    value: mole >> 15