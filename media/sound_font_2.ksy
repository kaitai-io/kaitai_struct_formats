meta:
  id: sound_font_2
  title: SoundFont 2
  file-extension: sf2
  endian: le
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
                'fourcc::ifil': fmt_version
                'fourcc::isng': sound_engine
                'fourcc::inam': bank_name
                'fourcc::irom': sound_rom_name
                'fourcc::iver': sound_rom_version
                'fourcc::icrd': date_created
                'fourcc::ieng': file_engineers
                'fourcc::iprd': product
                'fourcc::icop': copyright
                'fourcc::icmt': comment
                'fourcc::isft': tools
            size: len_body
          - id: pad_byte
            size: len_body % 2
        types:
          fmt_version: {}
          sound_engine: {}
          bank_name: {}
          sound_rom_name: {}
          sound_rom_version: {}
          date_created: {}
          file_engineers: {}
          product: {}
          copyright: {}
          comment: {}
          tools: {}
  sdta_chunk: {}
  pdta_chunk: {}
enums:
  fourcc:
    0x6c696669: ifil
    0x676e7369: isng
    0x6d6f7269: irom
    0x72657669: iver
    0x4d414e49: inam
    0x44524349: icrd
    0x474e4549: ieng
    0x44525049: iprd
    0x504f4349: icop
    0x544d4349: icmt
    0x54465349: isft
