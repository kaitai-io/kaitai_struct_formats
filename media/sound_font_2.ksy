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
  info_chunk: {}
  sdta_chunk: {}
  pdta_chunk: {}
