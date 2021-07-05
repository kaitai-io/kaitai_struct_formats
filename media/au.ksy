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
  - https://en.wikipedia.org/wiki/Au_file_format
  - https://web.archive.org/web/20121028010008/http://www-mmsp.ece.mcgill.ca/Documents/AudioFormats/AU/AU.html
seq:
  - id: header
    type: header
  - id: description
    type: strz
    encoding: ASCII
    size: header.len_header - sizeof<header>
types:
  header:
    seq:
      - id: magic
        contents: ".snd"
      - id: len_header
        type: u4
        valid:
          min: 24
      - id: data_size
        type: u4
      - id: encoding
        type: u4
        enum: encodings
      - id: sample_rate
        type: u4
      - id: num_channels
        type: u4
enums:
  encodings:
    1: mulaw_8
    2: linear_8
    3: linear_16
    4: linear_24
    5: linear_32
    6: float
    7: double
    8: fragmented_sample_data
    9: dsp_program
    10: fixed_point_8
    11: fixed_point_16
    12: fixed_point_24
    13: fixed_point_32
    18: linear_emphasis_16
    19: linear_compressed_16
    20: linear_emphasis_compressed_16
    21: music_kit_dsp
    23: adpcm_g721
    24: adpcm_g722
    25: adpcm_g723_3
    26: adpcm_g723_5
    27: alaw_8
