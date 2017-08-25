# Temporary solution, see this -> https://github.com/kaitai-io/kaitai_struct/issues/17
meta:
  id: exif
  imports:
    - exif_le
    - exif_be
seq:
  - id: endianness
    type: u2le
  - id: body
    type:
      switch-on: endianness
      cases:
        0x4949: exif_le
        0x4d4d: exif_be
