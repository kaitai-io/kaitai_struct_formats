meta:
  id: 'stfs'
  title: 'Secure Transacted Filesystem'
  application: 'Microsoft Xbox 360'
  license: 'CC0-1.0'
  endian: be
  encoding: UTF-8
seq:
  - id: header
    type: x_content_header
  - id: licenses
    type: x_content_license
    size: 0x10
    repeat: expr
    repeat-expr: 0x10
  - id: metadata_hash
    size: 0x14
  - id: metadata_size
    type: u4
  - id: metadata
    type: x_content_metadata
  # Hash Tables
instances:
  actual_meta_size:
    value: 'metadata._io.size'
  is_metadata_size_valid:
    value: 'metadata_size == actual_meta_size'
types:
  # \ Uncommon Data Types
  u3: # Unsigned int24
    seq:
      - id: value
        type: b24
    doc: 'Unsigned 24-bit integer'
  s3: # Signed int24
    seq:
      - id: a
        type: b24
    instances:
      value:
        value: (a ^ 0x80000) - 0x80000
    doc: 'Signed 24-bit integer'
  # / Uncommon Data Types
  # \ SVOD structs
  svod_vol_desc:
    seq:
      - id: size
        type: u1
      - id: block_cache_element_count
        type: u1
      - id: worker_thread_processor
        type: u1
      - id: worker_thread_priority
        type: u1
      - id: root_hash
        size: 0x14
      -
        type: b6
      - id: enhanced_gdf_layout
        type: b1
      -
        type: b1
      - id: num_data_block_raw
        size: 0x3
      - id: start_data_block_raw
        size: 0x3
      - size: 0x05
  # / SVOD structs
  # \ STFS Structs
  stfs_vol_desc:
    seq:
      - id: size
        type: u1
        valid: _io.size
      - id: version
        type: u1
      - id: flags
        type: stfs_vol_desc_flags
        size: 0x1
      - id: file_table_block_count
        type: u2
      - id: file_table_block_num_raw
        type: u1
      - id: top_hash_table_hash
        type: u1
      - id: allocated_block_count
        type: u4
      - id: unallocated_block_count
        type: u4
  stfs_vol_desc_flags:
    seq:
      - id: read_only_format
        type: b1
        doc: |
          if set, only uses a single backing-block
          per hash table (no resiliency),
          otherwise uses two
      - id: root_active_index
        type: b1
        doc: |
          if set, uses secondary backing-block
          for the highest-level hash table
      - id: directory_overallocated
        type: b1
      - id: directory_index_bounds_valid
        type: b1
      - type: b4
    doc: One byte of flags for the STFS volume descriptor
  stfs_hash_entry:
    seq:
      - id: sha1
        size: 0x14
      - id: info_raw
        type: u4
  stfs_hash_table:
    seq:
      - id: entries
        type: stfs_hash_entry
        repeat: expr
        repeat-expr: 170
      - id: num_blocks
        type: u4
      - size: 0xC
  stfs_directory_entry:
    seq:
      - id: name
        size: 40
      - id: flags
        type: stfs_dir_entry_flags
      - id: valid_data_blocks_raw
        size: 0x3
      - id: allocated_data_blocks_raw
        size: 0x3
      - id: start_block_number_raw
        size: 0x3
  stfs_dir_entry_flags:
    seq:
      - id: name_length
        type: b6
      - id: contiguous
        type: b1
      - id: directory
        type: b1
    doc: One byte of flags for an STFS directory entry
  stfs_file_entry:
    seq:
      - id: entry_index
        type: u4
      - id: name
        type: str
        size: name_length
        encoding: ASCII
      - id: name_length
        type: u1
      - id: flags
        type: b8
        doc: Number of blocks allocated for file (little endian)
      - id: blocks_allocated_for_file
        type: s3
      - id: starting_block_num
        type: s3
      - id: path_indicator
        type: s2
        doc: Path indicator (big endian)
      - id: file_size
        type: u4
        doc: Size of file in bytes (big endian)
      - id: update_date_time
        type: s4
        doc: Date/Time stamp of last update to the file
      - id: access_date_time
        type: s4
        doc: Date/Time stamp of last access of the file
      - id: file_entry_address
        type: s4
  # / STFS Structs
  # \ XContent Structs
  ## \ Header
  x_content_header:
    seq:
      - id: magic
        type: u4
        enum: magic
        valid:
          any-of:
            - 'magic::live'
            - 'magic::pirs'
            - 'magic::con'
      - id: certificate
        type: certificate
        if: 'magic == magic::con'
      - id: package_signature
        size: 0x228
        if: 'magic == magic::live or magic == magic::pirs'
    enums:
      magic:
        0x434f4e20: con
        0x4c495645: live
        0x50495253: pirs
  certificate:
    seq:
      - id: pub_key_cert_size
        type: u2
      - id: owner_console_id
        size: 0x5
      - id: owner_console_part_number
        type: str
        encoding: ASCII
        size: 0x11
      - id: console_type_data
        type: u4
      - id: date_generation
        type: str
        size: 0x8
        encoding: ASCII
      - id: public_exponent
        type: u4
      - id: public_modulus
        size: 0x80
      - id: certificate_signature
        size: 0x100
      - id: signature
        size: 0x80
    instances:
      console_type:
        value: 'console_type_data & 0x00000003'
        enum: console_type
      console_type_flags:
        value: 'console_type_data & 0xFFFFFFFC'
        enum: console_type_flags
      is_console_type_valid:
        value: 'console_type == console_type::retail or console_type == console_type::devkit'
    enums:
      console_type:
        1: devkit
        2: retail
      console_type_flags:
        0x40000000: test_kit
        0x80000000: recovery_generated
  x_content_license:
    seq:
      - id: licensee_id
        type: u8
      - id: bits
        type: b32
      - id: data
        type: u4
    instances:
      type:
        value: 'data >> 48'
        enum: license_type
      flags:
        value: data & 0xFFFFFFFFFFFF
    enums:
      license_type:
        0x0000: unused
        0xFFFF: unrestricted
        0x0009: console_profile_license
        0x0003: windows_profile_license
        0xF000: console_license
        0xE000: media_flags
        0xD000: key_vault_privileges
        0xC000: hypervisor_flags
        0xB000: user_privileges
  ## / Header
  ## \ Metadata
  x_content_metadata:
    seq:
      - id: content_type
        type: u4
        enum: content_type
      - id: metadata_version
        type: u4
        enum: metadata_version
      - id: content_size
        type: u8
      - id: execution_info
        type: xex2_opt_execution_info
      - id: console_id
        size: 0x5
      - id: profile_id
        size: 0x8
      - id: volume_descriptor
        size: 0x24
        type:
          switch-on: descriptor_type
          cases:
            'descriptor_type::stfs': stfs_vol_desc
            'descriptor_type::svod': svod_vol_desc
      - id: data_file_count
        type: u4
      - id: data_file_size
        type: u8
        doc: Size of all the files inside the package combined
      - id: volume_type
        type: u4
        enum: descriptor_type
        doc: Specifies which volume descriptor is used
      - id: online_creator
        type: u8
      - id: category
        type: u4
      - size: 0x20
      - id: metadata_v2
        size: 0x24
        type:
          switch-on: content_type
          cases:
            'content_type::tv': media_data
            'content_type::avatar_item': avatar_asset_data
        if: 'metadata_version == metadata_version::two'
      - id: device_id
        size: 0x14
      - id: display_names
        size: 0x80
        type: str
        repeat: expr
        repeat-expr: 0x10
      - id: descriptions
        size: 0x80
        type: str
        repeat: expr
        repeat-expr: 0x10
      - id: publisher
        size: 0x80
        type: str
      - id: title_name
        size: 0x80
        type: str
      - id: transfer_flags
        type: x_content_attributes
        size: 0x1
      - id: thumbnail_size
        type: u4
      - id: title_thumbnail_size
        type: u4
      - id: thumbnail_image
        size: thumbnail_size
      - id: display_names_ex
        type: str
        size: 0x80
        repeat: expr
        repeat-expr: 6
        if: 'metadata_version == metadata_version::two'
      - id: title_thumbnail_image
        size: title_thumbnail_size
      - id: descriptions_ex
        type: str
        size: 0x80
        repeat: expr
        repeat-expr: 6
        if: 'metadata_version == metadata_version::two'
    instances:
      descriptor_type:
        pos: 0x03A9
        type: u4
        enum: descriptor_type
    enums:
      metadata_version:
        1: one
        2: two
  media_data:
    seq:
      - id: series_id
        size: 0x10
      - id: season_id
        size: 0x10
      - id: season_number
        type: u2
      - id: episode_number
        type: u2
  avatar_asset_data:
    seq:
      - id: sub_category
        type: u4
      - id: colorizable
        type: u4
      - id: asset_id
        size: 0x10
      - id: skeleton_version_mask
        type: u1
      - size: 0xB
  x_content_attributes:
    seq:
      - id: profile_id_transfer
        type: b1
      - id: device_id_transfer
        type: b1
      - id: move_only_transfer
        type: b1
      - id: kinect_enabled
        type: b1
      - id: disable_network_storage
        type: b1
      - id: deep_link_support
        type: b1
      - type: b2
  ## / Metadata
  # / XContent Structs
  # \ XEX Structs
  xex2_opt_execution_info:
    seq:
      - id: media_id
        type: u4
      - id: version
        type: xex2_version
        doc: Version for system/title updates
      - id: base_version
        type: xex2_version
        doc: Base version for system/title updates
      - id: title_id
        type: u4
      - id: platform
        type: u1
        enum: platform
      - id: executable_type
        type: u1
      - id: disc_number
        type: u1
      - id: disc_in_set
        type: u1
      - id: save_game_id
        type: u4
  xex2_version:
    meta:
      bit-endian: le
    seq:
      - id: major
        type: b4
      - id: minor
        type: b4
      - id: build
        type: b16
      - id: qfe
        type: b8
  # / XEX Structs

  ms_time:
    seq:
      - id: data
        type: u4
    instances:
      year:
        value: '((data & 0xFE000000) >> 25) + 1980'
      month:
        value: '(data & 0x1E000000) >> 21'
      month_day:
        value: '(data & 0x001F0000) >> 16'
      hours:
        value: '(data & 0x0000F800) >> 11'
      minutes:
        value: '(data & 0x000007E0) >> 5'
      seconds:
        value: 'data & 0x0000001F'
  pec_header:
    seq:
      - id: console_security_certificate
        size: 228 # TODO: type
      - id: sha1_hash
        size: 0x14
        doc: Sha1 hash of data from 0x023C-0x1000
      - size: 0x8
      - id: volume_desc
        type: stfs_vol_desc
      - size: 0x4
      - id: profile_id
        size: 0x8
      - size: 0x1
      - id: console_id
        size: 0x5
