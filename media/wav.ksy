meta:
  id: wav
  title: Microsoft WAVE audio file
  file-extension: wav
  license: BSD-3-Clause-Attribution
  encoding: ASCII
  endian: le
doc: |
  The WAVE file format is a subset of Microsoft's RIFF specification for the
  storage of multimedia files. A RIFF file starts out with a file header
  followed by a sequence of data chunks. A WAVE file is often just a RIFF
  file with a single "WAVE" chunk which consists of two sub-chunks --
  a "fmt " chunk specifying the data format and a "data" chunk containing
  the actual sample data.

  This Kaitai implementation was written by John Byrd of Gigantic Software
  (jbyrd@giganticsoftware.com), and it is likely to contain bugs.
doc-ref: http://soundfile.sapp.org/doc/WaveFormat/
doc-ref: https://www.loc.gov/preservation/digital/formats/fdd/fdd000001.shtml
seq:
  - id: riff_id
    contents: RIFF
  - id: file_size
    type: u4
  - id: wave_id
    contents: WAVE
  - id: chunks
    type: chunks_type
    size: file_size - 5

instances:
  format_chunk:
    value: chunks.chunk[0].data

types:
  chunks_type:
    seq:
      - id: chunk
        type: chunk_type
        repeat: eos

  chunk_type:
    seq:
      - id: chunk_id
        type: u4be
      - id: len
        type: u4
      - id: data
        size: len
        type:
          switch-on: chunk_id
          cases:
            0x666d7420: format_chunk_type
            0x62657874: bext_chunk_type
            0x63756520: cue_chunk_type
            0x64617461: data_chunk_type

  bext_chunk_type:
    seq:
    - id: description
      size: 256
      type: str
    - id: originator
      size: 32
      type: str
    - id: originator_reference
      size: 32
      type: str
    - id: origination_date
      size: 10
      type: str
    - id: origination_time
      size: 8
      type: str
    - id: time_reference_low
      type: u4
    - id: time_reference_high
      type: u4
    - id: version
      type: u2
    - id: umid
      size: 64
    - id: loudness_value
      type: u2
    - id: loudness_range
      type: u2
    - id: max_true_peak_level
      type: u2
    - id: max_momentary_loudness
      type: u2
    - id: max_short_term_loudness
      type: u2

  cue_chunk_type:
    seq:
      - id: dw_cue_points
        type: u4
      - id: cue_points
        type: cue_point_type
        repeat: expr
        repeat-expr: dw_cue_points
        if: dw_cue_points != 0

  cue_point_type:
    seq:
      - id: dw_name
        type: u4
      - id: dw_position
        type: u4
      - id: fcc_chunk
        type: u4
      - id: dw_chunk_start
        type: u4
      - id: dw_block_start
        type: u4
      - id: dw_sample_offset
        type: u4

  data_chunk_type:
    seq:
      - id: data
        size-eos: true

  format_chunk_type:
    instances:
      is_extensible:
        value: w_format_tag == w_format_tag_type::extensible
      is_basic_pcm:
        value: w_format_tag == w_format_tag_type::pcm
      is_basic_float:
        value: w_format_tag == w_format_tag_type::ieee_float
      is_cb_size_meaningful:
        value: not is_basic_pcm and cb_size != 0

    seq:
      - id: w_format_tag
        type: u2
        enum: w_format_tag_type
      - id: n_channels
        type: u2
      - id: n_samples_per_sec
        type: u4
      - id: n_avg_bytes_per_sec
        type: u4
      - id: n_block_align
        type: u2
      - id: w_bits_per_sample
        type: u2
      - id: cb_size
        type: u2
        if: not is_basic_pcm
      - id: w_valid_bits_per_sample
        type: u2
        if: is_cb_size_meaningful
      - id: channel_mask_and_subformat
        type: channel_mask_and_subformat_type
        if: is_extensible

  channel_mask_and_subformat_type:
    seq:
      - id: dw_channel_mask
        type: channel_mask_type
      - id: subformat
        type: guid_type

  channel_mask_type:
    seq:
      - id: front_right_of_center
        type: b1
      - id: front_left_of_center
        type: b1
      - id: back_right
        type: b1
      - id: back_left
        type: b1

      - id: low_frequency
        type: b1
      - id: front_center
        type: b1
      - id: front_right
        type: b1
      - id: front_left
        type: b1

      - id: top_center
        type: b1
      - id: side_right
        type: b1
      - id: side_left
        type: b1
      - id: back_center
        type: b1

      - id: top_back_left
        type: b1
      - id: top_front_right
        type: b1
      - id: top_front_center
        type: b1
      - id: top_front_left
        type: b1

      - id: unused1
        type: b6

      - id: top_back_right
        type: b1
      - id: top_back_center
        type: b1

      - id: unused2
        type: b8

  guid_type:
    seq:
      - id: data1
        type: u4
      - id: data2
        type: u2
      - id: data3
        type: u2
      - id: data4
        type: u4be
      - id: data4a
        type: u4be

  samples_type:
    seq:
      - id: samples
        type: u4

  sample_type:
    seq:
      - id: sample
        type: u2

enums:
  w_format_tag_type:
    0x0000: unknown
    0x0001: pcm
    0x0002: adpcm
    0x0003: ieee_float
    0x0006: alaw
    0x0007: mulaw
    0x0011: dvi_adpcm
    0x0092: dolby_ac3_spdif
    0xfffe: extensible
    0xffff: development

  chunk_type:
    0x20746d66: fmt
    0x62657874: bext
    0x63756520: cue
    0x64617461: data
    0x756d6964: umid
    0x6d696e66: minf
    0x7265676e: regn
