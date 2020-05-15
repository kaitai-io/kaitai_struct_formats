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
                type: samples_type
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
                type: samples_type
                size: len_body
              - id: pad_byte
                size: len_body % 2
          samples_type: {}
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
              pmod_chunk_data:
                seq:
                  - id: records
                    type: preset_mod
                    repeat: eos
              preset_mod:
                seq:
                  - id: mod_src_oper
                    type: modulator
                  - id: mod_dest_oper
                    type: u2
                    enum: generator
                  - id: mod_amount
                    type: s2
                  - id: mod_amt_src_oper
                    type: modulator
                  - id: mod_trans_oper
                    type: u2
                    enum: transform
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
              pgen_chunk_data:
                seq:
                  - id: records
                    type: preset_gen
                    repeat: eos
              preset_gen:
                seq:
                  - id: gen_oper
                    type: u2
                    enum: generator
                  - id: gen_amount
                    size: 2
                    type: gen_amount_type
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
          modulator:
            meta:
              bit-endian: le
            seq:
              - id: cntrl_src_idx
                type: b7
                doc: don't read this, access cntrl_src_general and cntrl_src_midi instead
              - id: is_cntlr_cont
                type: b1
                doc: MIDI continuous controller flag
              - id: direction
                type: b1
                enum: src_direction
              - id: polarity
                type: b1
                enum: src_polarity
              - id: type
                type: b6
                enum: src_type
            instances:
              cntrl_src_general:
                value: cntrl_src_idx
                enum: src_cntrl_general
                if: not is_cntlr_cont
              cntrl_src_midi:
                value: cntrl_src_idx
                if: is_cntlr_cont
            enums:
              src_cntrl_general:
                0: no_controller
                2: note_on_velocity
                3: note_on_keynum
                10: poly_pressure
                13: channel_pressure
                14: pitch_wheel
                16: pitch_wheel_sensitivity
                127: link
              src_direction:
                0: min_max
                1: max_min
              src_polarity:
                0:
                  id: unipolar
                  doc: from 0 to 1
                1:
                  id: bipolar
                  doc: from -1 to 1
              src_type:
                0: linear
                1: concave
                2: convex
                3: switch
          gen_amount_type:
            doc: |
              must be used in a substream `size: 2`
            seq:
              - id: as_signed # declared as most common in the spec
                type: s2
            instances:
              as_range:
                pos: 0
                type: ranges_type
              as_unsigned:
                pos: 0
                type: u2
            types:
              ranges_type:
                seq:
                  - id: low
                    type: u1
                  - id: high
                    type: u1
        enums:
          generator:
            0: start_addrs_offset
            1: end_addrs_offset
            2: startloop_addrs_offset
            3: endloop_addrs_offset
            4: start_addrs_coarse_offset
            5: mod_lfo_to_pitch
            6: vib_lfo_to_pitch
            7: mod_env_to_pitch
            8: initial_filter_fc
            9: initial_filter_q
            10: mod_lfo_to_filter_fc
            11: mod_env_to_filter_fc
            12: end_addrs_coarse_offset
            13: mod_lfo_to_volume
            14: unused1
            15: chorus_effects_send
            16: reverb_effects_send
            17: pan
            18: unused2
            19: unused3
            20: unused4
            21: delay_mod_lf_o
            22: freq_mod_lf_o
            23: delay_vib_lf_o
            24: freq_vib_lf_o
            25: delay_mod_env
            26: attack_mod_env
            27: hold_mod_env
            28: decay_mod_env
            29: sustain_mod_env
            30: release_mod_env
            31: keynum_to_mod_env_hold
            32: keynum_to_mod_env_decay
            33: delay_vol_env
            34: attack_vol_env
            35: hold_vol_env
            36: decay_vol_env
            37: sustain_vol_env
            38: release_vol_env
            39: keynum_to_vol_env_hold
            40: keynum_to_vol_env_decay
            41: instrument
            42: reserved1
            43: key_range
            44: vel_range
            45: startloop_addrs_coarse_offset
            46: keynum
            47: velocity
            48: initial_attenuation
            49: reserved2
            50: endloop_addrs_coarse_offset
            51: coarse_tune
            52: fine_tune
            53: sample_id
            54: sample_modes
            55: reserved3
            56: scale_tuning
            57: exclusive_class
            58: overriding_root_key
            59: unused5
            60: end_oper
          transform:
            0: linear
            1: abs_value
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
