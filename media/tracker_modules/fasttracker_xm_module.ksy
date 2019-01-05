meta:
  id: fasttracker_xm_module
  title: Extended Module
  application:
    - FastTracker 2
    - Protracker
    - MilkyTracker
    - libmodplug
    - Mikmod
  file-extension: xm
  xref:
    justsolve: Extended_Module
    pronom: fmt/323
    wikidata: Q376852
  license: Unlicense
  endian: le
  encoding: utf-8
doc: |
  XM (standing for eXtended Module) is a popular module music file
  format, that was introduced in 1994 in FastTracker2 by Triton demo
  group. Akin to MOD files, it bundles both digital samples
  (instruments) and instructions on which note to play at what time
  (patterns), which provides good audio quality with relatively small
  file size. Audio is reproducible without relying on the sound of
  particular hardware samplers or synths.
doc-ref: |
  http://sid.ethz.ch/debian/milkytracker/milkytracker-0.90.85%2Bdfsg/resources/reference/xm-form.txt
  ftp://ftp.modland.com/pub/documents/format_documentation/FastTracker%202%20v2.04%20(.xm).html
seq:
  - id: preheader
    type: preheader
  - id: header
    size: preheader.header_size - 4
    type: header
  - id: patterns
    type: pattern
    repeat: expr
    repeat-expr: header.num_patterns
  - id: instruments
    type: instrument
    repeat: expr
    repeat-expr: header.num_instruments
