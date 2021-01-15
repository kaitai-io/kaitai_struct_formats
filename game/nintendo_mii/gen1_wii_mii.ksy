meta:
  id: gen1_wii_mii
  file-extension:
    - mii
    - mae
    - miigx
    - rcd
    - rsd
  endian: be
seq:
  - id: invalid
    type: b1
    doc: Has no apparent effect.
  - id: gender
    type: b1
    doc: Mii gender. 0 = male, 1 = female.
  - id: birth_month
    type: b4
    doc: Mii birthday month, Ranges from 1 to 12
  - id: birth_day
    type: b5
    doc: Mii birthday day, Ranges from 1 to 31
  - id: favorite_color
    type: b4
    doc: Favorite color. Ranges from 0 to 11.
  - id: favorite
    type: b1
    doc: Whether the Mii is a favorite or not.
  - id: mii_name
    type: str
    size: 20
    doc: Mii name. Can be up to 10 characters long.
    encoding: utf-16
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
    doc: Unique Mii identifier. Also governs color of Mii's pants
  - id: console_id
    type: u1
    repeat: expr
    repeat-expr: 4
    doc: Unique identifier for the console the Mii was created on. Consists of a checksum of the first 3 bytes of the console's mac address, followed by the last 3 bytes of the console's mac address
  - id: face_type
    type: b3
    doc: Face shape. Ranges from 0 to 11. Not ordered the same as visible in editor.
  - id: face_color
    type: b3
    doc: Skin color. Ranges from 0 to 9. Not ordered the same as visible in editor. A map of the internal values in correlation to the Mii editor is at /maps.txt/{skin}.
  - id: facial_feature
    type: b4
    doc: Facial feature. Ranges from 0 to 11.
  - id: unknown
    type: b3
    doc: Currently unknown data.
  - id: no_mingle
    type: b1
    doc: Whether the Mii was allowed to travel to other consoles via WiiConnect24. 0 = yes, 1 = no.
  - id: unknown_2
    type: 
    doc: Currently unknown data.
  - id: downloaded
    type: b1
    doc: Whether the Mii was downloaded from the Check Mii Out channel.
  - id: hair_type
    type: b7
    doc: Hair type. Ranges from 0 to 71. Not ordered the same as visible in editor.
  - id: hair_color
    type: b3
    doc: Hair color. Ranges from 0 to 7. Not ordered the same as visible in editor.
  - id: hair_flip
    type: b1
    doc: Flip hair. 0 = no, 1 = yes.
  - id: unknown_3
    type: b5
    doc: Currently unknown data.
  - id: eyebrow_type
    type: b5
    doc: Eyebrow type. Ranges from 0 to 23. Not ordered the same as visible in editor.
  - id: unknown_4
    type: b1
    doc: Currently unknown data.
  - id: eyebrow_rotation
    type: b4
    doc: Eyebrow rotation. Ranges from 0 to 11, down to up. Note that some eye types have a default rotation.
  - id: unknown_5
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
  - id: unknown_6
    type: b2
    doc: Currently unknown data.
  - id: eye_rotation
    type: b3
  - id: eye_vertical
    type: b5
    doc: Eye Y (vertical) position. Ranges from 0 to 18, high to low.
  - id: eye_color
    type: b3
    doc: Eye color. Ranges from 0 to 5. Not ordered the same as visible in editor.
  - id: unknown_7
    type: b1
    doc: Currently unknown data.
  - id: eye_size
    type: b3
    doc: Eye size. Ranges from 0 to 7, small to big.
  - id: eye_horizontal
    type: b4
    doc: Eye X (horizontal) distance. Ranges from 0 to 12, close to far.
  - id: unknown_8
    type: b5
    doc: Currently unknown data.
  - id: nose_type
    type: b4
    doc: Nose type. Ranges from 0 to 17. Not ordered the same as visible in editor. A map of the internal values in correlation to the Mii editor is at /maps.txt/{nose}.
  - id: nose_size
    type: b4
    doc: Nose size. Ranges from 0 to 8, small to big.
  - id: nose_vertical
    type: b5
    doc: Nose Y (vertical) position. Ranges from 18 to 0, low to high.
  - id: unknown_9
    type: b3
  - id: mouth_type
    type: b5
    doc: Mouth type. Ranges from 0 to 35. Not ordered the same as visible in editor. A map of the internal values in correlation to the Mii editor is at /maps.txt/{mouth}.
  - id: mouth_color
    type: b2
    doc: Mouth color. The default colors are ordered the same as visible in editor, ranging from 19 to 23. The custom colors are not and range from 0 to 99. A map of the internal values in correlation to the Mii editor is at /maps.txt/{colors} for custom colors.
  - id: mouth_size
    type: b4
    doc: Mouth size. Ranges from 0 to 8, small to large.
  - id: mouth_vertical
    type: b5
    doc: Mouth Y (vertical) position. Ranges from 18 to 0, low to high.
  - id: glasses_type
    type: b4
    doc: Glasses type. Ranges from 0 to 19. Not ordered the same as visible in editor. A map of the internal values in correlation to the Mii editor is at /maps.txt/{glasses}.
  - id: glasses_color
    type: b3
    doc: Glasses color. Ranges from 0 to 99. Not ordered the same as visible in editor. A map of the internal values in correlation to the Mii editor is at /maps.txt/{glasses-color} for default colors and /maps.txt/{colors} for custom colors.
  - id: unknown_10
    type: b1
    doc: Currently unknown data.
  - id: glasses_size
    type: b3
    doc: Glasses size. Ranges from 0 to 7, small to large.
  - id: glasses_vertical
    type: b5
    doc: Glasses Y (vertical) position. Ranges from 20 to 0, low to high.
  - id: facial_hair_mustache
    type: b2
  - id: facial_hair_beard
    type: b2
  - id: facial_hair_color
    type: b3
  - id: facial_hair_size
    type: b4
  - id: facial_hair_vertical
    type: b5
  - id: mole_enable
    type: b1
  - id: mole_size
    type: b4
  - id: mole_vertical
    type: b5
  - id: mole_horizontal
    type: b5
  - id: unknown_11
    size: 1
    doc: Currently unknown data.
  - id: creator_name
    type: str
    size: 20
    encoding: utf-16
