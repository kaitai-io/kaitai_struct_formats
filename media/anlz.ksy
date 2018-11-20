meta:
  id: anlz_file
  title: rekordbox track analysis file
  application: rekordbox
  file-extension:
    - dat
    - ext
  license: EPL-1.0
  endian: be

doc: |
  These files are created by rekordbox when analyzing audio tracks
  to facilitate DJ performance. They include waveforms, beat grids
  (information about the precise time at which each beat occurs),
  time indices to allow efficient seeking to specific positions
  inside variable bit-rate audio streams, and lists of memory cues
  and loop points. They are used by Pioneer professional DJ
  equipment.

  The format has been reverse-engineered to facilitate sophisticated
  integrations with light and laser shows, videos, and other musical
  instruments, by supporting deep knowledge of what is playing and
  what is coming next through monitoring the network communications
  of the players.

doc-ref: https://reverseengineering.stackexchange.com/questions/4311/help-reversing-a-edb-database-file-for-pioneers-rekordbox-software

seq:
  - contents: "PMAI"
  - id: len_header
    type: u4
    doc: |
      The number of bytes of this header section.
  - id: len_file
    type: u4
    doc: |
       The number of bytes in the entire file.
  - size: len_header - _io.pos
  - id: sections
    type: tagged_section
    repeat: eos
    doc: |
      The remainder of the file is a sequence of type-tagged sections,
      identified by a four-byte magic sequence.

