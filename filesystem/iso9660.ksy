meta:
  id: iso9660
  title: ISO9660 CD filesystem
  file-extension: iso
  xref:
    wikidata: Q815645
  license: CC0-1.0
  endian: be
  encoding: ASCII
doc: |
  ISO9660 is standard filesystem used on read-only optical discs
  (mostly CD-ROM). The standard was based on earlier High Sierra
  Format (HSF), proposed for CD-ROMs in 1985, and, after several
  revisions, it was accepted as ISO9960:1998.
  The format emphasizes portability (thus having pretty minimal
  features and very conservative file names standards) and sequential
  access (which favors disc devices with relatively slow rotation
  speed).
doc-ref: |
  ecma-119 http://www.ecma-international.org/publications/files/ECMA-ST/Ecma-119.pdf
  susp http://www.ymi.com/ymi/sites/default/files/pdf/Systems%20Use%20P1281.pdf
  rrip http://www.ymi.com/ymi/sites/default/files/pdf/Rockridge.pdf
  rras http://www.estamos.de/makecd/Rock_Ridge_Amiga_Specific
  rrzf https://dev.lovelyhq.com/libburnia/web/wikis/Zisofs
enums:
  descriptor_type:
    0x00: boot_record_volume_descriptor
    0x01: primary_volume_descriptor
    0x02: supplementary_volume_descriptor
    0x03: volume_partition_descriptor
    0xff: volume_descriptor_set_terminator
  su_signature:
    0x4153: rras_amiga_specific # AS
    0x4345: susp_continuation_area # CE
    0x434c: rrip_child_link # CL
    0x4552: susp_extensions_reference # ER
    0x4553: susp_extension_selector # ES
    0x4e4d: rrip_alternate_name # NM
    0x5044: susp_padding_field # PD
    0x504c: rrip_parent_link # PL
    0x504e: rrip_posix_device_number # PN
    0x5058: rrip_posix_file_attributes # PX
    0x5245: rrip_relocated_directory # RE
    0x5252: rrip_extensions_in_use_indicator # RR
    0x5346: rrip_sparse_file # SF
    0x534c: rrip_symbolic_link # SL
    0x5350: susp_indicator # SP
    0x5354: susp_terminator # ST
    0x5446: rrip_time_file # TF
    0x5a46: rrzf_zisofs # ZF
types:
  u2bi:
    doc-ref: ecma-119 7.2.3
    seq:
      - id: le
        type: u2le
      - id: be
        type: u2be
  u4bi:
    doc-ref: ecma-119 7.3.3
    seq:
      - id: le
        type: u4le
      - id: be
        type: u4be
  volume_descriptor:
    doc-ref: ecma-119 8.1
    seq:
      - id: descriptor_type
        doc-ref: ecma-119 8.1.1
        type: u1
        enum: descriptor_type
      - id: magic
        doc-ref: ecma-119 8.1.2
        contents: [0x43, 0x44, 0x30, 0x30, 0x31]
      - id: version
        doc-ref: ecma-119 8.1.3
        contents: [0x01]
      - id: volume
        type:
          switch-on: descriptor_type
          cases:
            'descriptor_type::boot_record_volume_descriptor': boot_record_volume
            'descriptor_type::primary_volume_descriptor': primary_volume
            'descriptor_type::supplementary_volume_descriptor': supplementary_volume
