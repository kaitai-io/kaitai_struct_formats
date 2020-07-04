meta:
  id: mac_os_resource_snd
  endian: be
  license: MIT
  xref:
    wikidata: Q7564684
enums:
  data_type:
    0x01: square_wave_synth
    0x03: wave_table_synth
    0x05: sampled_synth
  cmd_type:
    00: null_cmd
    03: quiet_cmd
    04: flush_cmd
    10: wait_cmd
    11: pause_cmd
    12: resume_cmd
    13: call_back_cmd
    14: sync_cmd
    15: empty_cmd
    40: freq_duration_cmd
    41: rest_cmd
    42: freq_cmd
    43: amp_cmd
    44: timbre_cmd
    60: wave_table_cmd
    61: phase_cmd
    80: sound_cmd
    81: buffer_cmd
    82: rate_cmd
  sound_header_type:
    0x00: standard
    0xFF: extended
    0xFE: compressed
doc-ref: "https://developer.apple.com/library/archive/documentation/mac/pdf/Sound/Sound_Manager.pdf"
seq:
  - id: format
    type: u2
  - id: num_data_formats
    -orig-id: number_of_data_formats
    type: u2
    if: format==1
  - id: data_formats
    type: data_format
    repeat: expr
    repeat-expr: num_data_formats
    if: format==1
  - id: reference_count
    type: u2
    if: format==2
  - id: num_sound_commands
    -orig-id: number_of_sound_commands
    type: u2
  - id: sound_commands
    type: sound_command
    repeat: expr
    repeat-expr: num_sound_commands
types:
  data_format:
    seq:
      - id: id
        type: u2
        enum: data_type
      - id: options
        type: u4
  sound_command:
    seq:
      - id: raw_cmd
        type: u2
      - id: param1
        type: u2
      - id: param2
        type: u4
    instances:
      cmd:
        value: raw_cmd&0x7FFF
        enum: cmd_type
      is_data_offset:
        value: raw_cmd&0x8000
      sound_header_type:
        pos: param2 + 20
        type: u1
        enum: sound_header_type
        if: is_data_offset > 0 and cmd == cmd_type::buffer_cmd
      sound_header:
        pos: param2
        size-eos: true
        if: is_data_offset > 0 and cmd == cmd_type::buffer_cmd
        type:
          switch-on: sound_header_type
          cases:
            sound_header_type::standard: standard_sound_header
            sound_header_type::extended: extended_sound_header
            sound_header_type::compressed: compressed_sound_header
  standard_sound_header:
    seq:
      - id: sample_ptr
        type: u4
      - id: length
        type: u4
      - id: sample_rate
        type: u2
      - id: sample_rate_frac
        type: u2
      - id: loop_start
        type: u4
      - id: loop_end
        type: u4
      - id: encode
        type: u1
        enum: sound_header_type
      - id: base_frequency
        type: u1
      - id: sample_area
        size: length
  extended_sound_header:
    seq:
      - id: sample_ptr
        type: u4
      - id: num_channels
        type: u4
      - id: sample_rate
        type: u2
      - id: sample_rate_frac
        type: u2
      - id: loop_start
        type: u4
      - id: loop_end
        type: u4
      - id: encode
        type: u1
        enum: sound_header_type
      - id: base_frequency
        type: u1
      - id: num_frames
        type: u4
      - id: aiff_sample_rate
        size: 10
        #this is a float80
      - id: marker_chunk
        type: u4
      - id: instrument_chunks
        type: u4
      - id: aes_recording
        type: u4
      - id: sample_size
        type: u2
      - id: reserved
        -orig-id: future_use_1, future_use_2, future_use_3, future_use_4
        size: 14
      - id: sample_area
        size: num_frames * num_channels * sample_size / 8
  compressed_sound_header:
    seq:
      - id: sample_ptr
        type: u4
      - id: num_channels
        type: u4
      - id: sample_rate
        type: u2
      - id: sample_rate_frac
        type: u2
      - id: loop_start
        type: u4
      - id: loop_end
        type: u4
      - id: encode
        type: u1
        enum: sound_header_type
      - id: base_frequency
        type: u1
      - id: num_frames
        type: u4
      - id: aiff_sample_rate
        size: 10
        #this is a float80
      - id: marker_chunk
        type: u4
      - id: format
        size: 4
        type: str
        encoding: ASCII
      - id: reserved
        -orig-id: future_use_2
        size: 4
      - id: state_vars_ptr
        type: u4
      - id: left_over_samples_ptr
        type: u4
      - id: compression_id
        type: u2
      - id: packet_size
        type: u2
      - id: snth_id
        type: u2
      - id: sample_size
        type: u2
      - id: sample_area
        size-eos: true
