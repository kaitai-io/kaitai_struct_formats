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
instances:
  midi_note_to_frequency:
    value: |
      [
        8.18, 8.66, 9.18, 9.72, 10.30, 10.91, 11.56, 12.25,
        12.98, 13.75, 14.57, 15.43, 16.35, 17.32, 18.35, 19.45,
        20.60, 21.83, 23.12, 24.50, 25.96, 27.50, 29.14, 30.87,
        32.70, 34.65, 36.71, 38.89, 41.20, 43.65, 46.25, 49.00,
        51.91, 55.00, 58.27, 61.74, 65.41, 69.30, 73.42, 77.78,
        82.41, 87.31, 92.50, 98.00, 103.83, 110.00, 116.54, 123.47,
        130.81, 138.59, 146.83, 155.56, 164.81, 174.61, 185.00, 196.00,
        207.65, 220.00, 233.08, 246.94, 261.63, 277.18, 293.66, 311.13,
        329.63, 349.23, 369.99, 392.00, 415.30, 440.00, 466.16, 493.88,
        523.25, 554.37, 587.33, 622.25, 659.26, 698.46, 739.99, 783.99,
        830.61, 880.00, 932.33, 987.77, 1046.50, 1108.73, 1174.66, 1244.51,
        1318.51, 1396.91, 1479.98, 1567.98, 1661.22, 1760.00, 1864.66, 1975.53,
        2093.00, 2217.46, 2349.32, 2489.02, 2637.02, 2793.83, 2959.96, 3135.96,
        3322.44, 3520.00, 3729.31, 3951.07, 4186.01, 4434.92, 4698.64, 4978.03,
        5274.04, 5587.65, 5919.91, 6271.93, 6644.88, 7040.00, 7458.62, 7902.13,
        8372.02, 8869.84, 9397.27, 9956.06, 10548.08, 11175.30, 11839.82, 12543.85
      ]
    doc: |
      Lookup table to convert a MIDI note into a frequency in hz
      The lookup table represents the formula (2 ** ((midi_note - 69) / 12)) * 440
    doc-ref: https://en.wikipedia.org/wiki/MIDI_tuning_standard
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
      sound_header:
        pos: param2
        type: sound_header
        size-eos: true
        if: is_data_offset and cmd == cmd_type::buffer_cmd
  sound_header:
    seq:
      - id: sample_ptr
        -orig-id: samplePtr
        type: u4
        doc: pointer to samples (or 0 if samples follow data structure)
      - id: num_samples
        -orig-id: length
        type: u4
        doc: number of samples
        if: sound_header_type == sound_header_type::standard
      - id: num_channels
        -orig-id: numChannels
        type: u4
        doc: number of channels in sample
        if: sound_header_type != sound_header_type::standard
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
        doc: base frequency of sample, expressed as MIDI note values, 60 is middle C
        -orig-id: baseFrequency
      - id: num_frames
        type: u4
        if: sound_header_type != sound_header_type::standard
      - id: aiff_sample_rate
        size: 10
        doc: rate of original sample (Extended80)
        if: sound_header_type != sound_header_type::standard
      - id: marker_chunk
        -orig-id: markerChunk
        type: u4
        doc: reserved
        if: sound_header_type != sound_header_type::standard
      - id: instrument_chunk_ptr
        -orig-id: instrumentChunks
        type: u4
        doc: pointer to instrument info
        if: sound_header_type == sound_header_type::extended
      - id: aes_recording_ptr
        -orig-id: AESRecording
        type: u4
        doc: pointer to audio info
        if: sound_header_type == sound_header_type::extended
      - id: format
        size: 4
        type: str
        encoding: ASCII
        doc: data format type
        if: sound_header_type == sound_header_type::compressed
      - id: reserved
        -orig-id: futureUse2
        size: 4
        if: sound_header_type == sound_header_type::compressed
      - id: state_vars_ptr
        -orig-id: stateVars
        type: u4
        doc: pointer to StateBlock
        if: sound_header_type == sound_header_type::compressed
      - id: left_over_samples_ptr
        -orig-id: leftOverSamples
        type: u4
        doc: pointer to LeftOverBlock
        if: sound_header_type == sound_header_type::compressed
      - id: compression_id
        -orig-id: compressionID
        type: s2
        doc: ID of compression algorithm
        if: sound_header_type == sound_header_type::compressed
      - id: packet_size
        -orig-id: packetSize
        type: u2
        doc: number of bits per packet
        if: sound_header_type == sound_header_type::compressed
      - id: synthesizer_id
        -orig-id: snthID
        type: u2
        doc: |
          Latest Sound Manager documentation specifies this field as:
          This field is unused. You should set it to 0.
          Inside Macintosh (Volume VI, 1991) specifies it as:
          Indicates the resource ID number of the 'snth' resource that was used to compress the packets contained in the compressed sound header.
        doc-ref: "https://vintageapple.org/inside_o/pdf/Inside_Macintosh_Volume_VI_1991.pdf Page 22-49, absolute page number 1169 in the PDF"
        if: sound_header_type == sound_header_type::compressed
      - id: bits_per_sample
        -orig-id: sampleSize
        type: u2
        doc: number of bits per sample
        if: sound_header_type != sound_header_type::standard
      - id: reserved2
        -orig-id: futureUse1, futureUse2, futureUse3, futureUse4
        size: 14
        doc: reserved
        if: sound_header_type == sound_header_type::extended
      - id: sample_area
        -orig-id: sampleArea
        size-eos: true
        doc: sampled-sound data

    instances:
      base_freqeuncy:
        value: _root.midi_note_to_frequency[midi_note]
        #TODO: If https://github.com/kaitai-io/kaitai_struct/issues/216 is implemented:
        #TODO: value: (2 ** ((midi_note - 69) / 12)) * 440
        doc: |
          base frequency of sample in hz
          Calculated with the formula (2 ** ((midi_note - 69) / 12)) * 440
        doc-ref: https://en.wikipedia.org/wiki/MIDI_tuning_standard
        if: midi_note >= 0 and midi_note < 128
      sound_header_type:
        pos: 20
        type: u1
        enum: sound_header_type
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
