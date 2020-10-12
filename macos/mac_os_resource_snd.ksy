meta:
  id: mac_os_resource_snd
  title: Classic MacOS Sound Resource
  application: Sound Manager
  endian: be
  license: MIT
  xref:
    wikidata: Q7564684
    mac-os-resource-type: 'snd '
doc-ref: "https://developer.apple.com/library/archive/documentation/mac/pdf/Sound/Sound_Manager.pdf"
doc: |
  Sound resources were introduced in Classic MacOS with the Sound Manager program.
  They can contain sound commands to generate sounds with given frequencies as well as sampled sound data.
  They are mostly found in resource forks, but can occasionally appear standalone or embedded in other files.
seq:
  - id: format
    type: u2
  - id: num_data_formats
    -orig-id: number_of_data_formats
    type: u2
    if: format == 1
  - id: data_formats
    type: data_format
    repeat: expr
    repeat-expr: num_data_formats
    if: format == 1
  - id: reference_count
    type: u2
    if: format == 2
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
      - id: is_data_offset
        type: b1
      - id: cmd
        type: b15
        enum: cmd_type
      - id: param1
        type: u2
      - id: param2
        type: u4
    instances:
      sound_header_type:
        pos: param2 + 20
        type: u1
        enum: sound_header_type
        if: is_data_offset and cmd == cmd_type::buffer_cmd
      sound_header:
        pos: param2
        size-eos: true
        if: is_data_offset and cmd == cmd_type::buffer_cmd
        type:
          switch-on: sound_header_type
          cases:
            'sound_header_type::standard': standard_sound_header
            'sound_header_type::extended': extended_sound_header
            'sound_header_type::compressed': compressed_sound_header
  standard_sound_header:
    seq:
      - id: sample_ptr
        -orig-id: samplePtr
        type: u4
        doc: pointer to samples (or 0 if samples follow data structure)
      - id: num_samples
        -orig-id: length
        type: u4
        doc: number of samples in array
      - id: sample_rate
        -orig-id: sampleRate
        type: unsigned_fixed_point
        doc: The rate at which the sample was originally recorded.
      - id: loop_start
        -orig-id: loopStart
        type: u4
        doc: loop point beginning
      - id: loop_end
        -orig-id: loopEnd
        type: u4
        doc: loop point ending
      - id: encode
        type: u1
        enum: sound_header_type
        doc: sample's encoding option
      - id: midi_note
        type: u1
        doc: base frequency of sample, expressed as MIDI note values, 60 is middleC
        -orig-id: baseFrequency
      - id: sample_area
        -orig-id: sampleArea
        size: num_samples
        doc: sampled-sound data
  extended_sound_header:
    seq:
      - id: sample_ptr
        -orig-id: samplePtr
        type: u4
        doc: pointer to samples (or 0 if samples follow data structure)
      - id: num_channels
        -orig-id: numChannels
        type: u4
        doc: number of channels in sample
      - id: sample_rate
        -orig-id: sampleRate
        type: unsigned_fixed_point
        doc: The rate at which the sample was originally recorded.
      - id: loop_start
        -orig-id: loopStart
        type: u4
        doc: loop point beginning
      - id: loop_end
        -orig-id: loopEnd
        type: u4
        doc: loop point ending
      - id: encode
        type: u1
        enum: sound_header_type
        doc: sample's encoding option
      - id: midi_note
        type: u1
        doc: base frequency of sample, expressed as MIDI note values, 60 is middleC
        -orig-id: baseFrequency
      - id: num_frames
        type: u4
      - id: aiff_sample_rate
        size: 10
        doc: rate of original sample (Extended80)
      - id: marker_chunk
        -orig-id: markerChunk
        type: u4
        doc: reserved
      - id: instrument_chunk_ptr
        -orig-id: instrumentChunks
        type: u4
        doc: pointer to instrument info
      - id: aes_recording_ptr
        -orig-id: AESRecording
        type: u4
        doc: pointer to audio info
      - id: bits_per_sample
        -orig-id: sampleSize
        type: u2
        doc: number of bits per sample
      - id: reserved
        -orig-id: futureUse1, futureUse2, futureUse3, futureUse4
        size: 14
        doc: reserved
      - id: sample_area
        -orig-id: sampleArea
        size: num_frames * num_channels * bits_per_sample / 8
        doc: sampled-sound data
  compressed_sound_header:
    seq:
      - id: sample_ptr
        -orig-id: samplePtr
        type: u4
        doc: pointer to samples (or 0 if samples follow data structure)
      - id: num_channels
        -orig-id: numChannels
        type: u4
        doc: number of channels in sample
      - id: sample_rate
        -orig-id: sampleRate
        type: unsigned_fixed_point
        doc: The rate at which the sample was originally recorded.
      - id: loop_start
        -orig-id: loopStart
        type: u4
        doc: loop point beginning
      - id: loop_end
        -orig-id: loopEnd
        type: u4
        doc: loop point ending
      - id: encode
        type: u1
        enum: sound_header_type
        doc: sample's encoding option
      - id: midi_note
        type: u1
        doc: base frequency of sample, expressed as MIDI note values, 60 is middleC
        -orig-id: baseFrequency
      - id: num_frames
        type: u4
      - id: aiff_sample_rate
        size: 10
        doc: rate of original sample (Extended80)
      - id: marker_chunk
        -orig-id: markerChunk
        type: u4
        doc: reserved
      - id: format
        size: 4
        type: str
        encoding: ASCII
        doc: data format type
      - id: reserved
        -orig-id: futureUse2
        size: 4
      - id: state_vars_ptr
        -orig-id: stateVars
        type: u4
        doc: pointer to StateBlock
      - id: left_over_samples_ptr
        -orig-id: leftOverSamples
        type: u4
        doc: pointer to LeftOverBlock
      - id: compression_id
        -orig-id: compressionID
        type: s2
        doc: ID of compression algorithm
      - id: packet_size
        -orig-id: packetSize
        type: u2
        doc: number of bits per packet
      - id: synthesizer_id
        -orig-id: snthID
        type: u2
        doc: |
          Latest Sound Manager documentation specifies this field as:
          This field is unused. You should set it to 0.
          Inside Macintosh (Volume VI, 1991) specifies it as:
          Indicates the resource ID number of the 'snth' resource that was used to compress the packets contained in the compressed sound header.
        doc-ref: "https://vintageapple.org/inside_o/pdf/Inside_Macintosh_Volume_VI_1991.pdf Page 22-49, absolute page number 1169 in the PDF"
      - id: bits_per_sample
        -orig-id: sampleSize
        type: u2
        doc: number of bits per sample
      - id: sample_area
        -orig-id: sampleArea
        size-eos: true
        doc: compressed sound data
    instances:
      compression_type:
        value: compression_id
        enum: compression_type_enum
  unsigned_fixed_point:
    seq:
      - id: integer_part
        type: u2
      - id: fraction_part
        type: u2
    instances:
      value:
        value: integer_part + fraction_part/65535.0

enums:
  data_type:
    0x01: square_wave_synth
    0x03: wave_table_synth
    0x05: sampled_synth
  cmd_type:
    0: null_cmd
    3: quiet_cmd
    4: flush_cmd
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
  compression_type_enum:
    -2: variable_compression
    -1: fixed_compression
    0: not_compressed
    3: three_to_one
    4: six_to_one
