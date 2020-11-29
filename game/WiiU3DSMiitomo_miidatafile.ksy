meta:
  id: wiiu3dsmiitomo_miidatafile
  endian: le
  bit-endian: le
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
  - id: gender
    type: b1
  - id: birth_month
    type: b4
  - id: birth_day
    type: b5
  - id: favorite_color
    type: b4
  - id: favorite
    type: b1
  - id: unknown_4
    type: b1
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
  - id: eye_type
    type: b6
  - id: eye_color
    type: b3
  - id: eye_size
    type: b3
  - id: unknown_6
    type: b1
  - id: eye_stretch
    type: b3
  - id: eye_rotation
    type: b5
  - id: eye_horizontal
    type: b4
  - id: eye_vertical
    type: b5
  - id: unknown_7
    type: b2
  - id: eyebrow_type
    type: b5
  - id: eyebrow_color
    type: b3
  - id: eyebrow_size
    type: b4
  - id: eyebrow_stretch
    type: b3
  - id: unknown_8
    type: b1
  - id: eyebrow_rotation
    type: b4
  - id: unknown_9
    type: b1
  - id: eyebrow_horizontal
    type: b4
  - id: eyebrow_vertical
    type: b5
  - id: unknown_10
    type: b2
  - id: nose_type
    type: b5
  - id: nose_size
    type: b4
  - id: nose_vertical
    type: b5
  - id: unknown_11
    type: b2
  - id: mouth_type
    type: b6
  - id: mouth_color
    type: b3
  - id: mouth_size
    type: b4
  - id: mouth_stretch
    type: b3
  - id: mouth_vertical
    type: b5
  - id: facial_hair_mustache
    type: b3
  - id: unknown_12
    type: b8
  - id: facial_hair_beard
    type: b3
  - id: facial_hair_color
    type: b3
  - id: facial_hair_size
    type: b4
  - id: facial_hair_vertical
    type: b5
  - id: unknown_13
    type: b1
  - id: glasses_type
    type: b4
  - id: glasses_color
    type: b3
  - id: glasses_size
    type: b4
  - id: glasses_vertical
    type: b4
  - id: unknown_14
    type: b1
  - id: mole_enable
    type: b1
  - id: mole_size
    type: b4
  - id: mole_horizontal
    type: b5
  - id: mole_vertical
    type: b5
  - id: unknown_15
    type: b1
  - id: creator_name
    type: str
    size: 20
    encoding: utf-16le
  - id: padding2
    type: u2le
  - id: checksum
    type: u2le
