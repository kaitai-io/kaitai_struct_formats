# Argon Design Ltd.
# Copyright (c) 2019 Argon Design. All rights reserved
# MP4 container parser. Parses general as well as AV1 and VP9 specific boxes.
meta:
  id: mp4
  imports:
    - vlq_base128_be
  application: QuickTime, MP4 ISO/IEC 14496-12:2005(E) media
  license: New BSD License (3-clause license)
  endian: be
doc-ref: ISO/IEC 14496-12:2005(E)
seq:
  - id: boxes
    type: box_list
types:
  box_list:
    seq:
      - id: items
        type: box
        repeat: eos
  box:
    seq:
      - id: len32
        type: u4
      - id: box_type
        type: u4
        enum: box_type
      - id: len64
        type: u8
        if: len32 == 1
      - id: body
        size: len
        type:
          switch-on: box_type
          cases:
            # Box types which actually just contain other boxes inside it
            'box_type::dinf': box_list
            'box_type::mdia': box_list
            'box_type::minf': box_list
            'box_type::moof': box_list
            'box_type::moov': box_list
            'box_type::stbl': box_list
            'box_type::traf': box_list
            'box_type::trak': box_list
            'box_type::udta': box_list
            'box_type::edts': box_list

            # Leaf boxes that have some distinct format inside
            'box_type::avc1': avc1_body
            'box_type::ftyp': ftyp_body
            'box_type::tkhd': tkhd_body
            'box_type::mvhd': mvhd_body
            'box_type::mdhd': mdhd_body
            'box_type::hdlr': hdlr_body
            'box_type::vmhd': vmhd_body
            'box_type::smhd': smhd_body
            'box_type::hmhd': hmhd_body
            'box_type::nmhd': nmhd_body
            'box_type::dref': dref_body
            'box_type::url' : url_body
            'box_type::urn' : urn_body
            'box_type::stsd': stsd_body
            'box_type::mp4a': mp4a_body
            'box_type::stss': stss_body
            'box_type::stts': stts_body
            'box_type::stsz': stsz_body
            'box_type::stsc': stsc_body
            'box_type::stco': stco_body
            'box_type::co64': co64_body
            'box_type::meta': meta_body
            'box_type::elst': elst_body
            'box_type::sgpd': sgpd_body
            'box_type::sbgp': sbgp_body
            'box_type::esds': esds_body

            # boxes that are part of MP4 standard for AV1 codec
            'box_type::av01': av01_body
            'box_type::av1c': av1c_body

            # boxes that are part of MP4 standard for VP9 codec
            'box_type::vp09': vp09_body
            'box_type::vpcc': vpcc_body

            # boxes that are part of QuickTime spec
            'box_type::fiel': fiel_body

            # proprietary boxes that are not part of MP4 ISO/IEC 14496-12:2005(E) standard
            # iTunes related boxes
            'box_type::data': data_body
            'box_type::cart': cart_body
            'box_type::cday': cday_body
            'box_type::cgen': cgen_body
            'box_type::cnam': cnam_body
            'box_type::ctoo': ctoo_body
            'box_type::ilst': ilst_body
            'box_type::pasp': pasp_body

    instances:
      len:
        value: 'len32 == 0 ? (_io.size - 8) : (len32 == 1 ? len64 - 16 : len32 - 8)'

  full_box:
    doc-ref: |
      ISO/IEC 14496-12:2005(E), section 4.2, Full Box Type Box
    seq:
      - id: version
        type: u1
      - id: flags
        size: 3
        
  ftyp_body:
    doc-ref: |
      ISO/IEC 14496-12:2005(E), section 4.3, FTYP (File Type) Box
    seq:
      - id: major_brand
        type: u4
        enum: brand
      - id: minor_version
        type: u4
      - id: compatible_brands
        type: u4
        enum: brand
        repeat: eos

  mvhd_body:
    doc-ref: |
      ISO/IEC 14496-12:2005(E), section 8.4, MVHD (Movie Header) Box
    seq:
      - id: version_flags
        type: full_box
# Fields if version == 1
      - id: creation_time_v1
        type: u8
        if: version_flags.version == 1
      - id: modification_time_v1
        type: u8
        if: version_flags.version == 1
      - id: time_scale_v1
        type: u4
        if: version_flags.version == 1
        doc: |
          A time value that indicates the time scale for this
          movie—that is, the number of time units that pass per second
          in its time coordinate system. A time coordinate system that
          measures time in sixtieths of a second, for example, has a
          time scale of 60.
      - id: duration_v1
        type: u8
        if: version_flags.version == 1
        doc: |
          A time value that indicates the duration of the movie in
          time scale units. Note that this property is derived from
          the movie’s tracks. The value of this field corresponds to
          the duration of the longest track in the movie.
