meta:
  id: iso9660
  file-extension: iso
  endian: be
doc-ref: http://www.ecma-international.org/publications/files/ECMA-ST/Ecma-119.pdf
instances:
  sector_size:
    value: 0x800
    doc-ref: 6.1.2
  volume_descriptor_set:
    io: _root._io
    pos: _root.sector_size * 0x10
    type: volume_descriptor
    size: sector_size
    repeat: until
    repeat-until: _.descriptor_type == descriptor_type::volume_descriptor_set_terminator
types:
  volume_descriptor:
    doc-ref: 8.1
    seq:
      - id: descriptor_type
        type: u1
        enum: descriptor_type
        doc-ref: 8.1.1
      - id: magic
        contents: [0x43, 0x44, 0x30, 0x30, 0x31]
        doc-ref: 8.1.2
      - id: version
        contents: [0x01]
        doc-ref: 8.1.3
      - id: boot_record
        type: boot_record_volume
        if: descriptor_type == descriptor_type::boot_record_volume_descriptor
      - id: primary_volume
        type: primary_volume
        if: descriptor_type == descriptor_type::primary_volume_descriptor
      - id: supplementary_volume
        type: supplementary_volume
        if: descriptor_type == descriptor_type::supplementary_volume_descriptor
      - id: volume_partition
        type: volume_partition
        if: descriptor_type == descriptor_type::volume_partition_descriptor        
  boot_record_volume:
    doc-ref: 8.2
    seq:
      - id: boot_system_identifier
        type: strz
        size: 0x20
        encoding: ascii
        doc-ref: 8.2.4
      - id: boot_identifier
        type: strz
        size: 0x20
        encoding: ascii
        doc-ref: 8.2.5
  primary_volume:
    doc-ref: 8.4
    seq:
      - id: unused01
        contents: [ 0x0 ]
        doc-ref: 8.4.4
      - id: system_identifier
        type: str
        size: 0x20
        encoding: ascii
        doc-ref: 8.4.5
      - id: volume_identifier
        type: str
        size: 0x20
        encoding: ascii
        doc-ref: 8.4.6
      - id: unused02
        contents: [ 0x0, 0x0, 0x0, 0x0,  0x0, 0x0, 0x0, 0x0 ]
        doc-ref: 8.4.7
      - id: volume_space_size
        type: u4bi
        doc-ref: 8.4.8
      - id: unused03
        contents: [ 0x0, 0x0, 0x0, 0x0,  0x0, 0x0, 0x0, 0x0,  0x0, 0x0, 0x0, 0x0,  0x0, 0x0, 0x0, 0x0,  0x0, 0x0, 0x0, 0x0,  0x0, 0x0, 0x0, 0x0,  0x0, 0x0, 0x0, 0x0,  0x0, 0x0, 0x0, 0x0 ]
        doc-ref: 8.4.9
      - id: volume_set_size
        type: u2bi
        doc-ref: 8.4.10
      - id: volume_sequence_number
        type: u2bi
        doc-ref: 8.4.11
      - id: logical_block_size
        type: u2bi
        doc-ref: 8.4.12
      - id: path_table_size
        type: u4bi
        doc-ref: 8.4.13
      - id: loc_l_path_table
        type: u4le
        doc-ref: 8.4.14
      - id: loc_opt_l_path_table
        type: u4le
        doc-ref: 8.4.15
      - id: loc_m_path_table
        type: u4le
        doc-ref: 8.4.16
      - id: loc_opt_m_path_table
        type: u4le
        doc-ref: 8.4.17
      - id: directory_record_for_root_directory
        type: directory_record
        size: 0x22
        doc-ref: 8.4.18
      - id: volume_set_identifier
        type: str
        size: 0x80
        encoding: ascii
        doc-ref: 8.4.19
      - id: publisher_identifier
        type: str
        size: 0x80
        encoding: ascii
        doc-ref: 8.4.20
      - id: data_preparer_identifier
        type: str
        size: 0x80
        encoding: ascii
        doc-ref: 8.4.21
      - id: application_identifier
        type: str
        size: 0x80
        encoding: ascii
        doc-ref: 8.4.22
      - id: copyright_file_identifier
        type: str
        size: 0x25
        encoding: ascii
        doc-ref: 8.4.23
      - id: abstract_file_identifier
        type: str
        size: 0x25
        encoding: ascii
        doc-ref: 8.4.24
      - id: bibliographic_file_identifier
        type: str
        size: 0x25
        encoding: ascii
        doc-ref: 8.4.25
      - id: volume_creation_date_and_time
        type: datetime
        doc-ref: 8.4.26
      - id: volume_modification_date_and_time
        type: datetime
        doc-ref: 8.4.27
      - id: volume_expiration_date_and_time
        type: datetime
        doc-ref: 8.4.28
      - id: volume_effective_date_and_time
        type: datetime
        doc-ref: 8.4.29
      - id: file_structure_version
        type: s1
        doc-ref: 8.4.31
  supplementary_volume:
    seq:
      - id: volume_flags_reserved
        type: b7
        doc-ref: 8.5.3 b1-b7
      - id: volume_flags_not_iso2375
        type: b1
        doc-ref: 8.5.3 b0
      - id: system_identifier
        type: str
        size: 0x20
        encoding: ascii
        doc-ref: 8.5.4
      - id: volume_identifier
        type: str
        size: 0x20
        encoding: ascii
        doc-ref: 8.5.5
      - id: unused01
        size: 0x8
        doc-ref: none
      - id: volume_space_size
        type: u4bi
        doc-ref: none
      - id: escape_sequences
        size: 0x20
        doc-ref: 8.5.6
      - id: volume_set_size
        type: u2bi
        doc-ref: none
      - id: volume_sequence_number
        type: u2bi
        doc-ref: none
      - id: logical_block_size
        type: u2bi
        doc-ref: none
      - id: path_table_size
        type: u4bi
        doc-ref: 8.5.7
      - id: occurrence_of_type_l_path_table
        type: u4le
        doc-ref: 8.5.8
      - id: optional_occurrence_of_type_l_path_table
        type: u4le
        doc-ref: 8.5.9
      - id: occurrence_of_type_m_path_table
        type: u4le
        doc-ref: 8.5.10
      - id: optional_occurrence_of_type_m_path_table
        type: u4le
        doc-ref: 8.5.11
      - id: directory_record_for_root_directory
        type: directory_record
        size: 0x22
        doc-ref: 8.5.12
      - id: volume_set_identifier
        type: str
        size: 0x80
        encoding: ascii
        doc-ref: 8.5.13
      - id: publisher_identifier
        type: str
        size: 0x80
        encoding: ascii
        doc-ref: 8.5.14
      - id: data_preparer_identifier
        type: str
        size: 0x80
        encoding: ascii
        doc-ref: 8.5.15
      - id: application_identifier
        type: str
        size: 0x80
        encoding: ascii
        doc-ref: 8.5.16
      - id: copyright_file_identifier
        type: str
        size: 0x25
        encoding: ascii
        doc-ref: 8.5.17
      - id: abstract_file_identifier
        type: str
        size: 0x25
        encoding: ascii
        doc-ref: 8.5.18
      - id: bibliographic_file_identifier
        type: str
        size: 0x25
        encoding: ascii
        doc-ref: 8.5.19
      - id: volume_creation_date_and_time
        type: datetime
        doc-ref: none
      - id: volume_modification_date_and_time
        type: datetime
        doc-ref: none
      - id: volume_expiration_date_and_time
        type: datetime
        doc-ref: none
      - id: volume_effective_date_and_time
        type: datetime
        doc-ref: none
      - id: file_structure_version
        type: s1
        doc-ref: none
  volume_partition:
    seq:
      - id: todo
        type: u1
  u2bi:
    seq:
      - id: le
        type: u2le
      - id: be
        type: u2be
  u4bi:
    seq:
      - id: le
        type: u4le
      - id: be
        type: u4be
  datetime:
    doc-ref: 8.4.26.1
    seq:
      - id: year
        type: str
        size: 0x4
        encoding: ascii
      - id: month
        type: str
        size: 0x2
        encoding: ascii
      - id: day
        type: str
        size: 0x2
        encoding: ascii
      - id: hour
        type: str
        size: 0x2
        encoding: ascii
      - id: minute
        type: str
        size: 0x2
        encoding: ascii
      - id: second
        type: str
        size: 0x2
        encoding: ascii
      - id: hundredths_second
        type: str
        size: 0x2
        encoding: ascii
      - id: timezone_offset
        type: s1
  recdatetime:
    doc-ref: 9.1.5
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
  directory_record:
    doc-ref: 9.1
    seq:
      - id: len_dr
        type: u1
        doc-ref: 9.1.1
      - id: ext_attr_rec_len
        type: u1
        doc-ref: 9.1.2
      - id: location_of_extent
        type: u4bi
        doc-ref: 9.1.3
      - id: data_len
        type: u4bi
        doc-ref: 9.1.4
      - id: rec_date_time
        type: recdatetime
        doc-ref: 9.1.5
      - id: file_flags_multi_extent
        type: b1
        doc-ref: 9.1.6 b7
      - id: file_flags_reserved
        type: b2
        doc-ref: 9.1.6 b5+b6
      - id: file_flags_protection
        type: b1
        doc-ref: 9.1.6 b4
      - id: file_flags_record
        type: b1
        doc-ref: 9.1.6 b3
      - id: file_flags_associated_file
        type: b1
        doc-ref: 9.1.6 b2
      - id: file_flags_directory
        type: b1
        doc-ref: 9.1.6 b1        
      - id: file_flags_existence
        type: b1
        doc-ref: 9.1.6 b0
      - id: file_unit_size
        type: u1
        doc-ref: 9.1.7
      - id: interleave_gap_size
        type: u1
        doc-ref: 9.1.8
      - id: vol_seq_num
        type: u2bi
        doc-ref: 9.1.9
      - id: len_fi
        type: u1
        doc-ref: 9.1.10
      - id: file_id_file
        size: len_fi
        if: file_flags_directory == false
        doc-ref: 9.1.11
      - id: file_id_dir
        size: len_fi
        if: file_flags_directory == true
        doc-ref: 9.1.11        
      - id: padding_field
        size: 0x1
        if: ( len_dr > 0x22 ) and ( len_fi & 1 == 1 ) # only if odd number
        doc-ref: 9.1.12
      - id: system_use
        size: ( len_dr - 33 ) - len_fi # recheck this logic
        if: ( len_dr > 0x22 )
        doc-ref: 9.1.13
  path_table:
    seq:
      - id: len_di
        type: u1
      - id: ext_attr_rec_len
        type: u1
      - id: location_of_extent
        type: u4le
      - id: parent_directory_number
        type: u2le
      - id: directory_identifier
        size: 8 + len_di
      - id: padding_field
        size: 0x1
        # todo, if len_di is odd number...
        # todo, 9.5 extended attribute record if ext_attr_rec_len > 0
enums:
  descriptor_type:
    0x00: boot_record_volume_descriptor
    0x01: primary_volume_descriptor
    0x02: supplementary_volume_descriptor
    0x03: volume_partition_descriptor
    0xff: volume_descriptor_set_terminator

