meta:
  id: mac_os_resource_snd
  title: Classic MacOS Sound Resource
  application: Sound Manager
  xref:
    mac-os-resource-type: 'snd '
    wikidata: Q7564684
  license: MIT
  endian: be
doc: |
  Sound resources were introduced in Classic MacOS with the Sound Manager program.
  They can contain sound commands to generate sounds with given frequencies as well as sampled sound data.
  They are mostly found in resource forks, but can occasionally appear standalone or embedded in other files.
doc-ref: "https://developer.apple.com/library/archive/documentation/mac/pdf/Sound/Sound_Manager.pdf"
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
      Lookup table to convert a MIDI note into a frequency in Hz
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
        doc: contains initialisation options for the SndNewChannel function
    instances:
      wave_init_channel_mask:
        value: 0x07
        doc: wave table only, Sound Manager 2.0 and earlier
      wave_init:
        value: options & wave_init_channel_mask
        enum: wave_init_option
        if: id == data_type::wave_table_synth
      init_pan_mask:
        -orig-id: initPanMask
        value: 0x0003
        doc: mask for right/left pan values
      pan_init:
        value: options & init_pan_mask
        enum: init_option
      init_stereo_mask:
        -orig-id: initStereoMask
        value: 0x00C0
        doc: mask for mono/stereo values
      stereo_init:
        value: options & init_stereo_mask
        enum: init_option
      init_comp_mask:
        -orig-id: initCompMask
        value: 0xFF00
        doc: mask for compression IDs
      comp_init:
        value: options & init_comp_mask
        enum: init_option
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
        if: is_data_offset and cmd == cmd_type::buffer_cmd
  sound_header:
    seq:
      - size: 0
        if: start_ofs < 0 # invoking the `start_ofs` value instance to save the current `_io.pos`
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
        if: sound_header_type == sound_header_type::extended or sound_header_type == sound_header_type::compressed
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
      - id: extended_or_compressed
        type: extended_or_compressed
        if: sound_header_type == sound_header_type::extended or sound_header_type == sound_header_type::compressed
      - id: sample_area
        -orig-id: sampleArea
        size: |
          sound_header_type == sound_header_type::standard ? num_samples :
          sound_header_type == sound_header_type::extended ? extended_or_compressed.num_frames * num_channels * extended_or_compressed.bits_per_sample / 8 :
          _io.size - _io.pos
        doc: sampled-sound data
        if: sample_ptr == 0
    instances:
      start_ofs:
        value: _io.pos
      base_freqeuncy:
        value: _root.midi_note_to_frequency[midi_note]
        #TODO: If https://github.com/kaitai-io/kaitai_struct/issues/216 is implemented:
        #TODO: value: (2 ** ((midi_note - 69) / 12)) * 440
        if: midi_note >= 0 and midi_note < 128
        doc: |
          base frequency of sample in Hz
          Calculated with the formula (2 ** ((midi_note - 69) / 12)) * 440
        doc-ref: https://en.wikipedia.org/wiki/MIDI_tuning_standard
      sound_header_type:
        pos: start_ofs + 20
        type: u1
        enum: sound_header_type
  extended_or_compressed:
    seq:
      - id: num_frames
        type: u4
      - id: aiff_sample_rate
        size: 10
        doc: rate of original sample (Extended80)
      - id: marker_chunk
        -orig-id: markerChunk
        type: u4
        doc: reserved
      - id: extended
        type: extended
        if: _parent.sound_header_type == sound_header_type::extended
      - id: compressed
        type: compressed
        if: _parent.sound_header_type == sound_header_type::compressed
      - id: bits_per_sample
        -orig-id: sampleSize
        type: u2
        doc: number of bits per sample
      - id: reserved
        -orig-id: futureUse1, futureUse2, futureUse3, futureUse4
        size: 14
        doc: reserved
        if: _parent.sound_header_type == sound_header_type::extended
  extended:
    seq:
      - id: instrument_chunk_ptr
        -orig-id: instrumentChunks
        type: u4
        doc: pointer to instrument info
      - id: aes_recording_ptr
        -orig-id: AESRecording
        type: u4
        doc: pointer to audio info
  compressed:
    seq:
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
  wave_init_option:
    0x04:
      id: channel0
      -orig-id: waveInitChannel0
      doc: Play sounds through the first wave-table channel
    0x05:
      id: channel1
      -orig-id: waveInitChannel1
      doc: Play sounds through the second wave-table channel
    0x06:
      id: channel2
      -orig-id: waveInitChannel2
      doc: Play sounds through the third wave-table channel
    0x07:
      id: channel3
      -orig-id: waveInitChannel3
      doc: Play sounds through the fourth wave-table channel
  init_option:
    0x0002:
      id: chan_left
      -orig-id: initChanLeft
      doc: left stereo channel
    0x0003:
      id: chan_right
      -orig-id: initChanRight
      doc: right stereo channel
    0x0004:
      id: no_interp
      -orig-id: initNoInterp
      doc: no linear interpolation
    0x0008:
      id: no_drop
      -orig-id: initNoDrop
      doc: no drop-sample conversion
    0x0080:
      id: mono
      -orig-id: initMono
      doc: monophonic channel
    0x00C0:
      id: stereo
      -orig-id: initStereo
      doc: stereo channel
    0x0300:
      id: mace3
      -orig-id: initMACE3
      doc: MACE 3:1
    0x0400:
      id: mace6
      -orig-id: initMACE6
      doc: MACE 6:1

  cmd_type:
    0:
      id: null_cmd
      -orig-id: nullCmd
      doc: do nothing
    3:
      id: quiet_cmd
      -orig-id: quietCmd
      doc: stop a sound that is playing
    4:
      id: flush_cmd
      -orig-id: flushCmd
      doc: flush a sound channel
    5:
      id: re_init_cmd
      -orig-id: reInitCmd
      doc: reinitialize a sound channel
    10:
      id: wait_cmd
      -orig-id: waitCmd
      doc: suspend processing in a channel
    11:
      id: pause_cmd
      -orig-id: pauseCmd
      doc: pause processing in a channel
    12:
      id: resume_cmd
      -orig-id: resumeCmd
      doc: resume processing in a channel
    13:
      id: call_back_cmd
      -orig-id: callBackCmd
      doc: execute a callback procedure
    14:
      id: sync_cmd
      -orig-id: syncCmd
      doc: synchronize channels
    15:
      id: empty_cmd
      -orig-id: emptyCmd
      doc: |
        If no other commands are pending in the sound channel after a
        resumeCmd command, the Sound Manager sends an emptyCmd command.
        The emptyCmd command is sent only by the Sound Manager and
        should not be issued by your application.
    24:
      id: available_cmd
      -orig-id: availableCmd
      doc: see if initialization options are supported
    25:
      id: version_cmd
      -orig-id: versionCmd
      doc: determine version
    26:
      id: total_load_cmd
      -orig-id: totalLoadCmd
      doc: report total CPU load
    27:
      id: load_cmd
      -orig-id: loadCmd
      doc: report CPU load for a new channel
    40:
      id: freq_duration_cmd
      -orig-id: freqDurationCmd
      doc: play a note for a duration
    41:
      id: rest_cmd
      -orig-id: restCmd
      doc: rest a channel for a duration
    42:
      id: freq_cmd
      -orig-id: freqCmd
      doc: change the pitch of a sound
    43:
      id: amp_cmd
      -orig-id: ampCmd
      doc: change the amplitude of a sound
    44:
      id: timbre_cmd
      -orig-id: timbreCmd
      doc: change the timbre of a sound
    45:
      id: get_amp_cmd
      -orig-id: getAmpCmd
      doc: get the amplitude of a sound
    46:
      id: volume_cmd
      -orig-id: volumeCmd
      doc: set volume
    47:
      id: get_volume_cmd
      -orig-id: getVolumeCmd
      doc: get volume
    60:
      id: wave_table_cmd
      -orig-id: waveTableCmd
      doc: install a wave table as a voice
    61:
      id: phase_cmd
      -orig-id: phaseCmd
      doc: Not documented
    80:
      id: sound_cmd
      -orig-id: soundCmd
      doc: install a sampled sound as a voice
    81:
      id: buffer_cmd
      -orig-id: bufferCmd
      doc: play a sampled sound
    82:
      id: rate_cmd
      -orig-id: rateCmd
      doc: set the pitch of a sampled sound
    85:
      id: get_rate_cmd
      -orig-id: getRateCmd
      doc: get the pitch of a sampled sound
  sound_header_type:
    0x00: standard
    0xFF: extended
    0xFE: compressed
  compression_type_enum:
    -2: variable_compression
    -1: fixed_compression
    0: not_compressed
    1: two_to_one
    2: eight_to_three
    3: three_to_one
    4: six_to_one
