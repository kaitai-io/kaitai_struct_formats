meta:
  id: aiff
  title: AIFF and AIFF-C Image File Format
  file-extension:
    - aif
    - aiff
    - aifc
  license: CC0-1.0
  ks-version: 0.9
  encoding: ASCII
  endian: be
doc-ref: 
  - https://en.wikipedia.org/wiki/Audio_Interchange_File_Format
  - https://web.archive.org/web/20071219035740/http://www.cnpbagwell.com/aiff-c.txt
  - http://www-mmsp.ece.mcgill.ca/Documents/AudioFormats/AIFF/AIFF.html
seq:
  - id: header
    type: header
  - id: aiff_type
    type: u4
    enum: aiff_type
    valid:
      any-of:
        - aiff_type::aifc
        - aiff_type::aiff
  - id: chunks
    type: chunks
    size: header.len_data - aiff_type._sizeof
types:
  header:
    seq:
      - id: magic
        contents: 'FORM'
      - id: len_data
        type: u4
  chunks:
    seq:
      - id: chunks
        type: chunk
        repeat: eos
  chunk:
    seq:
      - id: fourcc
        type: u4
        enum: fourcc
      - id: len_chunk
        type: u4
      - id: data
        size: len_chunk
        type:
          switch-on: fourcc
          cases:
            fourcc::common: common_chunk
            fourcc::fver: format_version_chunk
            fourcc::name: text_chunk
            fourcc::annotation: text_chunk
            fourcc::author: text_chunk
            fourcc::copyright: text_chunk
            fourcc::ssnd: ssnd_chunk
            fourcc::marker: marker_chunk
            fourcc::instrument: instrument_chunk
      - id: padding
        size: 1
        if: len_chunk % 2 == 1
  common_chunk:
    seq:
      - id: num_channels
        type: u2
      - id: num_sample_frames
        type: u4
      - id: sample_size
        type: u2
      - id: sample_rate
        size: 10
      - id: compression_type
        type: u4
        enum: compression
        if: _root.aiff_type == aiff_type::aifc
      - id: compression_name
        type: pstring
        if: _root.aiff_type == aiff_type::aifc
  marker_chunk:
    seq:
      - id: num_markers
        type: u2
      - id: markers
        type: marker
        repeat: expr
        repeat-expr: num_markers
  marker:
    seq:
      - id: marker_id
        type: u2
      - id: position
        type: u4
      - id: name
        type: pstring
  format_version_chunk:
    seq:
      - id: timestamp
        type: u4
        valid: 2726318400
  text_chunk:
    seq:
      - id: text
        type: str
        size-eos: true
  instrument_chunk:
    seq:
      - id: base_note
        type: u1
      - id: detune
        type: u1
      - id: low_note
        type: u1
      - id: high_note
        type: u1
      - id: low_velocity
        type: u1
      - id: gain
        type: u2
      - id: sustain_loop
        type: loop
      - id: release_loop
        type: loop
  loop:
    seq:
      - id: play_mode
        type: u2
        enum: play_mode
      - id: begin_loop
        type: u2
      - id: end_loop
        type: u2
  ssnd_chunk:
    seq:
      - id: offset
        type: u4
      - id: block_size
        type: u4
      - id: data
        size-eos: true
  pstring:
    seq:
      - id: len_string
        type: u1
      - id: string
        size: len_string
        type: str
      - id: padding
        size: 1
        if: len_string % 2 == 0
enums:
  aiff_type:
    0x41494646: aiff
    0x41494643: aifc
  fourcc:
    0x414e4e4f: annotation
    0x4150504c: application
    0x41455344: audio_recording
    0x41555448: author
    0x434f4d4d: common
    0x434f4d54: comment
    0x28632920: copyright
    0x46564552: fver
    0x4d494449: midi
    0x4e414d45: name
    0x53534e44: ssnd
    0x49443320: id3
    0x494e5354: instrument
    0x4d41524b: marker
  compression:
    0x4e4f4e45: not_compressed
    0x736f7774: sowt
    0x666c3332: fl32
    0x666c3634: fl64
    0x616c6177: alaw
    0x756c6177: ulaw
    0x414c4157: alaw_ccitt
    0x554c4157: ulaw_ccitt
    0x464c3332: float32
    0x47534d20: gsm
    0x47373232: g722
    0x47373236: g726
    0x47373238: g728
  play_mode:
    0: no_loop
    1: forward
    2: forward_backward