#            'descriptor_type::volume_partition_descriptor': volume_partition
  boot_record_volume:
    doc-ref: ecma-119 8.2
    seq:
      - id: boot_system_identifier
        doc-ref: ecma-119 8.2.4
        type: strz
        size: 0x20
      - id: boot_identifier
        doc-ref: ecma-119 8.2.5
        type: strz
        size: 0x20
  datetime_long:
    doc-ref: ecma-119 8.4.26.1
    seq:
      - id: year
        type: str
        size: 0x4
      - id: month
        type: str
        size: 0x2
      - id: day
        type: str
        size: 0x2
      - id: hour
        type: str
        size: 0x2
      - id: minute
        type: str
        size: 0x2
      - id: second
        type: str
        size: 0x2
      - id: hundredths_second
        type: str
        size: 0x2
      - id: timezone_offset
        type: s1
  volume_text_32: # 0x20
    seq:
      - id: text
        type: str
        size: 0x20
  volume_text_37: # 0x25
    seq:
      - id: text
        type: str
        size: 0x25
  volume_text_128: # 0x80
    seq:
      - id: text
        type: str
        size: 0x80
  primary_volume:
    doc-ref: ecma-119 8.4
    seq:
      - id: unused01
        doc-ref: ecma-119 8.4.4
        contents: [ 0x0 ]
      - id: system_identifier
        doc-ref: ecma-119 8.4.5
        type: volume_text_32
      - id: volume_identifier
        doc-ref: ecma-119 8.4.6
        type: volume_text_32
      - id: unused02
        doc-ref: ecma-119 8.4.7
        contents: [ 0x0, 0x0, 0x0, 0x0,  0x0, 0x0, 0x0, 0x0 ]
      - id: volume_space_size
        doc-ref: ecma-119 8.4.8
        type: u4bi
      - id: unused03
        doc-ref: ecma-119 8.4.9
        contents: [ 0x0, 0x0, 0x0, 0x0,  0x0, 0x0, 0x0, 0x0,  0x0, 0x0, 0x0, 0x0,  0x0, 0x0, 0x0, 0x0,  0x0, 0x0, 0x0, 0x0,  0x0, 0x0, 0x0, 0x0,  0x0, 0x0, 0x0, 0x0,  0x0, 0x0, 0x0, 0x0 ]
      - id: volume_set_size
        doc-ref: ecma-119 8.4.10
        type: u2bi
      - id: volume_sequence_number
        doc-ref: ecma-119 8.4.11
        type: u2bi
      - id: logical_block_size
        doc-ref: ecma-119 8.4.12
        type: u2bi
      - id: path_table_size
        doc-ref: ecma-119 8.4.13
        type: u4bi
      - id: loc_l_path_table
        doc-ref: ecma-119 8.4.14
        type: u4le
      - id: loc_opt_l_path_table
        doc-ref: ecma-119 8.4.15
        type: u4le
      - id: loc_m_path_table
        doc-ref: ecma-119 8.4.16
        type: u4le
      - id: loc_opt_m_path_table
        doc-ref: ecma-119 8.4.17
        type: u4le
      - id: directory_record_for_root_directory
        doc-ref: ecma-119 8.4.18
        doc: |
          The root directory_record_head and directory_record_body is 34 bytes.
          In other cases the size is variable.
        type: directory_record_head
        size: 0x22
      - id: volume_set_identifier
        doc-ref: ecma-119 8.4.19
        type: volume_text_128
      - id: publisher_identifier
        doc-ref: ecma-119 8.4.20
        type: volume_text_128
      - id: data_preparer_identifier
        doc-ref: ecma-119 8.4.21
        type: volume_text_128
      - id: application_identifier
        doc-ref: ecma-119 8.4.22
        type: volume_text_128
      - id: copyright_file_identifier
        doc-ref: ecma-119 8.4.23
        type: volume_text_37
      - id: abstract_file_identifier
        doc-ref: ecma-119 8.4.24
        type: volume_text_37
      - id: bibliographic_file_identifier
        doc-ref: ecma-119 8.4.25
        type: volume_text_37
      - id: volume_creation_date_and_time
        doc-ref: ecma-119 8.4.26
        type: datetime_long
      - id: volume_modification_date_and_time
        doc-ref: ecma-119 8.4.27
        type: datetime_long
      - id: volume_expiration_date_and_time
        doc-ref: ecma-119 8.4.28
        type: datetime_long
      - id: volume_effective_date_and_time
        doc-ref: ecma-119 8.4.29
        type: datetime_long
      - id: file_structure_version
        doc-ref: ecma-119 8.4.31
        type: s1
  supplementary_volume:
    doc-ref: ecma-119 8.5
    seq:
      - id: volume_flags_reserved
        doc-ref: ecma-119 8.5.3 b1-b7
        type: b7
      - id: volume_flags_not_iso2375
        doc-ref: ecma-119 8.5.3 b0
        type: b1
      - id: system_identifier
        doc-ref: ecma-119 8.5.4
        type: volume_text_32
      - id: volume_identifier
        doc-ref: ecma-119 8.5.5
        type: volume_text_32
      - id: unused01
        doc-ref: ecma-119 8.5
        size: 0x8
      - id: volume_space_size
        doc-ref: ecma-119 8.5
        type: u4bi
      - id: escape_sequences
        doc-ref: ecma-119 8.5.6
        size: 0x20
      - id: volume_set_size
        doc-ref: ecma-119 8.5
        type: u2bi
      - id: volume_sequence_number
        doc-ref: ecma-119 8.5
        type: u2bi
      - id: logical_block_size
        doc-ref: ecma-119 8.5
        type: u2bi
      - id: path_table_size
        doc-ref: ecma-119 8.5.7
        type: u4bi
      - id: occurrence_of_type_l_path_table
        doc-ref: ecma-119 8.5.8
        type: u4le
      - id: optional_occurrence_of_type_l_path_table
        doc-ref: ecma-119 8.5.9
        type: u4le
      - id: occurrence_of_type_m_path_table
        doc-ref: ecma-119 8.5.10
        type: u4le
      - id: optional_occurrence_of_type_m_path_table
        doc-ref: ecma-119 8.5.11
        type: u4le
      - id: directory_record_for_root_directory
        doc-ref: ecma-119 8.5.12
        doc: |
          The root directory_record_head and directory_record_body is 34 bytes.
          In other cases the size is variable.
        type: directory_record_head
        size: 0x22
      - id: volume_set_identifier
        doc-ref: ecma-119 8.5.13
        type: volume_text_128
      - id: publisher_identifier
        doc-ref: ecma-119 8.5.14
        type: volume_text_128
      - id: data_preparer_identifier
        doc-ref: ecma-119 8.5.15
        type: volume_text_128
      - id: application_identifier
        doc-ref: ecma-119 8.5.16
        type: volume_text_128
      - id: copyright_file_identifier
        doc-ref: ecma-119 8.5.17
        type: volume_text_37
      - id: abstract_file_identifier
        doc-ref: ecma-119 8.5.18
        type: volume_text_37
      - id: bibliographic_file_identifier
        doc-ref: ecma-119 8.5.19
        type: volume_text_37
      - id: volume_creation_date_and_time
        doc-ref: ecma-119 8.5
        type: datetime_long
      - id: volume_modification_date_and_time
        doc-ref: ecma-119 8.5
        type: datetime_long
      - id: volume_expiration_date_and_time
        doc-ref: ecma-119 8.5
        type: datetime_long
      - id: volume_effective_date_and_time
        doc-ref: ecma-119 8.5
        type: datetime_long
      - id: file_structure_version
        doc-ref: ecma-119 8.5
        type: s1
