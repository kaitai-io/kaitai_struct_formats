meta:
  id: wav
  title: Microsoft WAVE audio file
  file-extension:
    - wav
    - bwf
  xref:
    justsolve:
      - WAV
      - BWF
    loc:
      - fdd000001 # WAV
      - fdd000002 # WAV PCM
      - fdd000356 # BWF v1
      - fdd000003 # BWF v1 PCM
      - fdd000357 # BWF v2
      - fdd000359 # BWF v2 PCM
    mime:
      - audio/vnd.wave
      - audio/wav
      - audio/wave
      - audio/x-wav
    pronom:
      - fmt/6 # WAV
      - fmt/141 # WAV PCM
      - fmt/142 # WAV non-PCM but not extensible
      - fmt/143 # WAV extensible

      # see <http://fileformats.archiveteam.org/wiki/BWF>
      - fmt/1 # BWF v0
      - fmt/703 # BWF v0 PCM
      - fmt/706 # BWF v0 MPEG
      - fmt/709 # BWF v0 extensible

      - fmt/2 # BWF v1
      - fmt/704 # BWF v1 PCM
      - fmt/707 # BWF v1 MPEG
      - fmt/710 # BWF v1 extensible

      - fmt/527 # BWF v2
      - fmt/705 # BWF v2 PCM
      - fmt/708 # BWF v2 MPEG
      - fmt/711 # BWF v2 extensible
    rfc: 2361
    wikidata:
      - Q217570 # WAV
      - Q922446 # BWF
  tags:
    - windows
  license: BSD-3-Clause-Attribution
  imports:
    - /common/riff
  encoding: ASCII
  endian: le
doc: |
  The WAVE file format is a subset of Microsoft's RIFF specification for the
  storage of multimedia files. A RIFF file starts out with a file header
  followed by a sequence of data chunks. A WAVE file is often just a RIFF
  file with a single "WAVE" chunk which consists of two sub-chunks --
  a "fmt " chunk specifying the data format and a "data" chunk containing
  the actual sample data, although other chunks exist and are used.

  An extension of the file format is the Broadcast Wave Format (BWF) for radio
  broadcasts. Sample files can be found at:

  <https://www.bbc.co.uk/rd/publications/saqas>

  This Kaitai implementation was written by John Byrd of Gigantic Software
  (jbyrd@giganticsoftware.com), and it is likely to contain bugs.
doc-ref:
  - http://soundfile.sapp.org/doc/WaveFormat/
  - http://www-mmsp.ece.mcgill.ca/Documents/AudioFormats/WAVE/WAVE.html
  - https://web.archive.org/web/20101031101749/http://www.ebu.ch/fr/technical/publications/userguides/bwf_user_guide.php
seq:
  - id: chunk
    type: 'riff::chunk'
instances:
  chunk_id:
    value: chunk.id
    enum: fourcc
  is_riff_chunk:
    value: 'chunk_id == fourcc::riff'
  parent_chunk_data:
    io: chunk.data_slot._io
    pos: 0
    type: 'riff::parent_chunk_data'
    if: is_riff_chunk
  form_type:
    value: parent_chunk_data.form_type
    enum: fourcc
  is_form_type_wave:
    value: 'is_riff_chunk and form_type == fourcc::wave'
  subchunks:
    io: parent_chunk_data.subchunks_slot._io
    pos: 0
    type: chunk_type
    repeat: eos
    if: is_form_type_wave
