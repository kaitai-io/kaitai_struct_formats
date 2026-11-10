meta:
  id: rv565
  title: RV565 frame-independent RGB565 video
  application: RV565 (https://github.com/elixpo/rv565)
  file-extension: rv565
  xref:
    mime: video/x-rv565
  license: CC0-1.0
  ks-version: 0.9
  endian: le
doc: |
  RV565 is a video container for microcontrollers that drive RGB565 SPI
  displays such as the ST7789. A 12-byte header is followed by one record
  per frame: a 32-bit payload length and a zlib stream (RFC 1950) that
  inflates to exactly width * height * 2 bytes of big-endian RGB565 pixels,
  row-major, top to bottom. Frames share no state, so any frame decodes on
  its own. There is no audio. The file ends exactly after the last record.
doc-ref:
  - https://github.com/elixpo/rv565/blob/main/docs/FORMAT.md
  - https://arxiv.org/abs/2610.35935
seq:
  - id: magic
    contents: RV5
  - id: version
    type: u1
    valid: 6
  - id: width
    type: u2
    valid:
      min: 1
  - id: height
    type: u2
    valid:
      min: 1
  - id: fps
    type: u1
    valid:
      min: 1
      max: 30
    doc: Frames per second.
  - id: flags
    type: u1
    doc: 0 in version 6; readers must ignore unknown bits.
  - id: num_frames
    type: u2
    valid:
      min: 1
  - id: frames
    type: frame
    repeat: expr
    repeat-expr: num_frames
types:
  frame:
    seq:
      - id: len_payload
        type: u4
        valid:
          min: 1
      - id: payload
        size: len_payload
        process: zlib
        doc: |
          Inflated: exactly 2 * width * height bytes, each pixel a
          big-endian u2 (r5 << 11) | (g6 << 5) | b5.
