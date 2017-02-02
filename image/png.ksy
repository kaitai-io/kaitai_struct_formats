meta:
  id: png
  file-extension: png
  endian: be
seq:
  # https://www.w3.org/TR/PNG/#5PNG-file-signature
  - id: magic
    contents: [137, 80, 78, 71, 13, 10, 26, 10]
  # https://www.w3.org/TR/PNG/#11IHDR
  # Always appears first, stores values referenced by other chunks
  - id: ihdr_len
    contents: [0, 0, 0, 13]
  - id: ihdr_type
    contents: "IHDR"
  - id: ihdr
    type: ihdr_chunk
  - id: ihdr_crc
    size: 4
  # The rest of the chunks
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
            # Critical chunks
            # '"IHDR"': ihdr_chunk
            '"PLTE"': plte_chunk
            # IDAT = raw
            # IEND = empty, thus raw

            # Ancillary chunks
            '"cHRM"': chrm_chunk
            '"gAMA"': gama_chunk
            # iCCP
            # sBIT
            '"sRGB"': srgb_chunk
            '"bKGD"': bkgd_chunk
            # hIST
            # tRNS
            '"pHYs"': phys_chunk
            # sPLT
            '"tIME"': time_chunk
            '"iTXt"': international_text_chunk
            '"tEXt"': text_chunk
            '"zTXt"': compressed_text_chunk
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
  # https://www.w3.org/TR/PNG/#11cHRM
  chrm_chunk:
    seq:
      - id: white_point
        type: point
      - id: red
        type: point
      - id: green
        type: point
      - id: blue
        type: point
  point:
    seq:
      - id: x_int
        type: u4
      - id: y_int
        type: u4
    instances:
      x:
        value: x_int / 100000.0
      y:
        value: y_int / 100000.0
  # https://www.w3.org/TR/PNG/#11gAMA
  gama_chunk:
    seq:
      - id: gamma_int
        type: u4
    instances:
      gamma_ratio:
        value: 100000.0 / gamma_int
  # https://www.w3.org/TR/PNG/#11sRGB
  srgb_chunk:
    seq:
      - id: render_intent
        type: u1
        enum: intent
    enums:
      intent:
        0: perceptual
        1: relative_colorimetric
        2: saturation
        3: absolute_colorimetric
  # https://www.w3.org/TR/PNG/#11bKGD
  bkgd_chunk:
    seq:
      - id: bkgd
        type:
          switch-on: _root.ihdr.color_type
          cases:
            color_type::greyscale: bkgd_greyscale
            color_type::greyscale_alpha: bkgd_greyscale
            color_type::truecolor: bkgd_truecolor
            color_type::truecolor_alpha: bkgd_truecolor
            color_type::indexed: bkgd_indexed
  bkgd_greyscale:
    seq:
      - id: value
        type: u2
  bkgd_truecolor:
    seq:
      - id: red
        type: u2
      - id: green
        type: u2
      - id: blue
        type: u2
  bkgd_indexed:
    seq:
      - id: palette_index
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
  # https://www.w3.org/TR/PNG/#11iTXt
  international_text_chunk:
    seq:
      - id: keyword
        type: strz
        encoding: UTF-8
      - id: compression_flag
        type: u1
      - id: compression_method
        type: u1
      - id: language_tag
        type: strz
        encoding: ASCII
      - id: translated_keyword
        type: strz
        encoding: UTF-8
      - id: text
        type: str
        encoding: UTF-8
        size-eos: true
  # https://www.w3.org/TR/PNG/#11tEXt
  text_chunk:
    seq:
      - id: keyword
        type: strz
        encoding: iso8859-1
      - id: text
        type: str
        size-eos: true
        encoding: iso8859-1
  # https://www.w3.org/TR/PNG/#11zTXt
  compressed_text_chunk:
    seq:
      - id: keyword
        type: strz
        encoding: UTF-8
      - id: compression_method
        type: u1
      - id: text_datastream
        process: zlib
        size-eos: true
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
