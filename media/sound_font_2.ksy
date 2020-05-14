meta:
  id: sound_font_2
  title: SoundFont 2
  file-extension: sf2
  endian: le
  encoding: UTF-8 # though stated ASCII in the spec, UTF-8 is likely to be used as well
seq:
  - id: chunk
    type: riff_chunk
types:
  riff_chunk:
    seq:
      - id: chunk_id
        contents: RIFF
      - id: len_body
        type: u4
      - id: body
        type: sfbk_chunk_data
        size: len_body
      - id: pad_byte
        size: len_body % 2
    types:
      sfbk_chunk_data:
        seq:
          - id: form_type
            contents: sfbk
          - id: info
            type: info_chunk
          - id: sample_data
            type: sdta_chunk
          - id: preset_data
            type: pdta_chunk
  info_chunk:
    seq:
      - id: chunk_id
        contents: LIST
      - id: len_body
        type: u4
      - id: body
        type: info_chunk_data
        size: len_body
      - id: pad_byte
        size: len_body % 2
    types:
      info_chunk_data:
        seq:
          - id: form_type
            contents: INFO
          - id: subchunks
            type: info_subchunk
            repeat: eos
      info_subchunk:
        seq:
          - id: chunk_id
            type: u4
            enum: fourcc
          - id: len_body
            type: u4
          - id: body
            type:
              switch-on: chunk_id
              cases:
                'fourcc::ifil': version_tag
                'fourcc::isng': strz
                'fourcc::inam': strz
                'fourcc::irom': strz
                'fourcc::iver': version_tag
                'fourcc::icrd': strz
                'fourcc::ieng': strz
                'fourcc::iprd': strz
                'fourcc::icop': strz
                'fourcc::icmt': strz
                'fourcc::isft': strz
            size: len_body
          - id: pad_byte
            size: len_body % 2
        types:
          version_tag:
            seq:
              - id: major
                type: u2
              - id: minor
                type: u2
  sdta_chunk: {}
  pdta_chunk: {}
enums:
  fourcc:
    0x6c696669:
      id: ifil
      doc: SoundFont specification version
    0x676e7369:
      id: isng
      doc: |
        wavetable sound engine for which the file was optimized
        default is "EMU8000"
    0x6d6f7269:
      id: irom
      doc: wavetable sound data ROM to which any ROM samples refer
    0x72657669:
      id: iver
      doc: wavetable sound data ROM revision to which any ROM samples refer
    0x4d414e49:
      id: inam
      doc: name
    0x44524349:
      id: icrd
      doc: creation date
    0x474e4549:
      id: ieng
      doc: engineer
    0x44525049:
      id: iprd
      doc: product for which the bank is intended
    0x504f4349:
      id: icop
      doc: copyright
    0x544d4349:
      id: icmt
      doc: comments
    0x54465349:
      id: isft
      doc: software