# Fields if version == 0
      - id: creation_time_v0
        type: u4
        if: version_flags.version == 0
      - id: modification_time_v0
        type: u4
        if: version_flags.version == 0
      - id: time_scale_v0
        type: u4
        if: version_flags.version == 0
        doc: |
          A time value that indicates the time scale for this
          movie—that is, the number of time units that pass per second
          in its time coordinate system. A time coordinate system that
          measures time in sixtieths of a second, for example, has a
          time scale of 60.
      - id: duration_v0
        type: u4
        if: version_flags.version == 0
        doc: |
          A time value that indicates the duration of the movie in
          time scale units. Note that this property is derived from
          the movie’s tracks. The value of this field corresponds to
          the duration of the longest track in the movie.
      - id: rate
        type: fixed_s2_u2
        doc: The rate at which to play this movie. A value of 1.0 indicates normal rate.
      - id: volume
        type: fixed_s1_u1
        doc: How loud to play this movie’s sound. A value of 1.0 indicates full volume.
      - id: reserved1
        size: 10
      - id: matrix
        size: 36
        doc: A matrix shows how to map points from one coordinate space into another.
      - id: pre_defined
        size: 24
      - id: next_track_id
        type: u4
        doc: |
          Indicates a value to use for the track ID number of the next
          track added to this movie. Note that 0 is not a valid track
          ID value.

  tkhd_body:
    doc-ref: |
      ISO/IEC 14496-12:2005(E), section 8.5, TKHD (Track Header) Box
    seq:
      - id: version_flags
        type: full_box
# Fields if version == 1
      - id: creation_time_v1
        type: u8
        if: version_flags.version == 1
      - id: modification_time_v1
        type: u8
        if: version_flags.version == 1
      - id: track_id_v1
        type: u4
        if: version_flags.version == 1
        doc: Integer that uniquely identifies the track. The value 0 cannot be used.
      - id: reserved1_v1
        size: 4
        if: version_flags.version == 1
      - id: duration_v1
        type: u8
        if: version_flags.version == 1
# Fields if version == 0
      - id: creation_time_v0
        type: u4
        if: version_flags.version == 0
      - id: modification_time_v0
        type: u4
        if: version_flags.version == 0
      - id: track_id_v0
        type: u4
        if: version_flags.version == 0
        doc: Integer that uniquely identifies the track. The value 0 cannot be used.
      - id: reserved1_v0
        size: 4
        if: version_flags.version == 0
      - id: duration_v0
        type: u4
        if: version_flags.version == 0
      - id: reserved2
        size: 8
      - id: layer
        type: u2
      - id: alternative_group
        type: u2
      - id: volume
        type: u2
      - id: reserved3
        size: 2
      - id: matrix
        size: 36
      - id: width
        type: fixed_s2_u2
      - id: height
        type: fixed_s2_u2

  fixed_u2_u2:
    doc: Fixed-point 32-bit number containing unsigned integer 16 bit and unsigned fractional 16 bit part.
    seq:
      - id: int_part
        type: u2
      - id: frac_part
        type: u2

  fixed_s2_u2:
    doc: Fixed-point 32-bit number containing signed integer 16 bit and unsigned fractional 16 bit part.
    seq:
      - id: int_part
        type: s2
      - id: frac_part
        type: u2

  fixed_s2_s2:
    doc: Fixed-point 32-bit number containing signed integer 16 bit and signed fractional 16 bit part.
    seq:
      - id: int_part
        type: s2
      - id: frac_part
        type: s2
        
  fixed_s1_u1:
    doc: Fixed-point 16-bit number containing signed integer 8 bit and unsigned fractional 8 bit part.
    seq:
      - id: int_part
        type: s1
      - id: frac_part
        type: u1

  mdhd_body:
    doc-ref: |
      ISO/IEC 14496-12:2005(E), section 8.8, MDHR (Media Header) Box
    seq:
      - id: version_flags
        type: full_box
# Fields if version == 1
      - id: creation_time_v1
        type: u8
        if: version_flags.version == 1
      - id: modification_time_v1
        type: u8
        if: version_flags.version == 1
      - id: timescale_v1
        type: u4
        if: version_flags.version == 1
      - id: duration_v1
        type: u8
        if: version_flags.version == 1