types:
  chunk_type:
    seq:
      - id: chunk
        type: 'riff::chunk'
    instances:
      chunk_id:
        value: chunk.id
        enum: fourcc
      chunk_data:
        io: chunk.data_slot._io
        pos: 0
        type:
          switch-on: chunk_id
          cases:
            'fourcc::fmt': format_chunk_type
            'fourcc::cue': cue_chunk_type
            'fourcc::data': data_chunk_type
            'fourcc::list': list_chunk_type
            'fourcc::fact': fact_chunk_type
            'fourcc::pmx': pmx_chunk_type
            'fourcc::ixml': ixml_chunk_type
            'fourcc::bext': bext_chunk_type
            'fourcc::axml': axml_chunk_type
            'fourcc::afsp': afsp_chunk_type

  list_chunk_type:
    seq:
      - id: parent_chunk_data
        type: 'riff::parent_chunk_data'
    instances:
      form_type:
        value: parent_chunk_data.form_type
        enum: fourcc
      subchunks:
        io: parent_chunk_data.subchunks_slot._io
        pos: 0
        type:
          switch-on: form_type
          cases:
            'fourcc::info': info_chunk_type
        repeat: eos

  info_chunk_type:
    seq:
      - id: chunk
        type: 'riff::chunk'
    instances:
      chunk_data:
        io: chunk.data_slot._io
        pos: 0
        type: strz

  bext_chunk_type:
    doc-ref: https://en.wikipedia.org/wiki/Broadcast_Wave_Format
    seq:
      - id: description
        size: 256
        type: strz
      - id: originator
        size: 32
        type: strz
      - id: originator_reference
        size: 32
        type: strz
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

  axml_chunk_type:
    doc-ref: https://tech.ebu.ch/docs/tech/tech3285s5.pdf
    seq:
      - id: data
        size-eos: true
        type: str
        encoding: UTF-8

  ixml_chunk_type:
    doc-ref: https://en.wikipedia.org/wiki/IXML
    seq:
      - id: data
        size-eos: true
        type: str
        encoding: UTF-8

  cue_chunk_type:
    seq:
      - id: dw_cue_points
        type: u4
      - id: cue_points
        type: cue_point_type
        repeat: expr
        repeat-expr: dw_cue_points

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

  fact_chunk_type:
    doc: |
      required for all non-PCM formats
      (`w_format_tag != w_format_tag_type::pcm` or `not is_basic_pcm` in
      `format_chunk_type` context)
    seq:
      - id: num_samples_per_channel
        -orig-id: dwSampleLength
        type: u4

  format_chunk_type:
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
    instances:
      is_extensible:
        value: w_format_tag == w_format_tag_type::extensible
      is_basic_pcm:
        value: w_format_tag == w_format_tag_type::pcm
      is_basic_float:
        value: w_format_tag == w_format_tag_type::ieee_float
      is_cb_size_meaningful:
        value: not is_basic_pcm and cb_size != 0

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

  pmx_chunk_type:
    seq:
      - id: data
        size-eos: true
        type: str
        encoding: UTF-8
        doc: XMP data
        doc-ref: https://wwwimages2.adobe.com/content/dam/acom/en/devnet/xmp/pdfs/XMP%20SDK%20Release%20cc-2016-08/XMPSpecificationPart3.pdf

  afsp_chunk_type:
    doc-ref: http://www-mmsp.ece.mcgill.ca/Documents/Downloads/AFsp/
    seq:
      - id: magic
        contents: "AFsp"
      - id: info_records
        type: strz
        # The AFsp package uses C strings, so the encoding isn't strictly
        # defined. Therefore, it seems reasonable to assume ASCII.
        encoding: ASCII
        repeat: eos
        doc: |
          An array of AFsp information records, in the `<field_name>: <value>`
          format (e.g. "`program: CopyAudio`"). The list of existing information
          record types are available in the `doc-ref` links.
        doc-ref:
          - http://www-mmsp.ece.mcgill.ca/Documents/Software/Packages/AFsp/libtsp/AFsetInfo.html
          - http://www-mmsp.ece.mcgill.ca/Documents/Software/Packages/AFsp/libtsp/AFprintInfoRecs.html

