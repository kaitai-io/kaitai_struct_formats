meta:
  id: mii_data_wiiu_3ds
  application: Wii U and 3DS
  endian: le
seq:
  - id: format_version
    type: u1
    doc: Mii data file format version. Of course, this number is always the same, since this value is only here in Wii U/3DS format. Thus, always 3.
  - id: copying
    type: b1le
    doc: Enable Copying. This allows any non-owners of the Mii to make a copy of the Mii and edit the copy, if enabled. 0 = Copying disabled, 1 = Copying enabled. Default: 0.
  - id: profanity
    type: b1le
    doc: If the Mii's name or creator name contains any words deemed profane, this bit will be set to 1, and both the Mii name and creator name get replaced by "???".
  - id: region_lock
    type: b2le
    enum: region
    doc: Determines if the Mii's QR code can only be scanned on devices of a certain region. 0 = no lock, 1 = JPN, 2 = USA, 3 = PAL.
  - id: font_region
    type: b2le
    enum: region_text
    doc: The font region for the Mii name and creator name. For Wii U/3DS, viewing text of a font region different from the device's region will result in the text being replaced by "???". 0 = USA + PAL + JPN, 1 = CHN, 2 = KOR, 3 = TWN.
  - id: reserved_00
    type: b2le
    doc: These two bits are reserved. They should be set to 0.
  - id: position_page
    type: b4le
    doc: Determines what page of the 3DS Mii Maker that the Mii resides in. Ranges from 0 to 9. Wii U usage unclear currently.
  - id: position_slot
    type: b4le
    doc: Determines what slot of the 3DS Mii Maker page that the Mii resides in. Ranges from 0 to 9. Wii U usage unclear currently.
  - id: unknown_0
    type: b4le
    doc: These four bits are currently unknown. They should be set to 0.
  - id: original_creation_device
    type: b3le
    enum: creation_device
    doc: The device in which the Mii was originally made on. 1 = Wii, 2 = DS, 3 = 3DS, 4 = Wii U/Switch. Setting this value to anything else will result in an invalid Mii.
  - id: reserved_01
    type: b1le
    doc: This bit is reserved. It should be set to 0.
  - id: console_id
    type: u8
    doc: Unique to every Wii U and 3DS. Two Miis with different console IDs were made on different systems.
  - id: mii_id
    type: mii_id_contents
    doc: Four bytes (theoretically) unique to every Mii.
  - id: console_mac
    size: 6
    doc: Six bytes representing the full MAC address of the device the Mii was created on. (It's u2 repeated 3 times because I tried u6 and u3(2) but neither of them are valid types, apparently?)
  - id: reserved_02
    type: u2
    doc: These two bytes are reserved. They should be set to 0.
  - id: sex
    type: b1le
    doc: The Mii's sex, male or female. 0 = male, 1 = female.
  - id: birthday_month
    type: b4le
    doc: The month of the Mii's birthday, ranging from 0 to 12. 0 = no birthday set. Default: 0.
  - id: birthday_day
    type: b5le
    doc: The day of the Mii's birthday, ranging from 0 to 31. 0 = no birthday set. Default: 0.
  - id: favorite_color
    type: b4le
    enum: fav_colors
    doc: The Mii's favorite color, ranging from 0 to 11. The same order as it appears in-editor. Default: 0.
  - id: is_favorite
    type: b1le
    doc: Determines if a Mii is considered a Favorite (red pants). Favorite Miis appear in games more often. Up to 10 Favorites are allowed on 3DS and Wii U. 0 = not Favorited, 1 = is Favorited. Default: 0.
  - id: unknown_2
    type: b1le
    doc: This bit is currently unknown. It should be set to 0, in most common use cases.
  - id: mii_name
    type: str
    size: 20
    encoding: utf-16le
    doc: The Mii's name (sometimes referred to as "nickname"). Up to 10 characters supported. Terminated by two 0x00 bytes in a row. (I would implement this in the Kaitai, but I don't know how to make it terminate by two bytes)
  - id: height
    type: u1
    doc: The Mii's height. Ranges from 0 to 127. Default: 64.
  - id: build
    type: u1
    doc: The Mii's build. Ranges from 0 to 127. Default: 64.
  - id: head
    type: head_data
    doc: The information relating to the Mii's head and skin: face type, skin color, wrinkles, and makeup. Also includes the option for Sharing because I couldn't figure out how to make it work where some bits are part of these groups and others aren't lol
  - id: hair
    type: hair_data
    doc: The information relating to the Mii's hair: hair type, hair color, whether or not the hair is flipped, and four reserved bits.
  - id: eyes
    type: eye_data
    doc: The information relating to the Mii's eyes: eye type, color, size, stretch, rotation, X, Y, and two reserved bits.
  - id: eyebrows
    type: eyebrow_data
    doc: The information relating to the Mii's eyebrows: eyebrow type, color, size, stretch, rotation, X, Y, and four reserved bits.
  - id: nose
    type: nose_data
    doc: The information relating to the Mii's nose: nose type, size, Y, and two reserved bits.
  - id: mouth
    type: mouth_data
    doc: The information relating to the Mii's mouth: mouth type, color, size, stretch, and Y.
  - id: facial_hair
    type: facial_hair_data
    doc: The information relating to the Mii's facial hair: mustache type, beard type, facial hair color, mustache size, mustache Y, and seven reserved bits.
  - id: glasses
    type: glasses_data
    doc: The information relating to the Mii's glasses: glasses type, color, size, and Y.
  - id: mole
    type: mole_data
    doc: The information relating to the Mii's mole: mole enable, size, X, Y, and an reserved bit.
  - id: creator_name
    type: str
    size: 20
    encoding: utf-16le
    doc: The Mii's creator name (that's you!). Up to 10 characters supported. Terminated by two 0x00 bytes in a row. (I would implement this in the Kaitai, but I don't know how to make it terminate by two bytes)
  - id: reserved_12
    type: u2
    doc: These two bytes are reserved. They should be set to 0. NOTE: This only applies to (C/F)FSD files; (C/F)FCD files do not contain these two bytes.
  - id: checksum
    type: u2
    doc: The Mii data file from 0x00 to 0x5C in a crc32 checksum. NOTE: This only applies to (C/F)FSD files; (C/F)FCD files do not contain these two bytes.
types:
  mii_id_contents:
    seq:
      - id: is_not_special
        type: b1be
        doc: Determines if the Mii is Special (golden pants) or not. Special Miis are meant to only be created and distributed by Nintendo. 0 = Special, 1 = not Special.
      - id: unknown_1
        type: b1be
        doc: This bit is currently unknown. It should be set to 0, in most common use cases. Some documentation says only "is DSi Mii?" which doesn't seem right.
      - id: is_developer_mii
        type: b1be
        doc: Randomly generated Miis that games create at runtime that only get stored in RAM, or Miis made on a developer unit to only be used in games and applications. If this is set to 1, all other bits in the Mii ID contents should be set to 0.
      - id: is_valid
        type: b1be
        doc: Determines if the Mii is valid. Mii will be considered invalid if this bit is not set to 1.
      - id: creation_time
        type: b28be
        doc: Creation time in seconds since January 1st, 2010, 00:00:00, multiplied by 2. Takes the system time of when the Mii was created.
  head_data:
    seq:
      - id: not_sharing
        type: b1le
        doc: Disable Sharing. Enabling this allows the Mii to travel to others' systems via StreetPass. 0 = Sharing enabled, 1 = Sharing disabled. Default: 1.
      - id: face_type
        type: b4le
        doc: Face type. Ranges from 0 to 11. Not ordered the same as displayed in editor. Default: 0.
      - id: skin_color
        type: b3le
        doc: Skin color. Ranges from 0 to 5. Same order as displayed in editor. Default: 0.
      - id: face_wrinkles
        type: b4le
        doc: Face wrinkles. Ranges from 0 to 11. Same order as displayed in editor, top to bottom. Default: 0.
      - id: face_makeup
        type: b4le
        doc: Face makeup. Ranges from 0 to 11. Same order as displayed in editor, top to bottom. Default: 0.
  hair_data:
    seq:
      - id: hair_type
        type: u1
        doc: Hair type. Ranges from 0 to 131. Not ordered the same as displayed in editor. Default depends on sex initally selected when creating the Mii.
      - id: hair_color
        type: b3le
        doc: Hair color. Ranges from 0 to 7. Same order as displayed in editor, top to bottom. Default: 1.
      - id: hair_flip
        type: b1le
        doc: Flip hair. 0 = no, 1 = yes. Default: 0.
      - id: reserved_03
        type: b4le
        doc: These four bits are reserved. They should be set to 0.
  eye_data:
    seq:
      - id: eye_type
        type: b6le
        doc: Eye type. Ranges from 0 to 59. Not ordered the same as displayed in editor. Default depends on sex initally selected when creating the Mii.
      - id: eye_color
        type: b3le
        doc: Eye color. Ranges from 0 to 5. Same order as displayed in editor, top to bottom. Default: 0.
      - id: eye_size
        type: b4le
        doc: Eye size. Ranges from 0 to 7, smallest to largest. Default: 4.
      - id: eye_stretch
        type: b3le
        doc: Eye stretch. Ranges from 0 to 6, smallest to largest. Default: 3.
      - id: eye_rotation
        type: b5le
        doc: Eye rotation. Ranges from 0 to 7, down to up. Default depends on eye type.
      - id: eye_horizontal
        type: b4le
        doc: Eye X (horizontal) distance. Ranges from 0 to 12, close to far. Default: 2.
      - id: eye_vertical
        type: b5le
        doc: Eye Y (vertical) position. Ranges from 0 to 18, high to low. Default: 12.
      - id: reserved_04
        type: b2le
        doc: These two bits are reserved. They should be set to 0.
  eyebrow_data:
    seq:
      - id: eyebrow_type
        type: b5le
        doc: Eyebrow type. Ranges from 0 to 24. Not ordered the same as displayed in editor. Default depends on sex initally selected when creating the Mii.
      - id: eyebrow_color
        type: b3le
        doc: Eyebrow color. Ranges from 0 to 7. Same order as displayed in editor, top to bottom. Default: 1.
      - id: eyebrow_size
        type: b4le
        doc: Eyebrow size. Ranges from 0 to 8, smallest to largest. Default: 4.
      - id: eyebrow_stretch
        type: b3le
        doc: Eyebrow stretch. Ranges from 0 to 6, smallest to largest. Default: 3.
      - id: reserved_05
        type: b1le
        doc: This bit is reserved. It should be set to 0.
      - id: eyebrow_rotation
        type: b4le
        doc: Eyebrow rotation. Ranges from 0 to 11, down to up. Default depends on eyebrow type.
      - id: reserved_06
        type: b1le
        doc: This bit is reserved. It should be set to 0.
      - id: eyebrow_horizontal
        type: b4le
        doc: Eyebrow X (horizontal) distance. Ranges from 0 to 12, close to far. Default: 2.
      - id: eyebrow_vertical
        type: b5le
        doc: Eyebrow Y (vertical) position. Ranges from 3 to 18, high to low. Default: 10.
      - id: reserved_07
        type: b2le
        doc: These two bits are reserved. They should be set to 0.
  nose_data:
    seq:
      - id: nose_type
        type: b5le
        doc: Nose type. Ranges from 0 to 17. Not ordered the same as displayed in editor. Default: 1.
      - id: nose_size
        type: b4le
        doc: Nose size. Ranges from 0 to 8, small to large. Default: 4.
      - id: nose_vertical
        type: b5le
        doc: Nose Y (vertical) position. Ranges from 0 to 18, high to low. Default: 9.
      - id: reserved_08
        type: b2le
        doc: These two bits are reserved. They should be set to 0.
  mouth_data:
    seq:
      - id: mouth_type
        type: b6le
        doc: Mouth type. Ranges from 0 to 35. Not ordered the same as displayed in editor. Default: 23.
      - id: mouth_color
        type: b3le
        doc: Mouth (lipstick) color. Ranges from 0 to 4. Same order as displayed in editor, top to bottom. Default: 0.
      - id: mouth_size
        type: b4le
        doc: Mouth size. Ranges from 0 to 8, small to large. Default: 4.
      - id: mouth_stretch
        type: b3le
        doc: Mouth stretch. Ranges from 0 to 6, small to large. Default: 3.
      - id: mouth_vertical
        type: b5le
        doc: Mouth Y (vertical) position. Ranges from 0 to 18, high to low. Default: 13.
  facial_hair_data:
    seq:
      - id: facial_hair_mustache
        type: b5le
        doc: Mustache type. Ranges from 0 to 5. Same order as displayed in editor. Default: 0.
      - id: reserved_09
        type: b6le
        doc: These six bits are reserved. They should be set to 0.
      - id: facial_hair_beard
        type: b3le
        doc: Beard type. Ranges from 0 to 5. Same order as displayed in editor. Default: 0.
      - id: facial_hair_color
        type: b3le
        doc: Facial hair color (both beard and mustache). Ranges from 0 to 7. Same order as displayed in editor, top to bottom. Default: 0.
      - id: facial_hair_size
        type: b4le
        doc: Mustache size. Ranges from 0 to 8, small to large. Default: 4.
      - id: facial_hair_vertical
        type: b5le
        doc: Mustache Y (vertical) position. Ranges from 0 to 16, high to low. Default: 10.
      - id: reserved_10
        type: b1le
        doc: This bit is reserved. It should be set to 0.
  glasses_data:
    seq:
      - id: glasses_type
        type: b4le
        doc: Glasses type. Ranges from 0 to 8. Same order as displayed in editor. Default: 0.
      - id: glasses_color
        type: b3le
        doc: Glasses color. Ranges from 0 to 5. Same order as displayed in editor, top to bottom. Default: 0.
      - id: glasses_size
        type: b4le
        doc: Glasses size. Ranges from 0 to 7, small to large. Default: 4.
      - id: glasses_vertical
        type: b5le
        doc: Glasses Y (vertical) position. Ranges from 0 to 20, high to low. Default: 10.
  mole_data:
    seq:
      - id: mole_type
        type: b1le
        doc: Mole enable. 0 = disable mole, 1 = enable mole. Default: 0.
      - id: mole_size
        type: b4le
        doc: Mole size. Ranges from 0 to 8, small to large. Default: 4.
      - id: mole_horizontal
        type: b5le
        doc: Mole X (horizontal) position. Ranges from 0 to 16, left to right. Default: 2.
      - id: mole_vertical
        type: b5le
        doc: Mole Y (vertical) position. Ranges from 0 to 30, high to low. Default: 20.
      - id: reserved_11
        type: b1le
        doc: This bit is reserved. It should be set to 0.
enums:
  creation_device:
    1: wii
    2: ds
    3: n3ds
    4: wiiu_switch
  fav_colors:
    0: red
    1: orange
    2: yellow
    3: lime_green
    4: forest_green
    5: royal_blue
    6: sky_blue
    7: pink
    8: purple
    9: brown
    10: white
    11: black
  region:
    0: no_lock
    1: jpn
    2: usa
    3: pal
  region_text:
    0: jpn_usa_pal
    1: chn
    2: kor
    3: twn
