meta:
  id: png
  file-extension: png
  endian: be
seq:
  # https://www.w3.org/TR/PNG/#5PNG-file-signature
  - id: magic
    contents: [137, 80, 78, 71, 13, 10, 26, 10]
  - id: chunks
    type: chunk
    repeat: eos
types:
  chunk:
    seq:
      - id: len
        type: u4
      - id: type
        type: str
        size: 4
        encoding: UTF-8
      - id: body
        size: len
        type:
          switch-on: type
          cases:
            '"IHDR"': ihdr_chunk
            '"pHYs"': phys_chunk
            '"PLTE"': plte_chunk
            '"tIME"': time_chunk
      - id: crc
        size: 4
  # https://www.w3.org/TR/PNG/#11IHDR
  ihdr_chunk:
    seq:
      - id: width
        type: u4
      - id: height
        type: u4
      - id: bit_depth
        type: u1
      - id: color_type
        type: u1
        enum: color_type
      - id: compression_method
        type: u1
      - id: filter_method
        type: u1
      - id: interlace_method
        type: u1
  # https://www.w3.org/TR/PNG/#11pHYs
  phys_chunk:
    seq:
      - id: pixels_per_unit_x
        type: u4
      - id: pixels_per_unit_y
        type: u4
      - id: unit
        type: u1
        enum: phys_unit
  # https://www.w3.org/TR/PNG/#11tIME
  time_chunk:
    seq:
      - id: year
        type: u2
      - id: month
        type: u1
      - id: day
        type: u1
      - id: hour
        type: u1
      - id: minute
        type: u1
      - id: second
        type: u1
  # https://www.w3.org/TR/PNG/#11PLTE
  plte_chunk:
    seq:
      - id: entries
        type: rgb
        repeat: eos
  rgb:
    seq:
      - id: r
        type: u1
      - id: g
        type: u1
      - id: b
        type: u1
enums:
  color_type:
    0: greyscale
    2: truecolor
    3: indexed
    4: greyscale_alpha
    6: truecolor_alpha
  phys_unit:
    0: unknown
    1: meter