# Fields if version == 0
      - id: creation_time_v0
        type: u4
        if: version_flags.version == 0
      - id: modification_time_v0
        type: u4
        if: version_flags.version == 0
      - id: timescale_v0
        type: u4
        if: version_flags.version == 0
      - id: duration_v0
        type: u4
        if: version_flags.version == 0
      - id: pad
        type: b1
      - id: lang_0
        type: b5
        doc: ISO-639-2/T language code
      - id: lang_1
        type: b5
        doc: ISO-639-2/T language code
      - id: lang_2
        type: b5
        doc: ISO-639-2/T language code
      - id: pre_defined
        type: u2
  hdlr_body:
    doc-ref: |
      ISO/IEC 14496-12:2005(E), section 8.9, HDLR (Handler) Box
    seq:
      - id: version_flags
        type: full_box
      - id: pre_defined
        type: u4
      - id: handler_type
        type: str
        size: 4
        encoding: ASCII
        doc: specifies if this is video 'vide', sound 'soun' or hint 'hint' track
      - id: reserved
        size: 12
      - id: name
        type: strz
        encoding: UTF-8
        doc: Null-terminated human readable name for the track type

  vmhd_body:
    doc-ref: | 
      ISO/IEC 14496-12:2005(E), section 8.11.2, VMHD (Video Media Header) Box
    seq:
      - id: version_flags
        type: full_box
      - id: graphicsmode
        type: u2
        doc: composition mode for video track
      - id: opcolor_red
        type: u2
        doc: red color setting to be used by graphics mode
      - id: opcolor_green
        type: u2
        doc: green color setting to be used by graphics mode
      - id: opcolor_blue
        type: u2
        doc: blue color setting to be used by graphics mode

  smhd_body:
    doc-ref: | 
      ISO/IEC 14496-12:2005(E), section 8.11.3, SMHD (Sound Media Header) Box
    seq:
      - id: version_flags
        type: full_box
      - id: balance
        type: fixed_s1_u1
        doc: Specifies where put mono sound track in stereo space
      - id: reserved
        size: 2

  hmhd_body:
    doc: | 
      ISO/IEC 14496-12:2005(E), section 8.11.4, HMHD (Hint Media Header) Box
    seq:
      - id: version_flags
        type: full_box
      - id: maxpdusize
        type: u2
        doc: Maximum PDU size in bytes
      - id: avgpdusize
        type: u2
        doc: Average PDU size in bytes
      - id: maxbitrate
        type: u4
        doc: Maximum bit rate over any window in bits per second
      - id: avgbitrate
        type: u4
        doc: Average bir rate over entire presentation in bits per second
      - id: reserved
        size: 4

  nmhd_body:
    doc-ref: | 
      ISO/IEC 14496-12:2005(E), section 8.11.5, NMHD (Null Media Header) Box
    seq:
      - id: version_flags
        type: full_box

  dref_body:
    doc-ref: | 
      ISO/IEC 14496-12:2005(E), section 8.13, DREF (Data Reference) Box
    seq:
      - id: version_flags
        type: full_box
      - id: entry_count
        type: u4
      - id: data_entry
        type: box
        repeat: expr
        repeat-expr: entry_count

  url_body:
    doc-ref: |
      ISO/IEC 14496-12:2005(E), section 8.13, URL entry in DREF Box
    seq:
      - id: version_flags
        type: full_box
      - id: location
        type: strz
        size-eos: true
        encoding: UTF-8

  urn_body:
    doc-ref: |
      ISO/IEC 14496-12:2005(E), section 8.13, URN entry in DREF Box
    seq:
      - id: version_flags
        type: full_box
      - id: name
        type: strz
        encoding: UTF-8
      - id: location
        type: strz
        size-eos: true
        encoding: UTF-8
        
  stsd_body:
    doc-ref: |
      ISO/IEC 14496-12:2005(E), section 8.16, Sample Descripion (STSD) Box
    seq:
      - id: version_flags
        type: full_box
      - id: entry_count
        type: u4
      - id: entry
        type: box
        repeat: expr
        repeat-expr: entry_count
  
  decoder_specific_info:
    doc-ref: |
      ISO/IEC 14496-1:2004(E), section 7.2.6.7.1, DecoderSpecific info class
    seq:
      - id: specific
        size: _parent.decoder_specific_info_len.value
        doc: |
          The format information here depends on _parent.object_type_indication

  sl_config_descriptor:
    doc-ref: |
      ISO/IEC 14496-1:2004(E), section 7.2.6.7.1, DecoderSpecific info class
    seq:
      - id: predefined
        type: u1
        enum: sl_config_descriptor_predefined
      - id: use_access_unit_start_flag
        type: b1
        if: 'predefined == sl_config_descriptor_predefined::custom'
        
  decoder_config_descriptor:
    doc-ref: |
      ISO/IEC 14496-1:2004(E), section 7.2.6.6.1, DecoderConfigDescriptor class
    seq:
      - id: object_type_indication
        type: u1
        enum: object_type
        doc: |
          Indication of the object or scene description type that needs to be
          supported by the decoder for this elementary stream
      - id: stream_type
        type: b6
        enum: stream_type
        doc: |
          Type of this elementary stream
      - id: up_stream
        type: b1
        doc: |
          Indicates that this stream is used for upstream information
      - id: reserved
        type: b1
        doc: |
          Has to be equal to 1
      - id: buffer_size_db
        type: b24
        doc: |
          Size of the decoding buffer for this elementary stream in bytes
      - id: max_bitrate
        type: u4
        doc: |
          Maximum bitrate in bits per second of this elementary stream in any time
          window of one second duration
      - id: avg_bitrate
        type: u4
        doc: |
          Average bitrate in bits per second of this elementary stream. For streams with
          variable bitrate this value shall be set to zero
      - id: decoder_specific_info_tag
        # type: u1
        # enum: class_tag
        # Unfortunately Kaitai doesn't allow for enum values in contents array, so we have to hard code it
        contents: [0x05]
        doc: |
          This field has have class_tag::decspecificinfotag value. Something went wrong with the parsing if that is not the case.
      - id: decoder_specific_info_len
        type: vlq_base128_be
        doc: |
          The variable length encoded length of DecoderConfigDescriptor class
      - id: decoder_specific_info
        type: decoder_specific_info
        size: decoder_specific_info_len.value
        
  es_descriptor:
    doc-ref: | 
      ISO/IEC 14496-1:2004(E), section 7.2.6.5.1, ES_Descriptor class
    seq:
      - id: es_id
        type: u2
      - id: stream_dependence_flag
        type: b1
        doc: |
          If set, the stream depends on another elementary stream ID and this ID will follow
      - id: url_flag
        type: b1
        doc: |
          If set, the description can be found in URL and this URL will follow
      - id: ocr_stream_flag
        type: b1
        doc: |
          If set, OCR elementary syntax element will follow
      - id: stream_priority
        type: b5
        doc: |
          Indicates a relative measure for the priority of this elementary stream
      - id: depends_on_es_id
        type: u2
        if: stream_dependence_flag == true
        doc: |
          ES_ID of another elementary stream on which this elementary stream depends.
      - id: url_length
        type: u1
        if: url_flag == true
        doc: |
          The length of the subsequent URLstring in bytes
      - id: url_string
        type: str
        size: url_length
        encoding: UTF-8
        if: url_flag == true
        doc: |
          The URLstring specifying where streams elementary descriptor can be found
      - id: ocr_es_id
        type: u2
        if: ocr_stream_flag == true
        doc: |
          ES_ID of the elementary stream within the name scope from which the time
          base for this elementary stream is derived
      - id: decoder_config_descriptor_tag
        # type: u1
        # enum: class_tag
        # Unfortunately Kaitai doesn't allow for enum values in contents array, so we have to hard code it
        contents: [0x04]
        doc: |
          This field has have class_tag::decoderconfigdescrtag value. Something went wrong with the parsing if that is not the case.
      - id: decoder_config_descriptor_len
        type: vlq_base128_be
        doc: |
          The variable length encoded length of DecoderConfigDescriptor class
      - id: decoder_config_descriptor
        type: decoder_config_descriptor
        size: decoder_config_descriptor_len.value
      - id: sl_config_descriptor_tag
        # type: u1
        # enum: class_tag
        # Unfortunately Kaitai doesn't allow for enum values in contents array, so we have to hard code it
        contents: [0x06]
        doc: |
          This field has have class_tag::slconfigdescrtag value. Something went wrong with the parsing if that is not the case.
      - id: sl_config_descriptor_len
        type: vlq_base128_be
        doc: |
          The variable length encoded length of SLConfigDescriptor class
      - id: sl_config_descriptor
        type: sl_config_descriptor
        size: sl_config_descriptor_len.value
          
  esds_body:
    doc-ref: | 
      ISO/IEC 14496-1:2004(E), section 7.2.6.5.1, ES_Descriptor class
      ISO/IEC 14496-14:2003(E), section 5.6.1, class ESDBox
    seq:
      - id: version_flags
        type: full_box
      - id: es_descriptor_tag
        # type: u1
        # enum: class_tag
        # Unfortunately Kaitai doesn't allow for enum values in contents array, so we have to hard code it
        contents: [0x03]
        doc: |
          This field has have class_tag::es_descrtag value. Something went wrong with the parsing if that is not the case.
      - id: es_descriptor_len
        type: vlq_base128_be
        doc: |
          The variable length encoded length of ES_Descriptor class
      - id: es_descriptor
        type: es_descriptor
        size: es_descriptor_len.value
        doc: |
          Actual ES_Descriptor class

  sample_entry:
    doc-ref: |
      ISO/IEC 14496-12:2005(E), section 8.16.2, SampleEntry abstract class
    seq:
      - id: reserved
        size: 6
      - id: data_reference_index
        type: u2
        doc: |
          an integer that contains the index of the data reference to use to retrieve
          data associated with samples that use this sample description. Data references
          are stored in Data Reference Boxes

  hint_sample_entry:
    doc-ref: |
      ISO/IEC 14496-12:2005(E), section 8.16.2, HintSampleEntry class
    seq:
      - id: sample_entry
        type: sample_entry
      - id: data
        type: u1

  visual_sample_entry:
    doc-ref: |
      ISO/IEC 14496-12:2005(E), section 8.16.2, VisualSampleEntry class
    seq:
      - id: sample_entry
        type: sample_entry
      - id: pre_defined1
        type: u2
      - id: reserved1
        size: 2
      - id: pre_defined2
        size: 12
      - id: width
        type: u2
        doc: max video width in pixels
      - id: height
        type: u2
        doc: max video height in pixels
      - id: horizresolution
        type: fixed_u2_u2
        doc: video horizontal resolution in DPI
      - id: vertresolution
        type: fixed_u2_u2
        doc: video vertical resolution in DPI
      - id: reserved2
        size: 4
      - id: frame_count
        type: u2
        doc: indicates how many frames of compressed video are stored in each sample
      - id: compressor_name_len
        type: u1
        doc: the length of the compressor name that needs to be displayed
      - id: compressor_name
        type: strz
        size: 31
        encoding: UTF-8
      - id: depth
        type: u2
        doc: value 0x0018 means that images are in colour with no alpha
      - id: pre_defined3
        type: s2
          
  audio_sample_entry:
    doc-ref: |
      ISO/IEC 14496-12:2005(E), section 8.16.2, AudioSampleEntry class
    seq:
      - id: sample_entry
        type: sample_entry
      - id: reserved1
        size: 8
      - id: channel_count
        type: u2
      - id: sample_size
        type: u2
        doc: audion sample size in bits
      - id: pre_defined
        type: u2
      - id: reserved2
        size: 2 
      - id: samplerate
        type: fixed_u2_u2
        
  mp4a_body:
    doc-ref: |
      ISO/IEC 14496-14:2003(E), section 5.6.1, MP4AudioSampleEntry class
    seq:
      - id: audio_sample_entry
        type: audio_sample_entry
      - id: esd_box
        type: box
    
  avc1_body:
    doc-ref: |
      ISO/IEC 14496-12:2005(E), section 8.16.2, VideoSampleEntry class
    seq:
      - id: visual_sample_entry
        type: visual_sample_entry
    # TO DO: avcC and colr boxes decoding which are in avc1 box

  av1c_body:
    doc-ref: |
      https://aomediacodec.github.io/av1-isobmff/ ,section 2.3.3, AV1CodecConfigurationBox class
    seq:
      - id: marker
        type: b1
        doc: |
          Has always to be set to 1
      - id: version
        type: b7
        doc: |
          Has always to be set to 1
      - id: seq_profile
        type: b3
        doc: |
          The seq_profile value from the Sequence Header OBU
      - id: seq_level_idx_0
        type: b5
        doc: |
          The value of seq_level_idx[0] in the Sequence Header OBU
      - id: seq_tier_0
        type: b1
        doc: |
          The value of seq_tier[0] in the Sequence Header OBU
      - id: high_bitdepth
        type: b1
        doc: |
          Indicates the value of the high_bitdepth flag from the Sequence Header OBU
      - id: twelve_bit
        type: b1
        doc: |
          Indicates the value of the twelve_bit flag from the Sequence Header OBU. When twelve_bit is not
          present in the Sequence Header OBU the AV1CodecConfigurationRecord twelve_bit value SHALL be 0
      - id: monochrome
        type: b1
        doc: |
          Indicates the value of the mono_chrome flag from the Sequence Header OBU
      - id: chroma_subsampling_x
        type: b1
        doc: |
          Indicates the subsampling_x value from the Sequence Header OBU
      - id: chroma_subsampling_y
        type: b1
        doc: |
          Indicates the subsampling_y value from the Sequence Header OBU
      - id: chroma_sample_position
        type: b2
        doc: |
          Indicates the chroma_sample_position value from the Sequence Header OBU
      - id: reserved1
        type: b3
        doc: |
          Has to be set to 0
      - id: initial_presentation_delay_present
        type: b1
      - id: initial_presentation_delay_minus_one
        type: b4
        if: 'initial_presentation_delay_present == true'
      - id: reserved2
        type: b4
        if: 'initial_presentation_delay_present == false'
      # some configOBUS required here - not parsing them yet
      - id: config_obus
        size: _io.size - 4

  fiel_body:
    doc-ref: |
      https://developer.apple.com/library/archive/documentation/QuickTime/QTFF/QTFFChap3/qtff3.html , Table 4-2, video sample description extension
    seq:
      - id: field_count
        type: u1
        doc: |
          Value of 1 is used for progressive-scan images; a value of 2 indicates interlaced images.
      - id: field_ordering
        type: u1
        enum: field_ordering
        doc: |
          Specifies field ordering
    
  av01_body:
    doc-ref: |
      https://aomediacodec.github.io/av1-isobmff/ ,section 2.2.3, AV1SampleEntry class
    seq:
      - id: visual_sample_entry
        type: visual_sample_entry
      - id: av1c_box
        type: box
      # NOT_IN_SPEC
      # the following field has been added by ffmpeg, but is not present in https://aomediacodec.github.io/av1-isobmff/ spec
      - id: fiel_box
        type: box
        
  sample_delta_entry:
    doc-ref: |
      ISO/IEC 14496-12:2005(E), section 8.15.2.2, entry in TimeToSampleBox class
    seq:
      - id: sample_count
        type: u4
        doc: Sample number
      - id: sample_delta
        type: u4
        doc: Decode time delta
        
  vpcc_body:
    doc-ref: |
      https://www.webmproject.org/vp9/mp4/ VPCodecConfigurationBox class
    seq:
      - id: version_flags
        type: full_box
      - id: profile
        type: u1
        doc: |
          Integer specifies VP codec profile
      - id: level
        type: u1
        doc: |
          Integer specifies VP codec level
      - id: bit_depth
        type: b4
        doc: |
          Bit depth of luma and chroma components. Valid values are 8, 10 and 12
      - id: chroma_subsampling
        type: b3
        doc: |
          Integer specifies chroma subsampling
      - id: video_full_range_flag
        type: b1
        doc: |
          Indicates the black level and range of the luma and chroma signals
      - id: colour_primaries
        type: u1
        doc: |
           Integer that is defined by the "Colour primaries" section of ISO/IEC 23001-8:2016
      - id: transfer_characteristics
        type: u1
        doc: |
          Integer that is defined by the "Transfer characteristics" section of ISO/IEC 23001-8:2016
      - id: matrix_coefficients
        type: u1
        doc: |
          Integer that is defined by the "Matrix coefficients" section of ISO/IEC 23001-8:2016
      - id: codec_intialization_data_size
        type: u2
        doc: |
          This must be zero for VP9
  
  pasp_body:
    doc-ref: |
      https://developer.apple.com/library/archive/documentation/QuickTime/QTFF/QTFFChap3/qtff3.html#//apple_ref/doc/uid/TP40000939-CH205-124550
    seq:
      - id: h_spacing
        type: u4
        doc: |
          Integer specifying horizontal spacing of pixels
      - id: v_spacing
        type: u4
        doc: |
          Integer specifying vertical spacing of pixels
       
  vp09_body:
    doc-ref: |
      https://www.webmproject.org/vp9/mp4/ VP9SampleEntry class
    seq:
      - id: visual_sample_entry
        type: visual_sample_entry
      - id: vpcc_box
        type: box
      # NOT_IN_SPEC
      # the following fields have been added by ffmpeg, but is not present in https://www.webmproject.org/vp9/mp4/ spec
      - id: fiel_box
        type: box
      - id: pasp_box
        type: box
        
  stts_body:
    doc-ref: |
      ISO/IEC 14496-12:2005(E), section 8.15.2.2, TimeToSampleBox class
    seq:
      - id: version_flags
        type: full_box
      - id: entry_count
        type: u4
      - id: entries
        type: sample_delta_entry
        repeat: expr
        repeat-expr: entry_count

  stsz_entry:
    doc-ref: |
      ISO/IEC 14496-12:2005(E), section 8.17.2, SampleSizeBox class
    seq:
      - id: entry_size
        type: u4
        doc: The size in bytes of particular sample

  stsz_body:
    doc-ref: |
      ISO/IEC 14496-12:2005(E), section 8.17.2, SampleSizeBox class
    seq:
      - id: version_flags
        type: full_box
      - id: sample_size
        type: u4
        doc: |
          If not zero, all samples have the same size and this is the actual size in bytes. No array with sample sizes will follow
          If zero, the samples have different values specified in the following table
      - id: sample_count
        type: u4
        doc: The amount of entries in sample size table that follows
      - id: entries
        type: stsz_entry
        repeat: expr
        repeat-expr: sample_count
        if: sample_size == 0
        doc: Table with sample sizes given in bytes. Only present when sample_size == 0 indicating that the samples are different size

  stsc_entry:
    doc-ref: |
      ISO/IEC 14496-12:2005(E), section 8.18.2, SampleToChunkBox class
    seq:
      - id: first_chunk
        type: u4
        doc: |
          The index of the first chunk in this run of chunks that share the
          same samples-per-chunk and sample-description-index
      - id: samples_per_chunk
        type: u4
        doc: |
           The number of samples in each of these chunks
      - id: sample_description_index
        type: u4
        doc: |
           The index of the sample entry that describes the samples in this chunk.
           The index ranges from 1 to the number of sample entries in the Sample Description Box

  stsc_body:
    doc-ref: |
      ISO/IEC 14496-12:2005(E), section 8.18.2, SampleToChunkBox class
    seq:
      - id: version_flags
        type: full_box
      - id: entry_count
        type: u4
      - id: entries
        type: stsc_entry
        repeat: expr
        repeat-expr: entry_count
        doc: Table with chunks desciriprion

  stco_body:
    doc-ref: |
      ISO/IEC 14496-12:2005(E), section 8.19.2, ChunkOffsetBox class
    seq:
      - id: version_flags
        type: full_box
      - id: entry_count
        type: u4
      - id: entries
        type: u4
        repeat: expr
        repeat-expr: entry_count
        doc: Chunk offsets within the file

  co64_body:
    doc-ref: |
      ISO/IEC 14496-12:2005(E), section 8.19.2, ChunkLargeOffsetBox class
    seq:
      - id: version_flags
        type: full_box
      - id: entry_count
        type: u4
      - id: entries
        type: u8
        repeat: expr
        repeat-expr: entry_count
        doc: Chunk offsets in 64-bit form within the file
  
  stss_body:
    doc-ref: |
      ISO/IEC 14496-12:2005(E), section 8.20.2, SyncSampleBox class
    seq:
      - id: version_flags
        type: full_box
      - id: entry_count
        type: u4
      - id: sample_number
        type: u4
        repeat: expr
        repeat-expr: entry_count

  meta_body:
    doc-ref: |
      ISO/IEC 14496-12:2005(E), section 8.44.2, MetaBox class
    seq:
      - id: version_flags
        type: full_box
      - id: handler
        type: box
      - id: optional_boxes
        type: box
        repeat: eos
        doc: |
          Optional boxes that cary meta data

  elst_entry:
    doc-ref: |
      ISO/IEC 14496-12:2005(E), section 8.26.2, EditListBox class
    seq:
      - id: segment_duration_v1
        type: u8
        if: _parent.version_flags.version == 1
      - id: media_time_v1
        type: s8
        if: _parent.version_flags.version == 1
      - id: segment_duration_v0
        type: u4
        if: _parent.version_flags.version == 0
      - id: media_time_v0
        type: s4
        if: _parent.version_flags.version == 0
      - id: media_rate
        type: fixed_s2_s2
          
  elst_body:
    doc-ref: |
      ISO/IEC 14496-12:2005(E), section 8.26.2, EditListBox class
    seq:
      - id: version_flags
        type: full_box
      - id: entry_count
        type: u4
      - id: entries
        type: elst_entry
        repeat: expr
        repeat-expr: entry_count

  roll_entry:
    doc-ref: |
      ISO/IEC 14496-12:2005(E), section 8.40.4.2, VisualRollRecoveryEntry and AudioRollRecoveryEntry classes
    seq:
      - id: roll_distance
        type: s2
  
  sgpd_body:
    doc-ref: |
      ISO/IEC 14496-12:2005(E), section 8.40.3.3.2,  SampleGroupDescriptionBox class
    seq:
      - id: version_flags
        type: full_box
      - id: grouping_type
        type: u4
        enum: grouping_type
        doc: |
          The type of grouping used for the entries listed in the following table
      - id: entry_count
        type: u4
      - id: roll_entries
        type: roll_entry
        repeat: expr
        repeat-expr: entry_count
        if: grouping_type == grouping_type::roll

  sbgp_entry:
    doc-ref: |
      ISO/IEC 14496-12:2005(E), section 8.40.3.2.2, SampleToGroupBox class
    seq:
      - id: sample_count
        type: u4
        doc: |
          The number of consecutive samples with the same sample group
          descriptor
      - id: group_description_index
        type: u4
        doc: |
          The index of the sample group entry which
          describes the samples in this group
  
  sbgp_body:
    doc-ref: |
      ISO/IEC 14496-12:2005(E), section 8.40.3.2.2, SampleToGroupBox class
    seq:
      - id: version_flags
        type: full_box
      - id: grouping_type
        type: u4
        enum: grouping_type
        doc: |
          The type of grouping used for the entries listed in the following table
      - id: entry_count
        type: u4
      - id: entries
        type: sbgp_entry
        repeat: expr
        repeat-expr: entry_count
        if: grouping_type == grouping_type::roll
  
  ilst_body:
    doc-ref: |
      http://atomicparsley.sourceforge.net/mpeg-4files.html "Known iTunes Metadata Atoms"
    seq:
      - id: entry
        type: box
        repeat: eos
        doc: List of known iTunes related boxes. They are not a part of MP4 standard

  ctoo_body:
    doc-ref: |
      http://atomicparsley.sourceforge.net/mpeg-4files.html "Known iTunes Metadata Atoms"
    seq:
      - id: entry
        type: box
        repeat: eos
        doc: |
          Specifies the encoder used to generate whole file
          Actual information is carried in the child DATA box.
          THIS BOX IS NOT THE PART OF MP4 STANDARD
        
  cnam_body:
    doc-ref: |
      http://atomicparsley.sourceforge.net/mpeg-4files.html "Known iTunes Metadata Atoms"
    seq:
      - id: entry
        type: box
        repeat: eos
        doc: |
          Specifies the title
          Actual information is carried in the child DATA box.
          THIS BOX IS NOT THE PART OF MP4 STANDARD

  cart_body:
    doc-ref: |
      http://atomicparsley.sourceforge.net/mpeg-4files.html "Known iTunes Metadata Atoms"
    seq:
      - id: entry
        type: box
        repeat: eos
        doc: |
          Specifies artist name
          Actual information is carried in the child DATA box.
          THIS BOX IS NOT THE PART OF MP4 STANDARD

  cday_body:
    doc-ref: |
      http://atomicparsley.sourceforge.net/mpeg-4files.html "Known iTunes Metadata Atoms"
    seq:
      - id: entry
        type: box
        repeat: eos
        doc: |
          Specifies year
          Actual information is carried in the child DATA box.
          THIS BOX IS NOT THE PART OF MP4 STANDARD

  cgen_body:
    doc-ref: |
      http://atomicparsley.sourceforge.net/mpeg-4files.html "Known iTunes Metadata Atoms"
    seq:
      - id: entry
        type: box
        repeat: eos
        doc: |
          Specifies genre
          Actual information is carried in the child DATA box.
          THIS BOX IS NOT THE PART OF MP4 STANDARD

  data_body:
    doc-ref: |
      http://atomicparsley.sourceforge.net/mpeg-4files.html "Known iTunes Metadata Atoms"
    seq:
      - id: unknown
        size: 8
        doc: |
          Have no idea what this field is for. Version number?
      - id: data
        type: str
        encoding: UTF-8
        size: _io.size - 8
        doc: |
          The box carrying data for the iTunes related boxes.
          THIS BOX IS NOT THE PART OF MP4 STANDARD
        
