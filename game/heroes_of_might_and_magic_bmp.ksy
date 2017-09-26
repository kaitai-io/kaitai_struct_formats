meta:
  id: heroes_of_might_and_magic_bmp
  application: Heroes of Might and Magic
  file-extension: bmp
  license: CC0-1.0
  endian: le
seq:
  - id: magic
    type: u2
  - id: width
    type: u2
  - id: height
    type: u2
  - id: data
    size: 'width * height'
