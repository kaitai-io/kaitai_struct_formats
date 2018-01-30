meta:
  id: iso9660
  file-extension: iso
  endian: be
doc-ref: http://www.ecma-international.org/publications/files/ECMA-ST/Ecma-119.pdf
instances:
  sector_size:
    value: 0x800
  volume_descriptor_set:
    io: _root._io
    pos: _root.sector_size * 0x10
    type: volume_descriptor
    size: sector_size
    repeat: until
    repeat-until: _.descriptor_type == descriptor_type::volume_descriptor_set_terminator
types:
  volume_descriptor:
    seq:
      - id: descriptor_type
        type: u1
        enum: descriptor_type
      - id: magic
        contents: [0x43, 0x44, 0x30, 0x30, 0x31]
      - id: version
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
    seq:
      - id: boot_system_identifier
        type: strz
        size: 0x20
        encoding: ascii
      - id: boot_identifier
        type: strz
        size: 0x20
        encoding: ascii
  primary_volume:
    seq:
      - id: unused01
        size: 0x1
      - id: system_identifier
        type: str
        size: 0x20
        encoding: ascii
      - id: volume_identifier
        type: str
        size: 0x20
        encoding: ascii
      - id: unused02
        size: 0x8
      - id: volume_space_size
        type: u4bi
      - id: unused03
        size: 0x20
      - id: volume_set_size
        type: u2bi
      - id: volume_sequence_number
        type: u2bi
      - id: logical_block_size
        type: u2bi
      - id: path_table_size
        type: u4bi
      - id: occurrence_of_type_l_path_table
        type: u4le
      - id: optional_occurrence_of_type_l_path_table
        type: u4le
      - id: occurrence_of_type_m_path_table
        type: u4le
      - id: optional_occurrence_of_type_m_path_table
        type: u4le
      - id: directory_record_for_root_directory
        size: 0x22
      - id: volume_set_identifier
        type: str
        size: 0x80
        encoding: ascii
      - id: publisher_identifier
        type: str
        size: 0x80
        encoding: ascii
      - id: data_preparer_identifier
        type: str
        size: 0x80
        encoding: ascii
      - id: application_identifier
        type: str
        size: 0x80
        encoding: ascii
      - id: copyright_file_identifier
        type: str
        size: 0x25
        encoding: ascii
      - id: abstract_file_identifier
        type: str
        size: 0x25
        encoding: ascii
      - id: bibliographic_file_identifier
        type: str
        size: 0x25
        encoding: ascii
      - id: volume_creation_date_and_time
        type: datetime
      - id: volume_modification_date_and_time
        type: datetime
      - id: volume_expiration_date_and_time
        type: datetime
      - id: volume_effective_date_and_time
        type: datetime
      - id: file_structure_version
        type: s1
    instances:
      path_tables:
        io: _root._io
        pos: occurrence_of_type_l_path_table * logical_block_size.le
        type: path_table
#        size: path_table_size.le
#        repeat: expr
#        repeat-expr: path_table_size.le
  supplementary_volume:
    seq:
      - id: volume_flags
        size: 0x1
      - id: system_identifier
        type: str
        size: 0x20
        encoding: ascii
      - id: volume_identifier
        type: str
        size: 0x20
        encoding: ascii
      - id: unused01
        size: 0x8
      - id: volume_space_size
        type: u4bi
      - id: escape_sequences
        size: 0x20
      - id: volume_set_size
        type: u2bi
      - id: volume_sequence_number
        type: u2bi
      - id: logical_block_size
        type: u2bi
      - id: path_table_size
        type: u4bi
      - id: occurrence_of_type_l_path_table
        type: u4le
      - id: optional_occurrence_of_type_l_path_table
        type: u4le
      - id: occurrence_of_type_m_path_table
        type: u4le
      - id: optional_occurrence_of_type_m_path_table
        type: u4le
      - id: directory_record_for_root_directory
        size: 0x22
      - id: volume_set_identifier
        type: str
        size: 0x80
        encoding: ascii
      - id: publisher_identifier
        type: str
        size: 0x80
        encoding: ascii
      - id: data_preparer_identifier
        type: str
        size: 0x80
        encoding: ascii
      - id: application_identifier
        type: str
        size: 0x80
        encoding: ascii
      - id: copyright_file_identifier
        type: str
        size: 0x25
        encoding: ascii
      - id: abstract_file_identifier
        type: str
        size: 0x25
        encoding: ascii
      - id: bibliographic_file_identifier
        type: str
        size: 0x25
        encoding: ascii
      - id: volume_creation_date_and_time
        type: datetime
      - id: volume_modification_date_and_time
        type: datetime
      - id: volume_expiration_date_and_time
        type: datetime
      - id: volume_effective_date_and_time
        type: datetime
      - id: file_structure_version
        type: s1
    instances:
      path_tables:
        io: _root._io
        pos: occurrence_of_type_l_path_table * logical_block_size.le
        type: path_table
        repeat: expr
        repeat-expr: path_table_size.le
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

