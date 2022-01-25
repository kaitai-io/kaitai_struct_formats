meta:
  id: flv
  title: Adobe Flash Video File Format
  license: CC0-1.0
  ks-version: 0.9
  encoding: utf-8
  endian: be
doc-ref: https://wwwimages2.adobe.com/content/dam/acom/en/devnet/flv/video_file_format_spec_v10_1.pdf
seq:
  - id: preheader
    type: preheader
  - id: rest_of_header
    size: preheader.len_header - preheader._sizeof
  - id: previous_tag_size0
    type: u4
    valid: 0
  - id: tags
    type: tag_and_size
    repeat: eos
types:
  preheader:
    seq:
      - id: magic
        contents: 'FLV'
      - id: version
        type: u1
        valid: 1
      - id: flags
        type: flags
      - id: len_header
        type: u4
  flags:
    seq:
      - id: reserved
        type: b5
      - id: audio
        type: b1
      - id: reserved2
        type: b1
      - id: video
        type: b1
  tag_and_size:
    seq:
      - id: tag
        type: tag
      - id: previous_tag_size
        type: u4
        valid: tag.len_data + 11
  tag:
    seq:
      - id: reserved
        type: b2
      - id: filter
        type: b1
      - id: type
        type: b5
        enum: data_type
      - id: len_data
        type: b24
      - id: timestamp
        type: b24
      - id: timestamp_extended
        type: u1
      - id: stream_id
        type: b24
        valid: 0
      - id: data
        size: len_data
enums:
  data_type:
    8: audio
    9: video
    18: script