types:
  tagged_section:
    doc: |
      A type-tagged file section, identified by a four-byte magic
      sequence, with a header specifying its length, and whose payload
      is determined by the type tag.
    seq:
      - id: fourcc
        type: u4
        enum: section_tags
        doc: |
          A tag value indicating what kind of section this is.
      - id: len_header
        type: u4
        doc: |
          The size, in bytes, of the header portion of the tag.
      - id: len_tag
        type: u4
        doc: |
          The size, in bytes, of this entire tag, counting the header.
      - id: body
        size: len_tag - 12
        type:
          switch-on: fourcc
          cases:
            'section_tags::cues': cue_tag
            'section_tags::path': path_tag
            'section_tags::beat_grid': beat_grid_tag
            'section_tags::vbr': vbr_tag
            'section_tags::wave_preview': wave_preview_tag
            'section_tags::wave_tiny': wave_preview_tag
            'section_tags::wave_scroll': wave_scroll_tag
            'section_tags::wave_color_preview': wave_color_preview_tag
            'section_tags::wave_color_scroll': wave_color_scroll_tag
    -webide-representation: '{fourcc}'


  beat_grid_tag:
    doc: |
      Holds a list of all the beats found within the track, recording
      their bar position, the time at which they occur, and the tempo
      at that point.
    seq:
      - type: u4
      - type: u4  # @flesniak says this is always 0x80000
      - id: len_beats
        type: u4
        doc: |
          The number of beat entries which follow.
      - id: beats
        type: beat_grid_beat
        repeat: expr
        repeat-expr: len_beats
        doc: The entries of the beat grid.

  beat_grid_beat:
    doc: |
      Describes an individual beat in a beat grid.
    seq:
      - id: beat_number
        type: u2
        doc: |
          The position of the beat within its musical bar, where beat 1
          is the down beat.
      - id: tempo
        type: u2
        doc: |
          The tempo at the time of this beat, in beats per minute,
          multiplied by 100.
      - id: time
        type: u4
        doc: |
          The time, in milliseconds, at which this beat occurs when
          the track is played at normal (100%) pitch.

  cue_tag:
    doc: |
      Stores either a list of ordinary memory cues and loop points, or
      a list of hot cues and loop points.
    seq:
      - id: type
        type: u4
        enum: cue_list_type
        doc: |
          Identifies whether this tag stors ordinary or hot cues.
      - id: len_cues
        type: u4
        doc: |
          The length of the cue list.
      - id: memory_count
        type: u4
        doc: |
          Unsure what this means.
      - id: cues
        type: cue_entry
        repeat: expr
        repeat-expr: len_cues

  cue_entry:
    doc: |
      A cue list entry. Can either represent a memory cue or a loop.
    seq:
      - contents: "PCPT"
      - id: len_header
        type: u4
      - id: len_entry
        type: u4
      - id: hot_cue
        type: u4
        doc: |
          If zero, this is an ordinary memory cue, otherwise this a
          hot cue with the specified number.
      - id: status
        type: u4
        enum: cue_entry_status
        doc: |
          If zero, this entry should be ignored.
      - type: u4  # Seems to always be 0x10000
      - id: order_first
        type: u2
        doc: |
          @flesniak says: "0xffff for first cue, 0,1,3 for next"
      - id: order_last
        type: u2
        doc: |
          @flesniak says: "1,2,3 for first, second, third cue, 0xffff for last"
      - id: type
        type: u1
        enum: cue_entry_type
        doc: |
          Indicates whether this is a memory cue or a loop.
      - size: 3  # seems to always be 1000
      - id: time
        type: u4
        doc: |
          The position, in milliseconds, at which the cue point lies
          in the track.
      - id: loop_time
        type: u4
        doc: |
          The position, in milliseconds, at which the player loops
          back to the cue time if this is a loop.
      - size: 16

  path_tag:
    doc: |
      Stores the file path of the audio file to which this analysis
      applies.
    seq:
      - id: len_path
        type: u4
      - id: path
        type: str
        size: len_path - 2
        encoding: utf-16be
        if: len_path > 1

  vbr_tag:
    doc: |
      Stores an index allowing rapid seeking to particular times
      within a variable-bitrate audio file.
    seq:
      - type: u4
      - id: index
        type: u4
        repeat: expr
        repeat-expr: 400

  wave_preview_tag:
    doc: |
      Stores a waveform preview image suitable for display above
      the touch strip for jumping to a track position.
    seq:
      - id: len_preview
        type: u4
        doc: |
          The length, in bytes, of the preview data itself. This is
          slightly redundant because it can be computed from the
          length of the tag.
      - type: u4  # This seems to always have the value 0x10000
      - id: data
        size: len_preview
        doc: |
          The actual bytes of the waveform preview.

  wave_scroll_tag:
    doc: |
      A larger waveform image suitable for scrolling along as a track
      plays.
    seq:
      - type: u4  # Always 1?
      - id: len_entries
        type: u4
        doc: |
          The number of waveform data points, each of which takes one
          byte.
      - type: u4  # Always 0x960000?
      - id: entries
        size: len_entries

  wave_color_preview_tag:
    doc: |
      A larger, colorful waveform preview image suitable for display
      above the touch strip for jumping to a track position on newer
      high-resolution players.
    seq:
      - type: u4
      - id: len_entries
        type: u4
        doc: |
          The number of waveform data points, each of which takes one
          byte for each of six channels of information.
      - type: u4
      - id: entries
        size: len_entries * 6

  wave_color_scroll_tag:
    doc: |
      A larger, colorful waveform image suitable for scrolling along
      as a track plays on newer high-resolution hardware. Also
      contains a higher-resolution blue/white waveform.
    seq:
      - type: u4  # I have seen the value 2?
      - id: len_entries
        type: u4
        doc: |
          The number of columns of waveform data (this matches the
          non-color waveform length), but we do not yet know how to
          translate the payload into color columns.
      - type: u4
      - id: entries
        size-eos: true

enums:
  section_tags:
    0x50434f42: cues                # PCOB
    0x50434f32: cues_2              # PCO2 (seen in .EXT)
    0x50505448: path                # PPTH
    0x50564252: vbr                 # PVBR
    0x5051545a: beat_grid           # PQTZ
    0x50574156: wave_preview        # PWAV
    0x50575632: wave_tiny           # PWV2
    0x50575633: wave_scroll         # PWV3 (seen in .EXT)
    0x50575634: wave_color_preview  # PWV4 (seen in .EXT)
    0x50575635: wave_color_scroll   # PWV5 (seen in .EXT)

  cue_list_type:
    0: memory_cues
    1: hot_cues

  cue_entry_type:
    1: memory_cue
    2: loop

  cue_entry_status:
    0: disabled
    1: enabled
