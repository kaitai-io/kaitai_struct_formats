meta:
  id: creative_voice_file
  title: Creative Voice File
  file-extension: voc
  xref:
    justsolve: Creative_Voice_File
    mime: audio/x-voc
    wikidata: Q27967410
  license: CC0-1.0
  endian: le
doc: |
  Creative Voice File is a container file format for digital audio
  wave data. Initial revisions were able to support only unsigned
  8-bit PCM and ADPCM data, later versions were revised to add support
  for 16-bit PCM and a-law / u-law formats.

  This format was actively used in 1990s, around the advent of
  Creative's sound cards (Sound Blaster family). It was a popular
  choice for a digital sound container in lots of games and multimedia
  software due to simplicity and availability of Creative's recording
  / editing tools.
doc-ref: 'https://wiki.multimedia.cx/index.php?title=Creative_Voice'
# http://fabiensanglard.net/reverse_engineering_strike_commander/docs/Creative%20Voice%20(VOC)%20file%20format.txt
seq:
  - id: magic
    contents:
      - 'Creative Voice File'
      - 0x1a
  - id: header_size
    type: u2
    doc: Total size of this main header (usually 0x001A)
  - id: version
    type: u2
  - id: checksum
    type: u2
    doc: 'Checksum: this must be equal to ~version + 0x1234'
  - id: blocks
    type: block
    repeat: eos
    doc: Series of blocks that contain the actual audio data
types:
  block:
    seq:
      - id: block_type
        type: u1
        enum: block_types
        doc: Byte that determines type of block content
      - id: body_size1
        type: u2
        if: block_type != block_types::terminator
      - id: body_size2
        type: u1
        if: block_type != block_types::terminator
      - id: body
        size: body_size
        type:
          switch-on: block_type
          cases:
            'block_types::sound_data': block_sound_data
            'block_types::silence': block_silence
            'block_types::marker': block_marker
            #'block_types::text': block_text
            'block_types::repeat_start': block_repeat_start
            #'block_types::repeat_end': always_empty_block
            'block_types::extra_info': block_extra_info
            'block_types::sound_data_new': block_sound_data_new
        if: block_type != block_types::terminator
        doc: Block body, type depends on block type byte
    instances:
      body_size:
        value: body_size1 + (body_size2 << 16)
        if: block_type != block_types::terminator
        doc: |
          body_size is a 24-bit little-endian integer, so we're
          emulating that by adding two standard-sized integers
          (body_size1 and body_size2).
  block_sound_data:
    doc-ref: 'https://wiki.multimedia.cx/index.php?title=Creative_Voice#Block_type_0x01:_Sound_data'
    seq:
      - id: freq_div
        type: u1
        doc: Frequency divisor, used to determine sample rate
      - id: codec
        type: u1
        enum: codecs
      - id: wave
        size-eos: true
    instances:
      sample_rate:
        value: 1000000.0 / (256 - freq_div)
  block_silence:
    doc-ref: 'https://wiki.multimedia.cx/index.php?title=Creative_Voice#Block_type_0x03:_Silence'
    seq:
      - id: duration_samples
        type: u2
        doc: Duration of silence, in samples
      - id: freq_div
        type: u1
        doc: Frequency divisor, used to determine sample rate
    instances:
      sample_rate:
        value: 1000000.0 / (256 - freq_div)
      duration_sec:
        value: duration_samples / sample_rate
        doc: Duration of silence, in seconds
  block_marker:
    doc-ref: 'https://wiki.multimedia.cx/index.php?title=Creative_Voice#Block_type_0x04:_Marker'
    seq:
      - id: marker_id
        type: u2
        doc: Marker ID
  block_repeat_start:
    doc-ref: 'https://wiki.multimedia.cx/index.php?title=Creative_Voice#Block_type_0x06:_Repeat_start'
    seq:
      - id: repeat_count_1
        type: u2
        doc: Number of repetitions minus 1; 0xffff means infinite repetitions
  block_extra_info:
    doc-ref: 'https://wiki.multimedia.cx/index.php?title=Creative_Voice#Block_type_0x08:_Extra_info'
    seq:
      - id: freq_div
        type: u2
        doc: Frequency divisor
      - id: codec
        type: u1
        enum: codecs
      - id: num_channels_1
        type: u1
        doc: Number of channels minus 1 (0 = mono, 1 = stereo)
    instances:
      num_channels:
        value: num_channels_1 + 1
        doc: Number of channels (1 = mono, 2 = stereo)
      sample_rate:
        value: 256000000.0 / (num_channels * (65536 - freq_div))
  block_sound_data_new:
    doc-ref: 'https://wiki.multimedia.cx/index.php?title=Creative_Voice#Block_type_0x09:_Sound_data_.28New_format.29'
    seq:
      - id: sample_rate
        type: u4
      - id: bits_per_sample
        type: u1
      - id: num_channels
        type: u1
      - id: codec
        type: u2
        enum: codecs
      - id: reserved
        size: 4
      - id: wave
        size-eos: true
enums:
  block_types:
    0: terminator
    1: sound_data
    2: sound_data_cont
    3: silence
    4: marker
    5: text
    6: repeat_start
    7: repeat_end
    8: extra_info
    9: sound_data_new
  # https://wiki.multimedia.cx/index.php?title=Creative_Voice#Supported_codec_ids
  codecs:
    0x00: pcm_8bit_unsigned
    0x01: adpcm_4bit # 4 bits to 8 bits Creative ADPCM
    0x02: adpcm_2_6bit # 3 bits to 8 bits Creative ADPCM (AKA 2.6 bits)
    0x03: adpcm_2_bit # 2 bits to 8 bits Creative ADPCM
    0x04: pcm_16bit_signed # 16 bits signed PCM
    0x06: alaw
    0x07: ulaw
    0x0200: adpcm_4_to_16bit # 4 bits to 16 bits Creative ADPCM
