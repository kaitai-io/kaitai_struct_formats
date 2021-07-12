meta:
  id: au
  title: AU audio format
  file-extension:
    - au
    - snd
  xref:
    justsolve: AU
    mime: audio/basic
    pronom: x-fmt/139
    wikidata: Q672985
  license: CC0-1.0
  ks-version: 0.9
  endian: be
doc: |
  Test files for AU can be found in the Python Git repository:

  https://github.com/python/cpython/tree/b8a7daf077dab18e9e3701c5380b542ae0aa9a94/Lib/test/sndhdrdata

  as well as:

  ftp://ftp-ccrma.stanford.edu/pub/Lisp/sf.tar.gz
doc-ref:
  # - https://en.wikipedia.org/wiki/Au_file_format # incorrect encoding enum, don't use
  - http://www-mmsp.ece.mcgill.ca/Documents/AudioFormats/AU/AU.html
  - http://soundfile.sapp.org/doc/NextFormat/

  # Resources used to assemble the `encodings` enum:
  - http://soundfile.sapp.org/doc/NextFormat/soundstruct.h
  - https://github.com/andreiw/polaris/blob/deb47cb/usr/src/head/audio/au.h#L87-L112
  - https://github.com/libsndfile/libsndfile/blob/86c9f9eb/src/au.c#L39-L74
  - https://github.com/chirlu/sox/blob/dd8b63bd/src/au.c#L34-L49
  - https://github.com/mpruett/audiofile/blob/b62c902/libaudiofile/NeXT.cpp#L65-L96

seq:
  - id: magic
    contents: ".snd"
  - id: len_header
    type: u4
  - id: header
    type: header
    size: len_header - magic._sizeof - len_header._sizeof
types:
  header:
    seq:
      - id: data_size
        type: u4
      - id: encoding
        type: u4
        enum: encodings
      - id: sample_rate
        type: u4
      - id: num_channels
        type: u4
      - id: comment
        size-eos: true
        type: strz
        encoding: ASCII
enums:
  encodings:
    1:
      id: mulaw_8
      doc: 8-bit G.711 mu-law
    2:
      id: linear_8
      doc: 8-bit signed linear PCM
    3:
      id: linear_16
      doc: 16-bit signed linear PCM
    4:
      id: linear_24
      doc: 24-bit signed linear PCM
    5:
      id: linear_32
      doc: 32-bit signed linear PCM
    6:
      id: float
      doc: 32-bit IEEE floating point
    7:
      id: double
      doc: 64-bit IEEE double-precision floating point
    8:
      id: fragmented
      doc: sampled data which has become fragmented due to editing
    9:
      id: nested
      doc: multiple sound structures
    10:
      id: dsp_core
      doc: a loadable DSP core program
    11: fixed_point_8
    12: fixed_point_16
    13: fixed_point_24
    14: fixed_point_32
    16:
      id: display
      doc: non-audio display data used by the Sound Kit's `SoundView` class, can't be played
    17:
      id: mulaw_squelch
      doc: 8-bit mu-law with run-length encoding of silence
    18:
      id: emphasized
      doc: 16-bit linear with emphasis
    19:
      id: compressed
      doc: 16-bit linear with NeXT compression
    20:
      id: compressed_emphasized
      doc: 16-bit linear with emphasis and NeXT compression
    21:
      id: dsp_commands
      doc: Music Kit DSP commands
    22:
      id: dsp_commands_samples
      doc: Music Kit DSP samples
    23:
      id: adpcm_g721
      doc: 4-bit G.721 ADPCM (32 kb/s)
    24:
      id: adpcm_g722
      doc: G.722 ADPCM
    25:
      id: adpcm_g723_3
      doc: 3-bit G.723 ADPCM (24 kb/s)
    26:
      id: adpcm_g723_5
      doc: 5-bit G.723 ADPCM (40 kb/s)
    27:
      id: alaw_8
      doc: 8-bit G.711 A-law
    28: aes
    29: delta_mulaw_8
