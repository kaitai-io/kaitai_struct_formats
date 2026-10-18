meta:
  id: standard_midi_file
  title: Standard MIDI file
  file-extension:
    - mid
    - midi
    - smf
  xref:
    justsolve: MIDI
    loc:
      - fdd000102 # MIDI Sequence Data
      - fdd000119 # Standard MIDI File
    mime: audio/midi
    pronom: x-fmt/230
    wikidata: Q10610388
  license: CC0-1.0
  imports:
    - /common/vlq_base128_be
  endian: be
doc: |
  Standard MIDI file, typically known just as "MID", is a standard way
  to serialize series of MIDI events, which is a protocol used in many
  music synthesizers to transfer music data: notes being played,
  effects being applied, etc.

  Internally, file consists of a header and series of tracks, every
  track listing MIDI events with certain header designating time these
  events are happening.

  NOTE: Rarely, MIDI files employ certain stateful compression scheme
  to avoid storing certain elements of further elements, instead
  reusing them from events which happened earlier in the
  stream. Kaitai Struct (as of v0.9) is currently unable to parse
  these, but files employing this mechanism are relatively rare.
seq:
  - id: hdr
    type: header
  - id: tracks
    type: track
    repeat: expr
    repeat-expr: hdr.num_tracks
types:
  header:
    seq:
      - id: magic
        contents: "MThd"
      - id: len_header
        type: u4
      - id: format
        type: u2
      - id: num_tracks
        type: u2
      - id: division
        type: s2
  track:
    seq:
      - id: magic
        contents: "MTrk"
      - id: len_events
        type: u4
      - id: events
        type: track_events
        size: len_events
  track_events:
    seq:
      - id: event
        type: track_event
        repeat: eos
  track_event:
    doc: |
      System Common and System Real-Time messages should be stored in an
      F7 escape event in a Standard MIDI File. These messages are also
      accepted here when stored directly with a delta-time. Tune Request
      (F6), Timing Clock (F8), Start (FA), Continue (FB), Stop (FC) and
      Active Sensing (FE) have no data bytes. Reserved status bytes F4,
      F5, F9 and FD have no defined payload and are retained as
      header-only events.
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
        if: event_header == 0xf0 or event_header == 0xf7
        doc: |
          Both F0 SysEx events and F7 continuation or escape events have
          a variable-length size followed by that many data bytes.
      - id: system_event_body
        type:
          switch-on: event_header
          cases:
            0xf1: time_code_quarter_frame_event
            0xf2: song_position_pointer_event
            0xf3: song_select_event
        if: event_header >= 0xf1 and event_header <= 0xf3
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
    doc-ref: https://midi.org/summary-of-midi-1-0-messages
    seq:
      - id: b1
        type: u1
      - id: b2
        type: u1
    instances:
      bend_value:
        value: (b2 << 7) + b1
        doc: Unsigned 14-bit pitch bend value (0..16383), with 8192 meaning no bend.
      adj_bend_value:
        value: bend_value - 0x2000
        doc: Pitch bend value centered at zero (-8192..8191).
  time_code_quarter_frame_event:
    seq:
      - id: data
        type: u1
    instances:
      message_type:
        value: (data >> 4) & 0x7
      value:
        value: data & 0xf
  song_position_pointer_event:
    seq:
      - id: lsb
        type: u1
      - id: msb
        type: u1
    instances:
      song_position:
        value: (msb << 7) + lsb
        doc: Number of MIDI beats since the start of the song (1 beat = 6 MIDI clocks).
  song_select_event:
    seq:
      - id: song_number
        type: u1
  sysex_event_body:
    seq:
      - id: len
        type: vlq_base128_be
      - id: data
        size: len.value
