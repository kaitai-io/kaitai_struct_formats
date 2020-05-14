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
  sdta_chunk:
    seq:
      - id: chunk_id
        contents: LIST
      - id: len_body
        type: u4
      - id: body
        type: sdta_chunk_data
        size: len_body
      - id: pad_byte
        size: len_body % 2
    types:
      sdta_chunk_data:
        seq:
          - id: form_type
            contents: sdta
          - id: smpl
            type: smpl_chunk
            if: is_smpl_present
          - id: sm24
            type: sm24_chunk
            if: is_sm24_present
        instances:
          is_smpl_present:
            value: not _io.eof
          is_sm24_present:
            value: not _io.eof
          is_valid:
            value: >-
              (not is_smpl_present or (smpl.len_body % 2) == 0)
              and (not is_sm24_present or (2 * sm24.len_body) == smpl.len_body)
        types:
          smpl_chunk:
            seq:
              - id: chunk_id
                contents: smpl
              - id: len_body
                type: u4
              - id: samples
                size: len_body
              - id: pad_byte
                size: len_body % 2
          sm24_chunk:
            seq:
              - id: chunk_id
                contents: sm24
              - id: len_body
                type: u4
              - id: samples
                size: len_body
              - id: pad_byte
                size: len_body % 2
  pdta_chunk:
    seq:
      - id: chunk_id
        contents: LIST
      - id: len_body
        type: u4
      - id: body
        type: pdta_chunk_data
        size: len_body
      - id: pad_byte
        size: len_body % 2
    types:
      pdta_chunk_data:
        seq:
          - id: form_type
            contents: pdta
          - id: presets
            type: phdr_chunk
          - id: preset_zones
            type: pbag_chunk
          - id: preset_mods
            type: pmod_chunk
          - id: preset_gens
            type: pgen_chunk
          - id: instruments
            type: inst_chunk
          - id: instrument_zones
            type: ibag_chunk
          - id: instrument_mods
            type: imod_chunk
          - id: instrument_gens
            type: igen_chunk
          - id: samples
            type: shdr_chunk
        types:
          phdr_chunk:
            seq:
              - id: chunk_id
                contents: phdr
              - id: len_body
                type: u4
              - id: body
                size: len_body
                type: phdr_chunk_data
              - id: pad_byte
                size: len_body % 2
            types:
              phdr_chunk_data:
                seq:
                  - id: records
                    type: preset_header
                    repeat: eos
              preset_header:
                seq:
                  - id: preset_name
                    size: 20
                    type: strz
                  - id: preset
                    type: u2
                    doc: MIDI preset number
                  - id: bank
                    type: u2
                    doc: MIDI bank number
                  - id: preset_bag_idx
                    type: u2
                  - id: library
                    type: u4
                  - id: genre
                    type: u4
                  - id: morphology
                    type: u4
          pbag_chunk:
            seq:
              - id: chunk_id
                contents: pbag
              - id: len_body
                type: u4
              - id: body
                size: len_body
                type: pbag_chunk_data
              - id: pad_byte
                size: len_body % 2
            types:
              pbag_chunk_data:
                seq:
                  - id: records
                    type: preset_bag
                    repeat: eos
              preset_bag:
                seq:
                  - id: gen_idx
                    type: u2
                  - id: mod_idx
                    type: u2
          pmod_chunk:
            seq:
              - id: chunk_id
                contents: pmod
              - id: len_body
                type: u4
              - id: body
                size: len_body
                type: pmod_chunk_data
              - id: pad_byte
                size: len_body % 2
            types:
              pmod_chunk_data: {}
          pgen_chunk:
            seq:
              - id: chunk_id
                contents: pgen
              - id: len_body
                type: u4
              - id: body
                size: len_body
                type: pgen_chunk_data
              - id: pad_byte
                size: len_body % 2
            types:
              pgen_chunk_data: {}
          inst_chunk:
            seq:
              - id: chunk_id
                contents: inst
              - id: len_body
                type: u4
              - id: body
                size: len_body
                type: inst_chunk_data
              - id: pad_byte
                size: len_body % 2
            types:
              inst_chunk_data: {}
          ibag_chunk:
            seq:
              - id: chunk_id
                contents: ibag
              - id: len_body
                type: u4
              - id: body
                size: len_body
                type: ibag_chunk_data
              - id: pad_byte
                size: len_body % 2
            types:
              ibag_chunk_data: {}
          imod_chunk:
            seq:
              - id: chunk_id
                contents: imod
              - id: len_body
                type: u4
              - id: body
                size: len_body
                type: imod_chunk_data
              - id: pad_byte
                size: len_body % 2
            types:
              imod_chunk_data: {}
          igen_chunk:
            seq:
              - id: chunk_id
                contents: igen
              - id: len_body
                type: u4
              - id: body
                size: len_body
                type: igen_chunk_data
              - id: pad_byte
                size: len_body % 2
            types:
              igen_chunk_data: {}
          shdr_chunk:
            seq:
              - id: chunk_id
                contents: shdr
              - id: len_body
                type: u4
              - id: body
                size: len_body
                type: shdr_chunk_data
              - id: pad_byte
                size: len_body % 2
            types:
              shdr_chunk_data: {}
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
