meta:
  id: gen2_wiiu_3ds_miitomo
  endian: le
seq:
  - id: unknown_1
    type: u1
    doc: Always 3?
  - id: character_set
    type: b2
    doc: 0=JPN+USA+EUR, 1=CHN, 2=KOR, 3=TWN
  - id: region_lock
    type: b2
    doc: 0=no lock, 1=JPN, 2=USA, 3=EUR
  - id: profanity_flag
    type: b1
  - id: copying
    type: b1
  - id: unknown_2
    type: b2
  - id: mii_position_slot_index
    type: b4
  - id: mii_position_page_index
    type: b4
  - id: version
    type: b4
  - id: unknown_3
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
    encoding: utf-16le
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
  - id: face_makeup
    type: b4
  - id: face_wrinkles
    type: b4
  - id: hair_type
    type: u1
  - id: unknown_5
    type: b4
  - id: hair_flip
    type: b1
  - id: hair_color
    type: b3
  - id: eye
    type: u4le
  - id: eyebrow
    type: u4le
  - id: nose
    type: u2le
  - id: mouth
    type: u2le
  - id: mouth2
    type: u2le
  - id: beard
    type: u2le
  - id: glasses
    type: u2le
  - id: mole
    type: u2le
  - id: creator_name
    type: str
    size: 20
    encoding: utf-16le
  - id: padding2
    type: u2le
  - id: checksum
    type: u2le
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