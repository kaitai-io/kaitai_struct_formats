meta:
  id: standard_midi_file
  title: Standard MIDI file
  file-extension:
    - mid
    - smf
  endian: be
  imports:
    - /common/vlq_base128_be
seq:
  - id: hdr
    type: header
  - id: tracks
    type: track
    repeat: expr
    repeat-expr: hdr.qty_tracks
types:
  header:
    seq:
      - id: magic
        contents: "MThd"
      - id: header_length
        type: u4
      - id: format
        type: u2
      - id: qty_tracks
        type: u2
      - id: division
        type: s2
  track:
    seq:
      - id: magic
        contents: "MTrk"
      - id: track_length
        type: u4
      - id: events
        type: track_events
        size: track_length
  track_events:
    seq:
      - id: event
        type: track_event
        repeat: eos
#        repeat: expr
#        repeat-expr: 10
  track_event:
    seq:
      - id: v_time
        type: vlq_base128_be
      - id: event_header
        type: u1
      - id: meta_event_body
        type: meta_event_body
        if: event_header == 0xff
      - id: sysex_body
        type: sysex_event_body
        if: event_header == 0xf0
      - id: event_body
        type:
          switch-on: event_type
          cases:
            0x80: note_off_event
            0x90: note_on_event
            0xa0: polyphonic_pressure_event
            0xb0: controller_event
            0xc0: program_change_event
            0xd0: channel_pressure_event
            0xe0: pitch_bend_event
    instances:
      event_type:
        value: event_header & 0xf0
      channel:
        value: event_header & 0xf
        if: event_type != 0xf0
  meta_event_body:
    seq:
      - id: meta_type
        type: u1
        enum: meta_type_enum
      - id: len
        type: vlq_base128_be
      - id: body
        size: len.value
    enums:
      meta_type_enum:
        0x00: sequence_number
        0x01: text_event
        0x02: copyright
        0x03: sequence_track_name
        0x04: instrument_name
        0x05: lyric_text
        0x06: marker_text
        0x07: cue_point
        0x20: midi_channel_prefix_assignment
        0x2f: end_of_track
        0x51: tempo
        0x54: smpte_offset
        0x58: time_signature
        0x59: key_signature
        0x7f: sequencer_specific_event
  note_off_event:
    seq:
      - id: note
        type: u1
      - id: velocity
        type: u1
  note_on_event:
    seq:
      - id: note
        type: u1
      - id: velocity
        type: u1
  polyphonic_pressure_event:
    seq:
      - id: note
        type: u1
      - id: pressure
        type: u1
  controller_event:
    seq:
      - id: controller
        type: u1
      - id: value
        type: u1
  program_change_event:
    seq:
      - id: program
        type: u1
  channel_pressure_event:
    seq:
      - id: pressure
        type: u1
  pitch_bend_event:
    seq:
      - id: b1
        type: u1
      - id: b2
        type: u1
    instances:
      bend_value:
        value: (b2 << 7) + b1 - 0x4000
      adj_bend_value:
        value: bend_value - 0x4000
  sysex_event_body:
    seq:
      - id: len
        type: vlq_base128_be
      - id: data
        size: len.value