enums:
  box_type:
    0x61766331: avc1
    0x58747261: xtra
    0x636f3634: co64
    0x64696e66: dinf
    0x64726566: dref
    0x65647473: edts
    0x656c7374: elst
    0x65736473: esds
    0x66726565: free
    0x66747970: ftyp
    0x68646c72: hdlr
    0x686d6864: hmhd
    0x696f6473: iods
    0x6d646174: mdat
    0x6d646864: mdhd
    0x6d646961: mdia
    0x6d657461: meta
    0x6d696e66: minf
    0x6d6f6f66: moof
    0x6d6f6f76: moov
    0x6d703461: mp4a
    0x6d766864: mvhd
    0x6e6d6864: nmhd
    0x73626770: sbgp
    0x73677064: sgpd
    0x736d6864: smhd
    0x7374626c: stbl
    0x7374636f: stco
    0x73747363: stsc
    0x73747364: stsd
    0x73747373: stss
    0x7374737a: stsz
    0x73747473: stts
    0x746b6864: tkhd
    0x74726166: traf
    0x7472616b: trak
    0x74726566: tref
    0x75647461: udta
    0x75726c20: url
    0x75726e20: urn
    0x766d6864: vmhd
  # boxes that are part of MP4 standard for AV1 codec
    0x61763031: av01
    0x61763143: av1c
  # boxes that are part of MP4 standard for VP9 codec
    0x76703039: vp09
    0x76706343: vpcc
  # boxes that are part of QuickTime specification
    0x6669656c: fiel
  # proprietary boxes that are not part of MP4 ISO/IEC 14496-12:2005(E) standard
    0x64617461: data
    0xa9415254: cart
    0xa9646179: cday
    0xa96e616d: cnam
    0xa967656e: cgen
    0xa9746f6f: ctoo
    0x696c7374: ilst
    0x70617370: pasp

  # http://www.mp4ra.org/filetype.html
  brand:
    0x33673261: x_3g2a
    0x33676536: x_3ge6
    0x33676539: x_3ge9
    0x33676639: x_3gf9
    0x33676736: x_3gg6
    0x33676739: x_3gg9
    0x33676839: x_3gh9
    0x33676d39: x_3gm9
    0x33677034: x_3gp4
    0x33677035: x_3gp5
    0x33677036: x_3gp6
    0x33677037: x_3gp7
    0x33677038: x_3gp8
    0x33677039: x_3gp9
    0x33677236: x_3gr6
    0x33677239: x_3gr9
    0x33677336: x_3gs6
    0x33677339: x_3gs9
    0x33677439: x_3gt9
    0x41525249: arri
    0x61766331: avc1
    0x61763031: av01
    0x6262786d: bbxm
    0x43414550: caep
    0x63617176: caqv
    0x63636666: ccff
    0x43446573: cdes
    0x64613061: da0a
    0x64613062: da0b
    0x64613161: da1a
    0x64613162: da1b
    0x64613261: da2a
    0x64613262: da2b
    0x64613361: da3a
    0x64613362: da3b
    0x64617368: dash
    0x64627931: dby1
    0x646d6231: dmb1
    0x64736d73: dsms
    0x64763161: dv1a
    0x64763162: dv1b
    0x64763261: dv2a
    0x64763262: dv2b
    0x64763361: dv3a
    0x64763362: dv3b
    0x64767231: dvr1
    0x64767431: dvt1
    0x64786f20: dxo
    0x656d7367: emsg
    0x6966726d: ifrm
    0x69736332: isc2
    0x69736f32: iso2
    0x69736f33: iso3
    0x69736f34: iso4
    0x69736f35: iso5
    0x69736f36: iso6
    0x69736f6d: isom
    0x4a325030: j2p0
    0x4a325031: j2p1
    0x6a703220: jp2
    0x6a706d20: jpm
    0x6a707369: jpsi
    0x6a707820: jpx
    0x6a707862: jpxb
    0x4c434147: lcag
    0x6c6d7367: lmsg
    0x4d344120: m4a
    0x4d344220: m4b
    0x4d345020: m4p
    0x4d345620: m4v
    0x4d46534d: mfsm
    0x4d475356: mgsv
    0x6d6a3273: mj2s
    0x6d6a7032: mjp2
    0x6d703231: mp21
    0x6d703431: mp41
    0x6d703432: mp42
    0x6d703731: mp71
    0x4d505049: mppi
    0x6d736468: msdh
    0x6d736978: msix
    0x4d534e56: msnv
    0x6e696b6f: niko
    0x6f646366: odcf
    0x6f706632: opf2
    0x6f707832: opx2
    0x70616e61: pana
    0x70696666: piff
    0x706e7669: pnvi
    0x71742020: qt
    0x72697378: risx
    0x524f5353: ross
    0x73647620: sdv
    0x53454155: seau
    0x5345424b: sebk
    0x73656e76: senv
    0x73696d73: sims
    0x73697378: sisx
    0x73737373: ssss
    0x75767675: uvvu
    0x58415643: xavc
  date_entry_type:
    0x75726c20: url

  grouping_type:
    0x726f6c6c: roll

  # the list of class tags specified in ISO/IEC 14496-1:2004(E) paragraph 7.2.2.1
  class_tag:
    0x00: forbidden
    0x01: objectdescrtag
    0x02: initialobjectdescrtag
    0x03: es_descrtag
    0x04: decoderconfigdescrtag
    0x05: decspecificinfotag
    0x06: slconfigdescrtag

  # the list of object types specified in ISO/IEC 14496-1:2004(E) paragraph 7.2.6.6.2 table 5
  object_type:
    0x00: forbidden
    0x01: systems_iso_iec_14496_1_a
    0x02: systems_iso_iec_14496_1_b
    0x03: interaction_stream
    0x04: systems_iso_iec_14496_1_extended_bifs_configuration_c
    0x05: systems_iso_iec_14496_1_afx_d
    0x06: font_data_stream
    0x07: synthesized_texture_stream
    0x08: streaming_text_stream
    0x20: visual_iso_iec_14496_2_e
    0x21: visual_itu_t_recommendation_h_264_or_iso_iec_14496_10_f
    0x22: parameter_sets_for_itu_t_recommendation_h_264_or_iso_iec_14496_10_f
    0x40: audio_iso_iec_14496_3_g
    0x60: visual_iso_iec_13818_2_simple_profile
    0x61: visual_iso_iec_13818_2_main_profile
    0x62: visual_iso_iec_13818_2_snr_profile
    0x63: visual_iso_iec_13818_2_spatial_profile
    0x64: visual_iso_iec_13818_2_high_profile
    0x65: visual_iso_iec_13818_2_422_profile
    0x66: audio_iso_iec_13818_7_main_profile
    0x67: audio_iso_iec_13818_7_lowcomplexity_profile
    0x68: audio_iso_iec_13818_7_scaleable_sampling_rate_profile
    0x69: audio_iso_iec_13818_3
    0x6A: visual_iso_iec_11172_2
    0x6B: audio_iso_iec_11172_3
    0x6C: visual_iso_iec_10918_1
    0xFF: no_object_type_specified     

  # the list of stream types specified in ISO/IEC 14496-1:2004(E) paragraph 7.2.6.6.2 table 6
  stream_type:
    0x00: forbidden
    0x01: objectdescriptorstream
    0x02: clockreferencestream
    0x03: scenedescriptionstream
    0x04: visualstream
    0x05: audiostream
    0x06: mpeg7stream
    0x07: ipmpstream
    0x08: objectcontentinfostream
    0x09: mpegjstream
    0x0A: interactionstream
    0x0B: ipmptoolstream

  sl_config_descriptor_predefined:
    0x00: custom
    0x01: null_sl_packet_header
    0x02: reserved_for_mp4

  field_ordering:
    0x00: only_one_field
    0x01: t_disp_earliest_t_stored_first
    0x06: b_disp_earliest_b_stored_first
    0x09: b_disp_earliest_t_stored_first
    0x0E: t_disp_earliest_b_stored_first