#  volume_partition:
#    seq:
#      - id: todo
#        type: u1
  datetime_short:
    doc-ref: ecma-119 9.1.5
    seq:
      - id: year
        type: u1
      - id: month
        type: u1
      - id: day
        type: u1
      - id: hour
        type: u1
      - id: min
        type: u1
      - id: sec
        type: u1
      - id: offset
        type: s1
  susp_ce:
    doc-ref: susp 5.1
    seq:
      - id: length
        type: u1
      - id: version
        contents: [ 0x1 ]
      - id: ca_location
        type: u4bi
      - id: ca_offset
        type: u4bi
      - id: ca_length
        type: u4bi
  rrip_cl:
    doc-ref: rrip 4.1.5.1
    seq:
      - id: length
        type: u1
      - id: version
        contents: [ 0x1 ]
      - id: lba_child
        type: u4bi
  susp_er:
    doc-ref: susp 5.5
    seq:
      - id: length
        type: u1
      - id: version
        contents: [ 0x1 ]
      - id: len_id
        type: u1
      - id: len_des
        type: u1
      - id: len_src
        type: u1
      - id: ext_ver
        type: u1
      - id: ext_id
        size: len_id
      - id: ext_des
        size: len_des
      - id: ext_src
        size: len_src
  susp_es:
    doc-ref: susp 5.6
    seq:
      - id: length
        type: u1
      - id: version
        contents: [ 0x1 ]
      - id: ext_seq
        type: u1
  rrip_nm:
    doc-ref: rrip 4.1.4
    seq:
      - id: length
        type: u1
      - id: version
        contents: [ 0x1 ]
      - id: reserved
        type: b5
      - id: parent
        doc: |
          Grouped all 4x reserved into a single reserved
        type: b1
      - id: current
        type: b1
      - id: continue
        type: b1
      - id: name
        type: str
        size: length - 5
  susp_pd:
    doc-ref: susp 5.2
    seq:
      - id: length
        type: u1
      - id: version
        contents: [ 0x1 ]
      - id: padding_area
        size: length - 4
  rrip_px:
    doc-ref: rrip 4.1.1
    seq:
      - id: length
        type: u1
      - id: version
        contents: [ 0x1 ]
      - id: file_mode
        type: u4bi
      - id: links
        type: u4bi
      - id: user
        type: u4bi
      - id: group
        type: u4bi
      - id: serial
        type: u4bi
        if: length >= 44
  susp_sp:
    doc-ref: susp 5.3
    seq:
      - id: length
        type: u1
      - id: version
        contents: [ 0x1 ]
      - id: check_bytes
        contents: [ 0xbe, 0xef ]
      - id: len_skp
        size: length - 6
  susp_st:
    doc-ref: susp 5.4
    seq:
      - id: length
        type: u1
      - id: version
        contents: [ 0x1 ]
  rrip_tf_short:
    doc-ref: rrip 4.6.1
    doc: |
      The data is available in this specific order.
      Multiple dates can be set.
    seq:
      - id: creation
        type: datetime_short
        if: _parent.creation
      - id: modify
        type: datetime_short
        if: _parent.modify
      - id: access
        type: datetime_short
        if: _parent.access
      - id: attributes
        type: datetime_short
        if: _parent.attributes
      - id: backup
        type: datetime_short
        if: _parent.backup
      - id: expiration
        type: datetime_short
        if: _parent.expiration
      - id: effective
        type: datetime_short
        if: _parent.effective
  rrip_tf_long:
    doc-ref: rrip 4.6.1
    doc: |
      The data is available in this specific order.
      Multiple dates can be set.
    seq:
      - id: creation
        type: datetime_long
        if: _parent.creation
      - id: modify
        type: datetime_long
        if: _parent.modify
      - id: access
        type: datetime_long
        if: _parent.access
      - id: attributes
        type: datetime_long
        if: _parent.attributes
      - id: backup
        type: datetime_long
        if: _parent.backup
      - id: expiration
        type: datetime_long
        if: _parent.expiration
      - id: effective
        type: datetime_long
        if: _parent.effective
  rrip_tf:
    doc-ref: rrip 4.6.1
    seq:
      - id: length
        type: u1
      - id: version
        contents: [ 0x1 ]
      - id: long_form
        type: b1
      - id: effective
        type: b1
      - id: expiration
        type: b1
      - id: backup
        type: b1
      - id: attributes
        type: b1
      - id: access
        type: b1
      - id: modify
        type: b1
      - id: creation
        type: b1
      - id: datetime_short
        type: rrip_tf_short
        if: not long_form
      - id: datetime_long
        type: rrip_tf_long
        if: long_form
  susp_unknown: # default for now
    seq:
      - id: length
        type: u1
      - id: version
        type: u1
      - id: data
        size: length - 4
  su_header:
    seq:
      - id: signature
        type: u2be
        enum: su_signature
      - id: su_specific
        type:
          switch-on: signature
          cases:
            'su_signature::rras_amiga_specific': susp_unknown # AS
            'su_signature::susp_continuation_area': susp_ce # CE
            'su_signature::rrip_child_link': rrip_cl # CL
            'su_signature::susp_extensions_reference': susp_er # ER
            'su_signature::susp_extension_selector': susp_es # ES
            'su_signature::rrip_alternate_name': rrip_nm # NM
            'su_signature::susp_padding_field': susp_pd # PD
            'su_signature::rrip_parent_link': susp_unknown # PL
            'su_signature::rrip_posix_device_number': susp_unknown # PN
            'su_signature::rrip_posix_file_attributes': rrip_px # PX
            'su_signature::rrip_relocated_directory': susp_unknown # RE
            'su_signature::rrip_extensions_in_use_indicator': susp_unknown # RR
            'su_signature::rrip_sparse_file': susp_unknown # SF
            'su_signature::rrip_symbolic_link': susp_unknown # SL
            'su_signature::susp_indicator': susp_sp # SP
            'su_signature::susp_terminator': susp_st # ST
            'su_signature::rrip_time_file': rrip_tf # TF
            'su_signature::rrzf_zisofs': susp_unknown # ZF
  su_headers:
    doc: |
      We check if we have at least 2 bytes left.
      The SUSP magic is 2 bytes.
    seq:
      - id: header
        type: su_header
        if: _io.size - _io.pos >= 2
        repeat: eos
  directory_records:
    doc: |
      First item "." it points to it self
      Second item ".." it points to the parent, or also to self if it the root
    seq:
      - id: directory_record
        type: directory_record_head
        repeat: until
        repeat-until: _.len_dr == 0
  directory_record_head:
    doc-ref: ecma-119 9.1
    seq:
      - id: len_dr
        doc-ref: ecma-119 9.1.1
        doc: |
          If len_dr == 0 we do not process the body
          If len_dr >= 1 we include field len_dr in the size
        type: u1
      - id: body
        type: directory_record_body
        if: len_dr > 0x0
  directory_record_body:
    seq:
      - id: ext_attr_rec_len
        doc-ref: ecma-119 9.1.2
        type: u1
      - id: location_of_extent
        doc-ref: ecma-119 9.1.3
        type: u4bi
      - id: data_len
        doc-ref: ecma-119 9.1.4
        type: u4bi
      - id: rec_date_time
        doc-ref: ecma-119 9.1.5
        type: datetime_short
      - id: file_flags_multi_extent
        doc-ref: ecma-119 9.1.6 b7
        type: b1
      - id: file_flags_reserved
        doc-ref: ecma-119 9.1.6 b5+b6
        type: b2
      - id: file_flags_protection
        doc-ref: ecma-119 9.1.6 b4
        type: b1
      - id: file_flags_record
        doc-ref: ecma-119 9.1.6 b3
        type: b1
      - id: file_flags_associated_file
        doc-ref: ecma-119 9.1.6 b2
        type: b1
      - id: file_flags_directory
        doc-ref: ecma-119 9.1.6 b1
        type: b1
      - id: file_flags_existence
        doc-ref: ecma-119 9.1.6 b0
        type: b1
      - id: file_unit_size
        doc-ref: ecma-119 9.1.7
        type: u1
      - id: interleave_gap_size
        doc-ref: ecma-119 9.1.8
        type: u1
      - id: vol_seq_num
        doc-ref: ecma-119 9.1.9
        type: u2bi
      - id: len_fi
        doc-ref: ecma-119 9.1.10
        type: u1
      - id: file_id_file
        doc-ref: ecma-119 9.1.11
        type: str
        size: len_fi
        if: not file_flags_directory
      - id: file_id_dir
        doc-ref: ecma-119 9.1.11
        size: len_fi
        type: str
        if: file_flags_directory
      - id: padding_field
        doc-ref: ecma-119 9.1.12
        doc: |
          Padding field is added when len_fi contains an even number
        size: 0x1
        if: len_fi % 2 == 0
      - id: system_use
        doc-ref: ecma-119 9.1.13
        doc: |
          The size of the system_use is defined as:
          ( len_dr - size of directory_record = 33 bytes ) - len_fi
        type: su_headers
        size: ( _parent.len_dr - 33 ) - len_fi
    instances:
      directory_records:
        io: _root._io
        pos: _root.sector_size * location_of_extent.le
        size: data_len.le
        type: directory_records
        if: ( _parent.len_dr > 0x0 ) and file_flags_directory
      file_content:
        io: _root._io
        pos: _root.sector_size * location_of_extent.le
        size: data_len.le
        if: ( _parent.len_dr > 0x0 ) and not file_flags_directory
instances:
  sector_size:
    doc-ref: ecma-119 6.1.2
    value: 0x800
  volume_descriptor_set:
    io: _root._io
    pos: _root.sector_size * 0x10
    type: volume_descriptor
    size: sector_size
    repeat: until
    repeat-until: _.descriptor_type == descriptor_type::volume_descriptor_set_terminator

