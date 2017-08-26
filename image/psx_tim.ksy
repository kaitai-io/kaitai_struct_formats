# http://fileformats.archiveteam.org/wiki/TIM_(PlayStation_graphics)
# http://mrclick.zophar.net/TilEd/download/timgfx.txt
# http://www.romhacking.net/documents/31/
meta:
  id: psx_tim
  endian: le
  file-extension: tim
  application: Sony PlayStation (PSX) typical image format
seq:
  - id: magic
    contents: [0x10, 0, 0, 0]
  - id: flags
    type: u4
    doc: Encodes bits-per-pixel and whether CLUT is present in a file or not
  - id: clut
    type: bitmap
    if: has_clut
    doc: CLUT (Color LookUp Table), one or several palettes for indexed color image, represented as a 
  - id: img
    type: bitmap
types:
  bitmap:
    seq:
      - id: len
        type: u4
      - id: origin_x
        type: u2
      - id: origin_y
        type: u2
      - id: width
        type: u2
      - id: height
        type: u2
      - id: body
        size: len - 12 # 4 + 4 * 2
instances:
  has_clut:
    value: flags & 0b1000 != 0
  bpp:
    value: flags & 0b0011
enums:
  bpp_type:
    0: bpp_4
    1: bpp_8
    2: bpp_16
    3: bpp_24
