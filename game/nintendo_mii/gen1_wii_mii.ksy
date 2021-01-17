meta:
  id: gen1_wii_mii
  title: Wii Mii character data
  file-extension:
    - mii
    - mae
    - miigx
    - rcd
    - rsd
  bit-endian: be
  endian: be
seq:
  - id: invalid
    type: b1
    doc: Has no apparent effect.
  - id: gender
    type: b1
    enum: genders
  - id: birth_month
    type: b4
    enum: months
    doc: Mii birthday month, Ranges from 0 to 11
  - id: birth_day
    type: b5
    doc: Mii birthday day, Ranges from 0 to 30
  - id: favorite_color
    type: b4
    enum: favorite_colors
    doc: Favorite color. Ranges from 0 to 11.
  - id: is_favorite
    type: b1
    doc: Whether the Mii is a favorite or not.
  - id: mii_name
    type: str
    size: 20
    doc: Mii name. Can be up to 10 characters long.
    encoding: utf-16be
  - id: body_height
    type: u1
    doc: Body height. Ranges from 0 to 127, short to tall.
  - id: body_weight
    type: u1
    doc: Body weight. Ranges from 0 to 127, small to large.
  - id: mii_id
    type: u1
    repeat: expr
    repeat-expr: 4
    doc: Unique Mii identifier. Also governs color of the Mii's pants.
  - id: console_id
    type: u1
    repeat: expr
    repeat-expr: 4
    doc: Unique identifier for the console the Mii was created on. Consists of a checksum of the first 3 bytes of the console's mac address, followed by the last 3 bytes of the console's mac address
  - id: face_type
    type: b3
    doc: Face shape. Ranges from 0 to 7. Not ordered the same as visible in editor.
  - id: face_color
    type: b3
    doc: Skin color. Ranges from 0 to 5. Not ordered the same as visible in editor. A map of the internal values in correlation to the Mii editor is at /maps.txt/{skin}.
  - id: facial_feature
    type: b4
    doc: Facial feature. Ranges from 0 to 11.
  -
    type: b3
    doc: Currently unknown data.
  - id: is_not_mingled
    type: b1
    doc: Whether the Mii was allowed to travel to other consoles via WiiConnect24. 0 = yes, 1 = no.
  -
    type: b1
    doc: Currently unknown data.
  - id: is_downloaded
    type: b1
    doc: Whether the Mii was downloaded from the Check Mii Out channel.
  - id: hair_type
    type: b7
    doc: Hair type. Ranges from 0 to 71. Not ordered the same as visible in editor.
  - id: hair_color
    type: b3
    doc: Hair color. Ranges from 0 to 7. Not ordered the same as visible in editor.
  - id: is_hair_flipped
    type: b1
    doc: Flip hair. 0 = no, 1 = yes.
  -
    type: b5
    doc: Currently unknown data.
  - id: eyebrow_type
    type: b5
    doc: Eyebrow type. Ranges from 0 to 23. Not ordered the same as visible in editor.
  -
    type: b1
    doc: Currently unknown data.
  - id: eyebrow_rotation
    type: b4
    doc: Eyebrow rotation. Ranges from 0 to 11, down to up. Note that some eye types have a default rotation.
  -
    type: b6
    doc: Currently unknown data.
  - id: eyebrow_color
    type: b3
    doc: Eyebrow color. Ranges from 0 to 7. Not ordered the same as visible in editor.
  - id: eyebrow_size
    type: b4
  - id: eyebrow_vertical
    type: b5
    doc: Eyebrow Y (vertical) position. Ranges from 3 to 18, low to high.
  - id: eyebrow_horizontal
    type: b4
    doc: Eyebrow X (horizontal) distance. Ranges from 0 to 12, close to far.
  - id: eye_type
    type: b6
    doc: Eye type. Ranges from 0 to 47. Not ordered the same as visible in editor.
  -
    type: b2
    doc: Currently unknown data.
  - id: eye_rotation
    doc: Eye rotation. Ranges from 0 to 7. 
    type: b3
  - id: eye_vertical
    type: b5
    doc: Eye Y (vertical) position. Ranges from 0 to 18, high to low.
  - id: eye_color
    type: b3
    doc: Eye color. Ranges from 0 to 5. Not ordered the same as visible in editor.
  -
    type: b1
    doc: Currently unknown data.
  - id: eye_size
    type: b3
    doc: Eye size. Ranges from 0 to 7, small to big.
  - id: eye_horizontal
    type: b4
    doc: Eye X (horizontal) distance. Ranges from 0 to 12, close to far.
  -
    type: b5
    doc: Currently unknown data.
  - id: nose_type
    type: b4
    doc: Nose type. Ranges from 0 to 11. Not ordered the same as visible in editor.
  - id: nose_size
    type: b4
    doc: Nose size. Ranges from 0 to 8, small to big.
  - id: nose_vertical
    type: b5
    doc: Nose Y (vertical) position. Ranges from 0 to 18, high to low.
  -
    type: b3
    doc: Currently unknown data.
  - id: mouth_type
    type: b5
    doc: Mouth type. Ranges from 0 to 23.
  - id: mouth_color
    type: b2
    doc: Mouth color. Ranges from 0 to 2.
  - id: mouth_size
    type: b4
    doc: Mouth size. Ranges from 0 to 8, small to large.
  - id: mouth_vertical
    type: b5
    doc: Mouth Y (vertical) position. Ranges from 0 to 18, high to low.
  - id: glasses_type
    type: b4
    doc: Glasses type. Ranges from 0 to 8.
  - id: glasses_color
    type: b3
    doc: Glasses color. Ranges from 0 to 5
  -
    type: b1
    doc: Currently unknown data. When enabled, mii does not appear.
  - id: glasses_size
    type: b3
    doc: Glasses size. Ranges from 0 to 7, small to large.
  - id: glasses_vertical
    type: b5
    doc: Glasses Y (vertical) position. Ranges from 0 to 20, high to low.
  - id: facial_hair_mustache
    type: b2
    doc: Mustache type. Ranges from 0 to 3.
  - id: facial_hair_beard
    type: b2
    doc: Beard type. Ranges from 0 to 3.
  - id: facial_hair_color
    type: b3
    doc: Facial hair color. Ranges from 0 to 7. Not ordered the same as visible in editor.
  - id: facial_hair_size
    type: b4
    doc: Mustache size. Ranges from 0 to 8, small to large.
  - id: facial_hair_vertical
    type: b5
    doc: Mustache Y (vertical) position. Ranges from 22 to 0, low to high.
  - id: is_mole_enabled
    type: b1
    doc: Enable beauty mark. 0 = no, 1 = yes.
  - id: mole_size
    type: b4
    doc: Beauty mark size. Ranges from 0 to 8, small to large.
  - id: mole_vertical
    type: b5
    doc: Beauty mark Y (vertical) position. Ranges from 30 to 0, low to high.
  - id: mole_horizontal
    type: b5
    doc: Beauty mark X (horizontal) position. Ranges from 0 to 16, left to right.
  -
    type: b1
    doc: Currently unknown data.
  - id: creator_name
    type: str
    size: 20
    encoding: utf-16be
    doc: Mii creator's name. Can be up to 10 characters long.
  - id: checksum
    type: u2
    if: not _io.eof
    doc: |
      The key difference between RCD and RSD files:
      RSD files contain a 2-byte CRC-16 CCITT checksum at the end.
      RCD files omit this checksum.
instances:
  mii_type:
    value: mii_id[0]
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
  months:
    0: january
    1: february
    2: march
    3: april
    4: may
    5: june
    6: july
    7: august
    8: september
    9: october
    10: november
    11: december