types:
  preheader:
    seq:
      - id: signature0
        contents: 'Extended Module: '
      - id: module_name
        size: 20
        type: strz
        doc: Module name, padded with zeroes
      - id: signature1
        contents: [0x1a]
      - id: tracker_name
        size: 20
        type: strz
        doc: Tracker name
      - id: version_number
        type: version
        doc: "Format versions below [0x01, 0x04] have a LOT of differences. Check this field!"
      - id: header_size
        type: u4
        doc: Header size << Calculated FROM THIS OFFSET, not from the beginning of the file! >>
    types:
      version:
        seq:
          - id: minor
            type: u1
            doc: currently 0x04
          - id: major
            type: u1
            doc: currently 0x01
        instances:
          value:
            value: (major<<8) | minor
  header:
    seq:
      - id: song_length
        type: u2
        doc: Song length (in pattern order table)
      - id: restart_position
        type: u2
      - id: num_channels
        type: u2
        doc: "(2,4,6,8,10,...,32)"
      - id: num_patterns
        type: u2
        doc: "(max 256)"
      - id: num_instruments
        type: u2
        doc: "(max 128)"
      - id: flags
        type: flags
      - id: default_tempo
        type: u2
      - id: default_bpm
        type: u2
      - id: pattern_order_table
        type: u1
        doc: "max 256"
        repeat: expr
        #repeat-expr: song_length
        repeat-expr: 256
  flags:
    seq:
      - id: reserved
        type: b15
      - id: freq_table_type
        type: b1
        doc: "0 = Amiga frequency table (see below); 1 = Linear frequency table"
  pattern:
    seq:
      - id: header
        type: header
      - id: packed_data
        size: header.main.len_packed_pattern
    types:
      header:
        seq:
          - id: header_length
            type: u4
            doc: Pattern header length
          - id: main
            type: header_main
            size: header_length - 4
        types:
          header_main:
            seq:
                - id: packing_type
                  type: u1
                  doc: Packing type (always 0)
                - id: num_rows_raw
                  type:
                    switch-on: _root.preheader.version_number.value
                    cases:
                      0x0102: u1
                      _: u2
                  doc: Number of rows in pattern (1..256)
                - id: len_packed_pattern
                  type: u2
                  doc: Packed pattern data size
            instances:
              num_rows:
                value: 'num_rows_raw + (_root.preheader.version_number.value == 0x0102 ? 1 : 0)'
  instrument:
    doc: |
      XM's notion of "instrument" typically constitutes of a
      instrument metadata and one or several samples. Metadata
      includes:

      * instrument's name
      * instruction of which sample to use for which note
      * volume and panning envelopes and looping instructions
      * vibrato settings
    seq:
      - id: header_size
        type: u4
        doc: |
          Instrument size << header that is >>
          << "Instrument Size" field tends to be more than the actual size of the structure documented here (it includes also the extended instrument sample header above). So remember to check it and skip the additional bytes before the first sample header >>
      - id: header
        size: header_size - 4
        type: header
      - id: samples_headers
        type: sample_header
        repeat: expr
        repeat-expr: header.num_samples
      - id: samples
        type: samples_data(samples_headers[_index])
        repeat: expr
        repeat-expr: header.num_samples
    types:
      header:
        seq:
          - id: name
            size: 22
            type: strz
          - id: type
            type: u1
            doc: Usually zero, but this seems pretty random, don't assume it's zero
          - id: num_samples
            type: u2
          - id: extra_header
            type: extra_header
            if: num_samples > 0
      extra_header:
        seq:
          - id: len_sample_header
            type: u4
          - id: idx_sample_per_note
            type: u1
            repeat: expr
            repeat-expr: 96
            doc: |
              Index of sample that should be used for any particular
              note. In the simplest case, where it's only one sample
              is available, it's an array of full of zeroes.
          - id: volume_points
            type: envelope_point
            repeat: expr
            repeat-expr: 12
            doc: Points for volume envelope. Only `num_volume_points` will be actually used.
          - id: panning_points
            type: envelope_point
            repeat: expr
            repeat-expr: 12
            doc: Points for panning envelope. Only `num_panning_points` will be actually used.
          - id: num_volume_points
            type: u1
          - id: num_panning_points
            type: u1
          
          - id: volume_sustain_point
            type: u1
          - id: volume_loop_start_point
            type: u1
          - id: volume_loop_end_point
            type: u1
          
          - id: panning_sustain_point
            type: u1
          - id: panning_loop_start_point
            type: u1
          - id: panning_loop_end_point
            type: u1
          
          - id: volume_type
            type: u1
            enum: type
          - id: panning_type
            type: u1
            enum: type
          
          - id: vibrato_type
            type: u1
          - id: vibrato_sweep
            type: u1
          - id: vibrato_depth
            type: u1
          - id: vibrato_rate
            type: u1
          - id: volume_fadeout
            type: u2
          - id: reserved
            type: u2
        types:
          envelope_point:
            doc: |
              Envelope frame-counters work in range 0..FFFFh (0..65535 dec).
              BUT! FT2 only itself supports only range 0..FFh (0..255 dec).
              Some other trackers (like SoundTracker for Unix), however, can use the full range 0..FFFF, so it should be supported.
              !!TIP: This is also a good way to detect if the module has been made with FT2 or not. (In case the tracker name is brain- deadly left unchanged!)
              Of course it does not help if all instruments have the values inside FT2 supported range.
              The value-field of the envelope point is ranged between 00..3Fh (0..64 dec).
            seq:
              - id: x
                type: u2
                doc: Frame number of the point
              - id: y
                type: u2
                doc: Value of the point
        enums:
          type:
            0: on
            1: sustain
            2: loop
      samples_data:
        doc: |
          The saved data uses simple delta-encoding to achieve better compression ratios (when compressed with pkzip, etc.)
          Pseudocode for converting the delta-coded data to normal data,
          old = 0;
          for i in range(data_len):
            new = sample[i] + old;
            sample[i] = new;
            old = new;
        params:
          - id: header
            type: sample_header
        seq:
          - id: data
            size: 'header.sample_length * (header.type.is_sample_data_16_bit ? 2 : 1)'
      sample_header:
        seq:
          - id: sample_length
            type: u4
          - id: sample_loop_start
            type: u4
          - id: sample_loop_length
            type: u4
          
          - id: volume
            type: u1
          - id: fine_tune
            type: s1
            doc: -16..+15
          - id: type
            type: loop_type
          - id: panning
            type: u1
            doc: (0-255)
          - id: relative_note_number
            type: s1
          - id: reserved
            type: u1
          - id: name
            size: 22
            type: strz
        types:
          loop_type:
            seq:
              - id: reserved0
                type: b3
              - id: is_sample_data_16_bit
                type: b1
              - id: reserved1
                type: b2
              - id: loop_type
                type: b2
                enum: loop_type
            enums:
              loop_type:
                0: none
                1: forward
                2: ping_pong