enums:
  w_format_tag_type:
    0x0000: unknown
    0x0001: pcm
    0x0002: adpcm
    0x0003: ieee_float
    0x0004: vselp
    0x0005: ibm_cvsd
    0x0006: alaw
    0x0007: mulaw
    0x0008: dts
    0x0009: drm
    0x000a: wmavoice9
    0x000b: wmavoice10
    0x0010: oki_adpcm
    0x0011: dvi_adpcm
    0x0012: mediaspace_adpcm
    0x0013: sierra_adpcm
    0x0014: g723_adpcm
    0x0015: digistd
    0x0016: digifix
    0x0017: dialogic_oki_adpcm
    0x0018: mediavision_adpcm
    0x0019: cu_codec
    0x001a: hp_dyn_voice
    0x0020: yamaha_adpcm
    0x0021: sonarc
    0x0022: dspgroup_truespeech
    0x0023: echosc1
    0x0024: audiofile_af36
    0x0025: aptx
    0x0026: audiofile_af10
    0x0027: prosody_1612
    0x0028: lrc
    0x0030: dolby_ac2
    0x0031: gsm610
    0x0032: msnaudio
    0x0033: antex_adpcme
    0x0034: control_res_vqlpc
    0x0035: digireal
    0x0036: digiadpcm
    0x0037: control_res_cr10
    0x0038: nms_vbxadpcm
    0x0039: cs_imaadpcm
    0x003a: echosc3
    0x003b: rockwell_adpcm
    0x003c: rockwell_digitalk
    0x003d: xebec
    0x0040: g721_adpcm
    0x0041: g728_celp
    0x0042: msg723
    0x0043: intel_g723_1
    0x0044: intel_g729
    0x0045: sharp_g726
    0x0050: mpeg
    0x0052: rt24
    0x0053: pac
    0x0055: mpeglayer3
    0x0059: lucent_g723
    0x0060: cirrus
    0x0061: espcm
    0x0062: voxware
    0x0063: canopus_atrac
    0x0064: g726_adpcm
    0x0065: g722_adpcm
    0x0066: dsat
    0x0067: dsat_display
    0x0069: voxware_byte_aligned
    0x0070: voxware_ac8
    0x0071: voxware_ac10
    0x0072: voxware_ac16
    0x0073: voxware_ac20
    0x0074: voxware_rt24
    0x0075: voxware_rt29
    0x0076: voxware_rt29hw
    0x0077: voxware_vr12
    0x0078: voxware_vr18
    0x0079: voxware_tq40
    0x007a: voxware_sc3
    0x007b: voxware_sc3_1
    0x0080: softsound
    0x0081: voxware_tq60
    0x0082: msrt24
    0x0083: g729a
    0x0084: mvi_mvi2
    0x0085: df_g726
    0x0086: df_gsm610
    0x0088: isiaudio
    0x0089: onlive
    0x008a: multitude_ft_sx20
    0x008b: infocom_its_g721_adpcm
    0x008c: convedia_g729
    0x008d: congruency
    0x0091: sbc24
    0x0092: dolby_ac3_spdif
    0x0093: mediasonic_g723
    0x0094: prosody_8kbps
    0x0097: zyxel_adpcm
    0x0098: philips_lpcbb
    0x0099: packed
    0x00a0: malden_phonytalk
    0x00a1: racal_recorder_gsm
    0x00a2: racal_recorder_g720_a
    0x00a3: racal_recorder_g723_1
    0x00a4: racal_recorder_tetra_acelp
    0x00b0: nec_aac
    0x00ff: raw_aac1
    0x0100: rhetorex_adpcm
    0x0101: irat
    0x0111: vivo_g723
    0x0112: vivo_siren
    0x0120: philips_celp
    0x0121: philips_grundig
    0x0123: digital_g723
    0x0125: sanyo_ld_adpcm
    0x0130: siprolab_aceplnet
    0x0131: siprolab_acelp4800
    0x0132: siprolab_acelp8v3
    0x0133: siprolab_g729
    0x0134: siprolab_g729a
    0x0135: siprolab_kelvin
    0x0136: voiceage_amr
    0x0140: g726adpcm
    0x0141: dictaphone_celp68
    0x0142: dictaphone_celp54
    0x0150: qualcomm_purevoice
    0x0151: qualcomm_halfrate
    0x0155: tubgsm
    0x0160: msaudio1
    0x0161: wmaudio2
    0x0162: wmaudio3
    0x0163: wmaudio_lossless
    0x0164: wmaspdif
    0x0170: unisys_nap_adpcm
    0x0171: unisys_nap_ulaw
    0x0172: unisys_nap_alaw
    0x0173: unisys_nap_16k
    0x0174: sycom_acm_syc008
    0x0175: sycom_acm_syc701_g726l
    0x0176: sycom_acm_syc701_celp54
    0x0177: sycom_acm_syc701_celp68
    0x0178: knowledge_adventure_adpcm
    0x0180: fraunhofer_iis_mpeg2_aac
    0x0190: dts_ds
    0x0200: creative_adpcm
    0x0202: creative_fastspeech8
    0x0203: creative_fastspeech10
    0x0210: uher_adpcm
    0x0215: ulead_dv_audio
    0x0216: ulead_dv_audio_1
    0x0220: quarterdeck
    0x0230: ilink_vc
    0x0240: raw_sport
    0x0241: esst_ac3
    0x0249: generic_passthru
    0x0250: ipi_hsx
    0x0251: ipi_rpelp
    0x0260: cs2
    0x0270: sony_scx
    0x0271: sony_scy
    0x0272: sony_atrac3
    0x0273: sony_spc
    0x0280: telum_audio
    0x0281: telum_ia_audio
    0x0285: norcom_voice_systems_adpcm
    0x0300: fm_towns_snd
    0x0350: micronas
    0x0351: micronas_celp833
    0x0400: btv_digital
    0x0401: intel_music_coder
    0x0402: indeo_audio
    0x0450: qdesign_music
    0x0500: on2_vp7_audio
    0x0501: on2_vp6_audio
    0x0680: vme_vmpcm
    0x0681: tpc
    0x08ae: lightwave_lossless
    0x1000: oligsm
    0x1001: oliadpcm
    0x1002: olicelp
    0x1003: olisbc
    0x1004: oliopr
    0x1100: lh_codec
    0x1101: lh_codec_celp
    0x1102: lh_codec_sbc8
    0x1103: lh_codec_sbc12
    0x1104: lh_codec_sbc16
    0x1400: norris
    0x1401: isiaudio_2
    0x1500: soundspace_musicompress
    0x1600: mpeg_adts_aac
    0x1601: mpeg_raw_aac
    0x1602: mpeg_loas
    0x1608: nokia_mpeg_adts_aac
    0x1609: nokia_mpeg_raw_aac
    0x160a: vodafone_mpeg_adts_aac
    0x160b: vodafone_mpeg_raw_aac
    0x1610: mpeg_heaac
    0x181c: voxware_rt24_speech
    0x1971: sonicfoundry_lossless
    0x1979: innings_telecom_adpcm
    0x1c07: lucent_sx8300p
    0x1c0c: lucent_sx5363s
    0x1f03: cuseeme
    0x1fc4: ntcsoft_alf2cm_acm
    0x2000: dvm
    0x2001: dts2
    0x3313: makeavis
    0x4143: divio_mpeg4_aac
    0x4201: nokia_adaptive_multirate
    0x4243: divio_g726
    0x434c: lead_speech
    0x564c: lead_vorbis
    0x5756: wavpack_audio
    0x674f: ogg_vorbis_mode_1
    0x6750: ogg_vorbis_mode_2
    0x6751: ogg_vorbis_mode_3
    0x676f: ogg_vorbis_mode_1_plus
    0x6770: ogg_vorbis_mode_2_plus
    0x6771: ogg_vorbis_mode_3_plus
    0x7000: threecom_nbx
    0x706d: faad_aac
    0x7361: amr_nb
    0x7362: amr_wb
    0x7363: amr_wp
    0x7a21: gsm_amr_cbr
    0x7a22: gsm_amr_vbr_sid
    0xa100: comverse_infosys_g723_1
    0xa101: comverse_infosys_avqsbc
    0xa102: comverse_infosys_sbc
    0xa103: symbol_g729_a
    0xa104: voiceage_amr_wb
    0xa105: ingenient_g726
    0xa106: mpeg4_aac
    0xa107: encore_g726
    0xa108: zoll_asao
    0xa109: speex_voice
    0xa10a: vianix_masc
    0xa10b: wm9_spectrum_analyzer
    0xa10c: wmf_spectrum_anayzer
    0xa10d: gsm_610
    0xa10e: gsm_620
    0xa10f: gsm_660
    0xa110: gsm_690
    0xa111: gsm_adaptive_multirate_wb
    0xa112: polycom_g722
    0xa113: polycom_g728
    0xa114: polycom_g729_a
    0xa115: polycom_siren
    0xa116: global_ip_ilbc
    0xa117: radiotime_time_shift_radio
    0xa118: nice_aca
    0xa119: nice_adpcm
    0xa11a: vocord_g721
    0xa11b: vocord_g726
    0xa11c: vocord_g722_1
    0xa11d: vocord_g728
    0xa11e: vocord_g729
    0xa11f: vocord_g729_a
    0xa120: vocord_g723_1
    0xa121: vocord_lbc
    0xa122: nice_g728
    0xa123: france_telecom_g729
    0xa124: codian
    0xf1ac: flac
    0xfffe: extensible
    0xffff: development

  fourcc:
    # little-endian
    0x46464952: riff
    0x45564157: wave
    0x5453494c: list
    0x4f464e49: info
    0x74636166: fact
    0x20746d66: fmt
    0x20657563: cue
    0x61746164: data
    0x64696d75: umid
    0x666e696d: minf
    0x6e676572: regn
    0x20336469: id3
    0x4b414550: peak
    0x584d505f: pmx
    # BWF chunks
    0x74786562: bext
    0x6c6d7861: axml
    0x4c4d5869: ixml
    0x616e6863:
      id: chna
      doc: Audio definition model
      doc-ref: https://www.itu.int/rec/R-REC-BS.2076-2-201910-I/en
    0x70736661:
      id: afsp
      doc: AFsp metadata
