meta:
  id: s3m
  title: Scream Tracker 3 module
  file-extension: s3m
  xref:
    justsolve: Scream_Tracker_3_module
    pronom: fmt/718
    wikidata: Q1461901
  license: CC0-1.0
  endian: le
doc: |
  Scream Tracker 3 module is a tracker music file format that, as all
  tracker music, bundles both sound samples and instructions on which
  notes to play. It originates from a Scream Tracker 3 music editor
  (1994) by Future Crew, derived from original Scream Tracker 2 (.stm)
  module format.

  Instrument descriptions in S3M format allow to use either digital
  samples or setup and control AdLib (OPL2) synth.

  Music is organized in so called `patterns`. "Pattern" is a generally
  a 64-row long table, which instructs which notes to play on which
  time measure. "Patterns" are played one-by-one in a sequence
  determined by `orders`, which is essentially an array of pattern IDs
  - this way it's possible to reuse certain patterns more than once
  for repetitive musical phrases.
doc-ref: http://hackipedia.org/browse.cgi/File%20formats/Music%20tracker/S3M%2c%20ScreamTracker%203/Scream%20Tracker%203.20%20by%20Future%20Crew.txt
seq:
  - id: song_name
    size: 28
    terminator: 0
  - id: magic1
    contents: [0x1a]
  - id: file_type
    -orig-id: Typ
    type: u1
  - id: reserved1
    size: 2
  - id: num_orders
    -orig-id: OrdNum
    type: u2
    doc: Number of orders in a song
  - id: num_instruments
    -orig-id: InsNum
    type: u2
    doc: Number of instruments in a song
  - id: num_patterns
    -orig-id: PatNum
    type: u2
    doc: Number of patterns in a song
  - id: flags
    -orig-id: Flags
    type: u2
  - id: version
    -orig-id: Cwt/v
    type: u2
    doc: Scream Tracker version that was used to save this file
  - id: samples_format
    -orig-id: Ffi
    type: u2
    doc: '1 = signed samples, 2 = unsigned samples'
  - id: magic2
    contents: 'SCRM'
  - id: global_volume
    -orig-id: g.v
    type: u1
  - id: initial_speed
    -orig-id: i.s
    type: u1
  - id: initial_tempo
    -orig-id: i.t
    type: u1
  - id: is_stereo
    type: b1
  - id: master_volume
    -orig-id: m.v
    type: b7
  - id: ultra_click_removal
    -orig-id: u.c
    type: u1
  - id: has_custom_pan
    -orig-id: d.p
    type: u1
  - id: reserved2
    size: 8
  - id: ofs_special
    -orig-id: Special
    type: u2
    doc: Offset of special data, not used by Scream Tracker directly.
  - id: channels
    type: channel
    repeat: expr
    repeat-expr: 32
  - id: orders
    size: num_orders
  - id: instruments
    type: instrument_ptr
    repeat: expr
    repeat-expr: num_instruments
  - id: patterns
    type: pattern_ptr
    repeat: expr
    repeat-expr: num_patterns
  - id: channel_pans
    type: channel_pan
    repeat: expr
    repeat-expr: 32
    if: has_custom_pan == 252
types:
  channel:
    seq:
      - id: is_disabled
        type: b1
      - id: ch_type
        type: b7
        doc: Channel type (0..7 = left sample channels, 8..15 = right sample channels, 16..31 = AdLib synth channels)
  instrument_ptr:
    seq:
      - id: paraptr
        type: u2
    instances:
      body:
        pos: paraptr * 0x10
        type: instrument
  instrument:
    seq:
      - id: type
        type: u1
        enum: inst_types
      - id: filename
        terminator: 0
        size: 12
      - id: body
        type:
          switch-on: type
          cases:
            'inst_types::sample': sampled
            _: adlib
      - id: tuning_hz
        type: u4
      - id: reserved2
        size: 12
      - id: sample_name
        size: 28
        terminator: 0
      - id: magic
        contents: 'SCRS'
    enums:
      inst_types:
        1: sample
        2: melodic
        3: bass_drum
        4: snare_drum
        5: tom
        6: cymbal
        7: hihat
    types:
      sampled:
        seq:
          - id: paraptr_sample
            -orig-id: MemSeg
            type: swapped_u3
          - id: len_sample
            -orig-id: Length
            type: u4
          - id: loop_begin
            -orig-id: LoopBeg
            type: u4
          - id: loop_end
            -orig-id: LoopEnd
            type: u4
          - id: default_volume
            -orig-id: Vol
            type: u1
            doc: Default volume
          - id: reserved1
            type: u1
          - id: is_packed
            -orig-id: '[P]'
            type: u1
            doc: 0 = unpacked, 1 = DP30ADPCM packing
          - id: flags
            -orig-id: '[F]'
            type: u1
        instances:
          sample:
            pos: paraptr_sample.value * 0x10
            size: len_sample
      adlib:
        # TODO
        seq:
          - id: reserved1
            contents: [0, 0, 0]
          - size: 16
  pattern_ptr:
    seq:
      - id: paraptr
        type: u2
    instances:
      body:
        pos: paraptr * 0x10
        type: pattern
  pattern:
    seq:
      - id: size
        type: u2
      - id: body
        size: size - 2
        type: pattern_cells
  pattern_cells:
    seq:
      - id: cells
        type: pattern_cell
        repeat: eos
  pattern_cell:
    seq:
      - id: has_fx
        type: b1
      - id: has_volume
        type: b1
      - id: has_note_and_instrument
        type: b1
      - id: channel_num
        type: b5
      - id: note
        type: u1
        if: has_note_and_instrument
      - id: instrument
        type: u1
        if: has_note_and_instrument
      - id: volume
        type: u1
        if: has_volume
      - id: fx_type
        type: u1
        if: has_fx
      - id: fx_value
        type: u1
        if: has_fx
  swapped_u3:
    doc: Custom 3-byte integer, stored in mixed endian manner.
    seq:
      - id: hi
        type: u1
      - id: lo
        type: u2
    instances:
      value:
        value: lo | (hi << 16)
  channel_pan:
    seq:
      - id: reserved1
        type: b2
      - id: has_custom_pan
        type: b1
        doc: |
          If true, then use a custom pan setting provided in the `pan`
          field. If false, the channel would use the default setting
          (0x7 for mono, 0x3 or 0xc for stereo).
      - id: reserved2
        type: b1
      - id: pan
        type: b4
