meta:
  id: iso9660
  file-extension: iso
  endian: be
doc-ref: |
  ecma-119 http://www.ecma-international.org/publications/files/ECMA-ST/Ecma-119.pdf
enums:
  descriptor_type:
    0x00: boot_record_volume_descriptor
    0x01: primary_volume_descriptor
    0x02: supplementary_volume_descriptor
    0x03: volume_partition_descriptor
    0xff: volume_descriptor_set_terminator
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
    doc-ref: ecma-119 8.2
    seq:
      - id: boot_system_identifier
        doc-ref: ecma-119 8.2.4
        type: strz
        size: 0x20
        encoding: ascii
      - id: boot_identifier
        doc-ref: ecma-119 8.2.5
        type: strz
        size: 0x20
        encoding: ascii
  datetime:
    doc-ref: ecma-119 8.4.26.1
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
  primary_volume:
    doc-ref: ecma-119 8.4
    seq:
      - id: unused01
        doc-ref: ecma-119 8.4.4
        contents: [ 0x0 ]
      - id: system_identifier
        doc-ref: ecma-119 8.4.5
        type: str
        size: 0x20
        encoding: ascii
      - id: volume_identifier
        doc-ref: ecma-119 8.4.6
        type: str
        size: 0x20
        encoding: ascii
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
        type: directory_record
        size: 0x22
      - id: volume_set_identifier
        doc-ref: ecma-119 8.4.19
        type: str
        size: 0x80
        encoding: ascii
      - id: publisher_identifier
        doc-ref: ecma-119 8.4.20
        type: str
        size: 0x80
        encoding: ascii
      - id: data_preparer_identifier
        doc-ref: ecma-119 8.4.21
        type: str
        size: 0x80
        encoding: ascii
      - id: application_identifier
        doc-ref: ecma-119 8.4.22
        type: str
        size: 0x80
        encoding: ascii
      - id: copyright_file_identifier
        doc-ref: ecma-119 8.4.23
        type: str
        size: 0x25
        encoding: ascii
      - id: abstract_file_identifier
        doc-ref: ecma-119 8.4.24
        type: str
        size: 0x25
        encoding: ascii
      - id: bibliographic_file_identifier
        doc-ref: ecma-119 8.4.25
        type: str
        size: 0x25
        encoding: ascii
      - id: volume_creation_date_and_time
        doc-ref: ecma-119 8.4.26
        type: datetime
      - id: volume_modification_date_and_time
        doc-ref: ecma-119 8.4.27
        type: datetime
      - id: volume_expiration_date_and_time
        doc-ref: ecma-119 8.4.28
        type: datetime
      - id: volume_effective_date_and_time
        doc-ref: ecma-119 8.4.29
        type: datetime
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
        type: str
        size: 0x20
        encoding: ascii
      - id: volume_identifier
        doc-ref: ecma-119 8.5.5
        type: str
        size: 0x20
        encoding: ascii
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
        type: directory_record
        size: 0x22
      - id: volume_set_identifier
        doc-ref: ecma-119 8.5.13
        type: str
        size: 0x80
        encoding: ascii
      - id: publisher_identifier
        doc-ref: ecma-119 8.5.14
        type: str
        size: 0x80
        encoding: ascii
      - id: data_preparer_identifier
        doc-ref: ecma-119 8.5.15
        type: str
        size: 0x80
        encoding: ascii
      - id: application_identifier
        doc-ref: ecma-119 8.5.16
        type: str
        size: 0x80
        encoding: ascii
      - id: copyright_file_identifier
        doc-ref: ecma-119 8.5.17
        type: str
        size: 0x25
        encoding: ascii
      - id: abstract_file_identifier
        doc-ref: ecma-119 8.5.18
        type: str
        size: 0x25
        encoding: ascii
      - id: bibliographic_file_identifier
        doc-ref: ecma-119 8.5.19
        type: str
        size: 0x25
        encoding: ascii
      - id: volume_creation_date_and_time
        doc-ref: ecma-119 8.5
        type: datetime
      - id: volume_modification_date_and_time
        doc-ref: ecma-119 8.5
        type: datetime
      - id: volume_expiration_date_and_time
        doc-ref: ecma-119 8.5
        type: datetime
      - id: volume_effective_date_and_time
        doc-ref: ecma-119 8.5
        type: datetime
      - id: file_structure_version
        doc-ref: ecma-119 8.5
        type: s1
  volume_partition:
    seq:
      - id: todo
        type: u1
  recdatetime:
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
  directory_record:
    doc-ref: ecma-119 9.1
    seq:
      - id: len_dr
        doc-ref: ecma-119 9.1.1
        type: u1
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
        type: recdatetime
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
        size: len_fi
        if: file_flags_directory == false
      - id: file_id_dir
        doc-ref: ecma-119 9.1.11
        size: len_fi
        if: file_flags_directory == true
      - id: padding_field
        doc-ref: ecma-119 9.1.12
        size: 0x1
        if: ( len_dr > 0x22 ) and ( len_fi & 1 == 1 ) # only if odd number
      - id: system_use
        doc-ref: ecma-119 9.1.13
        size: ( len_dr - 33 ) - len_fi # recheck this logic
        if: ( len_dr > 0x22 )
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

