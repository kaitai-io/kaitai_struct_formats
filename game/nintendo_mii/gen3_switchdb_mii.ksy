meta:
  id: gen3_switchdb_mii
  title: SwitchDB Mii character data
  file-extension:
    - nfsd
  endian: le
seq:
  - id: hair_type
    type: u1
    doc: Hair type. Ranges from 0 to 131. Not ordered the same as visible in editor.
  - id: is_mole_enabled
    type: b1
    doc: Enable mole. 0 = no, 1 = yes.
  - id: body_height
    type: b7
    doc: Body height. Ranges from 0 to 127, short to tall. In the Mii editor, pressing right will add 1 to this value, and pressing left will subtract 1, allowing for precise editing.
  - id: is_hair_flipped
    type: b1
    doc: Flip hair. 0 = no, 1 = yes.
  - id: body_weight
    type: b7
    doc: Body weight. Ranges from 0 to 127, small to large. In the Mii editor, pressing right will add 1 to this value, and pressing left will subtract 1, allowing for precise editing.
  - id: hair_color
    type: u1
    doc: Hair color. Ranges from 0 to 99. Not ordered the same as visible in editor.
  - id: gender
    type: b1
    enum: genders
    doc: Mii gender.
  - id: eye_color
    type: b7
    doc: Eye color. Ranges from 0 to 99. Not ordered the same as visible in editor.
  - id: eyebrow_color
    type: u1
    doc: Eyebrow color. Ranges from 0 to 99. Not ordered the same as visible in editor.
  - id: mouth_color
    type: u1
    doc: Mouth color. The default colors are ordered the same as visible in editor, ranging from 19 to 23. The custom colors are not and range from 0 to 99.
  - id: facial_hair_color
    type: u1
    doc: Facial hair color. Ranges from 0 to 99. Not ordered the same as visible in editor.
  - id: glasses_color
    type: u1
    doc: Glasses color. Ranges from 0 to 99. Not ordered the same as visible in editor.
  - id: eye_type
    type: u1
    doc: Eye type. Ranges from 0 to 59. Not ordered the same as visible in editor.
  - id: mouth_type
    type: u1
    doc: Mouth type. Ranges from 0 to 35. Not ordered the same as visible in editor.
  - id: glasses_size
    type: b3
    doc: Glasses size. Ranges from 0 to 7, small to big.
  - id: eye_vertical
    type: b5
    doc: Eye Y (vertical) position. Ranges from 24 to 0, low to high.
  - id: facial_hair_mustache
    type: b3
    doc: Mustache type. Ranges from 0 to 5.
  - id: eyebrow_type
    type: b5
    doc: Eyebrow type. Ranges from 0 to 23. Not ordered the same as visible in editor.
  - id: facial_hair_beard
    type: b3
    doc: Beard type. Ranges from 0 to 5.
  - id: nose_type
    type: b5
    doc: Nose type. Ranges from 0 to 17. Not ordered the same as visible in editor.
  - id: mouth_stretch
    type: b3
    doc: Mouth stretch. Ranges from 0 to 6, small to big.
  - id: nose_vertical
    type: b5
    doc: Nose Y (vertical) position. Ranges from 24 to 0, low to high.
  - id: eyebrow_stretch
    type: b3
    doc: Eyebrow stretch. Ranges from 0 to 6, small to big.
  - id: mouth_vertical
    type: b5
    doc: Mouth Y (vertical) position. Ranges from 24 to 0, low to high.
  - id: eye_rotation
    type: b3
    doc: Eye rotation. Ranges from 0 to 7, down to up. Note that some eye types have a default rotation.
  - id: facial_hair_vertical
    type: b5
    doc: Mustache Y (vertical) position. Ranges from 22 to 0, low to high.
  - id: eye_stretch
    type: b3
    doc: Eye stretch. Ranges from 0 to 6, small to big.
  - id: glasses_vertical
    type: b5
    doc: Glasses Y (vertical) position. Ranges from 20 to 0, low to high.
  - id: eye_size
    type: b3
    doc: Eye size. Ranges from 0 to 7, small to big.
  - id: mole_horizontal
    type: b5
    doc: Mole X (horizontal) position. Ranges from 0 to 16, left to right.
  - id: mole_vertical
    type: u1
    doc: Mole Y (vertical) position. Ranges from 30 to 0, low to high.
  - id: glasses_type
    type: u1
    doc: Glasses type. Ranges from 0 to 19. Not ordered the same as visible in editor.
  - id: face_type
    type: b4
    doc: Face shape. Ranges from 0 to 11. Not ordered the same as visible in editor.
  - id: favorite_color
    type: b4
    enum: favorite_colors
    doc: Favorite color. Ranges from 0 to 11.
  - id: face_wrinkles
    type: b4
    doc: Face wrinkles. Ranges from 0 to 11.
  - id: face_color
    type: b4
    doc: Skin color. Ranges from 0 to 9. Not ordered the same as visible in editor.
  - id: eye_horizontal
    type: b4
    doc: Eye X (horizontal) distance. Ranges from 0 to 12, close to far.
  - id: face_makeup
    type: b4
    doc: Face makeup. Ranges from 0 to 11.
  - id: eyebrow_rotation
    type: b4
    doc: Eyebrow rotation. Ranges from 0 to 11, down to up. Note that some eye types have a default rotation.
  - id: eyebrow_size
    type: b4
    doc: Eyebrow size. Ranges from 0 to 8, small to big.
  - id: eyebrow_vertical
    type: b4
    doc: Eyebrow Y (vertical) position. Ranges from 15 to 0, low to high.
  - id: eyebrow_horizontal
    type: b4
    doc: Eyebrow X (horizontal) distance. Ranges from 0 to 12, close to far.
  - id: mouth_size
    type: b4
    doc: Mouth size. Ranges from 0 to 8, small to big.
  - id: nose_size
    type: b4
    doc: Nose size. Ranges from 0 to 8, small to big.
  - id: mole_size
    type: b4
    doc: Mole size. Ranges from 0 to 8, small to big.
  - id: facial_hair_size
    type: b4
    doc: Mustache size. Ranges from 0 to 8, small to big.
  - id: mii_name
    type: str
    size: 20
    encoding: utf-16le
    doc: Mii name. Can be up to 10 characters long.
  -
    type: u1
    repeat: expr
    repeat-expr: 16
    doc: Currently unknown data.
  - id: mii_id
    type: u1
    repeat: expr
    repeat-expr: 4
    doc: Mii ID. An identifier used to save Miis in most games.
enums:
  genders:
    0: male
    1: female
  favorite_colors:
    0:  red
    1:  orange
    2:  yellow
    3:  light_green
    4:  green
    5:  blue
    6:  light_blue
    7:  pink
    8:  purple
    9:  brown
    10: white
    11: black