enums:
  sex:
    0: male
    1: female
  level:
    0: zero
    1: one
    2: two
  file_entry_flags:
    1: consecutive_blocks
    2: folder
  installer_type:
     0x00000000: none
     0x53555044: system_update
     0x54555044: title_update
     0x50245355: system_update_progress_cache
     0x50245455: title_update_progress_cache
     0x50245443: title_content_progress_cache
  content_type:
    0x0000001: saved_game
    0x0000002: marketplace_content
    0x0000003: publisher
    0x0001000: xbox_360_title
    0x0002000: iptv_pause_buffer
    0x0004000: installed_game
    0x0005000: xbox_title
    0x0009000: avatar_item
    0x0010000: profile
    0x0020000: gamer_picture
    0x0030000: theme
    0x0040000: cache_file
    0x0050000: storage_download
    0x0060000: xbox_saved_game
    0x0070000: xbox_download
    0x0080000: games_on_demand
    0x0090000: video
    0x00A0000: game_trailer
    0x00B0000: installer
    0x00D0000: arcade_title
    0x00E0000: xna
    0x00F0000: license_store
    0x0100000: movie
    0x0200000: tv
    0x0300000: music_video
    0x0400000: game_video
    0x0500000: podcast_video
    0x0600000: viral_video
    0x2000000: community_game
  block_status_level_zero:
    0x00: unallocated
    0x40: previously_allocated
    0x80: allocated
    0xC0: newly_allocated
  svod_features:
    0x40: enhanced_gdf_layout
    0x80: should_be_zero_for_down_level_clients
  platform:
    0x2: xbox_360
    0x4: pc
  descriptor_type:
    0x0: stfs
    0x1: svod
