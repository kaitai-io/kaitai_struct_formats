meta:
  id: regf
  title: Windows registry database
  application: Windows NT and later
  xref:
    justsolve: Windows_Registry
    forensicswiki: windows_nt_registry_file_(regf)
    wikidata: Q463244
  license: CC0-1.0
  endian: le
doc: |
  This spec allows to parse files used by Microsoft Windows family of
  operating systems to store parts of its "registry". "Registry" is a
  hierarchical database that is used to store system settings (global
  configuration, per-user, per-application configuration, etc).

  Typically, registry files are stored in:

  * System-wide: several files in `%SystemRoot%\\System32\\Config\\`
  * User-wide:
    * `%USERPROFILE%\\Ntuser.dat`
    * `%USERPROFILE%\\Local Settings\\Application Data\\Microsoft\\Windows\\Usrclass.dat` (localized, Windows 2000, Server 2003 and Windows XP)
    * `%USERPROFILE%\\AppData\\Local\\Microsoft\\Windows\\Usrclass.dat` (non-localized, Windows Vista and later)

  Note that one typically can't access files directly on a mounted
  filesystem with a running Windows OS.
doc-ref: 'https://github.com/libyal/libregf/blob/main/documentation/Windows%20NT%20Registry%20File%20(REGF)%20format.asciidoc'
seq:
  - id: header
    type: file_header
  - id: hive_bins
    type: hive_bin
    repeat: eos
types:
  file_header:
    seq:
      - id: signature
        contents: "regf"
      - id: primary_sequence_number
        type: u4
        doc: Matches the secondary sequence number if the hive was properly synchronized
      - id: secondary_sequence_number
        type: u4
        doc: Matches the primary sequence number if the hive was properly synchronized
      - id: last_modification_date_and_time
        type: winfiletime
        doc: Contains a FILETIME in UTC
      - id: major_version
        type: u4
      - id: minor_version
        type: u4
      - id: type
        type: u4
        enum: file_type
      - id: format
        type: u4
        enum: file_format
      - id: root_key_offset
        type: u4
      - id: hive_bins_data_size
        type: u4
      - id: clustering_factor
        type: u4
        doc: Logical sector size of the underlying disk in bytes divided by 512
      - id: unknown1
        size: 64
        doc: Sometimes contains the last part of the filename in UTF-16 LE most of the time with an end-of-string character, but not always. Unused bytes are 0.
      - id: unknown2
        size: 396
        doc: Can contain remnant data, Padding used for the checksum?
      - id: checksum
        type: u4
        doc: XOR-32 of the previous 508 bytes
      - id: reserved
        size: 3576
      - id: boot_type
        type: u4
        doc: This field has no meaning on a disk
      - id: boot_recover
        type: u4
        doc: This field has no meaning on a disk
    enums:
      file_type:
        0: normal
        1: transaction_log
      file_format:
        1: direct_memory_load
  hive_bin_header:
    seq:
      - id: offset
        type: u4
        doc: |
          The offset of the hive bin, Value in bytes and relative from
          the start of the hive bin data
      - id: size
        type: u4
        doc: Size of the hive bin
      - id: unknown1
        type: u4
        doc: 0 most of the time, can contain remnant data
      - id: unknown2
        type: u4
        doc: 0 most of the time, can contain remnant data
      - id: timestamp
        type: winfiletime
        doc: Only the root (first) hive bin seems to contain a valid FILETIME
      - id: unknown4
        type: u4
        doc: Contains number of bytes
  hive_bin_cell:
    seq:
      - id: cell_size_raw
        type: s4
      - id: identifier_raw
        type: u2
        enum: data_flags
      - id: data
        size: cell_size - 2 - 4
        type:
          switch-on: identifier
          cases:
            data_flags::nk: named_key
            data_flags::lh: sub_key_list_lh_lf
            data_flags::lf: sub_key_list_lh_lf
            data_flags::li: sub_key_list_li
            data_flags::ri: sub_key_list_ri
            data_flags::vk: sub_key_list_vk
            data_flags::sk: sub_key_list_sk
      - id: padding
        size: (8 - _io.pos) % 8
    enums:
      data_flags:
        0x6B6E: nk
        0x686C: lh
        0x666C: lf
        0x696C: li
        0x6972: ri
        0x6B76: vk
        0x6B73: sk
        0x0000: nll
    -webide-representation: "{identifier}"
    instances:
      cell_size:
        value: "(cell_size_raw < 0 ? -1 : +1) * cell_size_raw"
        -webide-parse-mode: eager
      identifier:
        value: "(cell_size_raw > 0 ? data_flags::nll : identifier_raw)"
      is_allocated:
        value: "cell_size_raw < 0"
        -webide-parse-mode: eager
    types:
      named_key:
        seq:
          - id: flags
            type: u2
            enum: nk_flags
          - id: last_key_written_date_and_time
            type: winfiletime
          - id: unknown1
            type: u4
            doc: empty value
          - id: parent_key_offset
            type: u4
            doc: The offset value is in bytes and relative from the start of the hive bin data
          - id: number_of_sub_keys
            type: u4
          - id: number_of_volatile_sub_keys
            type: u4
            doc: The offset value is in bytes and relative from the start of the hive bin data / Refers to a sub keys list or contains -1 (0xffffffff) if empty.
          - id: sub_keys_list_offset
            type: u4
            doc: The offset value is in bytes and relative from the start of the hive bin data / Refers to a sub keys list or contains -1 (0xffffffff) if empty.
          - id: volatile_sub_keys_list_offset
            type: u4
          - id: number_of_values
            type: u4
            doc: The offset value is in bytes and relative from the start of the hive bin data / Refers to a sub keys list or contains -1 (0xffffffff) if empty.
          - id: values_list_offset
            type: u4
          - id: security_key_offset
            type: u4
          - id: class_name_offset
            type: u4
          - id: largest_sub_key_name_size
            type: u4
          - id: largest_sub_key_class_name_size
            type: u4
          - id: largest_value_name_size
            type: u4
          - id: largest_value_data_size
            type: u4
          - id: unknown2
            type: u4
            doc: Some run-time caching index or hash?
          - id: key_name_size
            type: u2
          - id: class_name_size
            type: u2
          - id: key_name
            type: str
            encoding: iso-8859-1
            size: key_name_size
        enums:
          nk_flags:
            0x0001: key_is_volatile   # Is volatile key
            0x0002: key_hive_exit     # Is mount point (of another Registry hive)
            0x0004: key_hive_entry    # Is root key (of current Registry hive)
            0x0008: key_no_delete     # Cannot be deleted
            0x0010: key_sym_link      # Is symbolic link key
            0x0020: key_comp_name     # Name is an ASCII string / Otherwise the name is a Unicode (UTF-16 little-endian) string
            0x0040: key_prefef_handle # Is predefined handle
            0x0080: key_virt_mirrored # Unknown
            0x0100: key_virt_target   # Unknown
            0x0200: key_virtual_store # Unknown
            0x1000: unknown1
            0x4000: unknown2
      sub_key_list_lh_lf:
        seq:
          - id: count
            type: u2
          - id: items
            type: item
            repeat: expr
            repeat-expr: count
        types:
          item:
            seq:
              - id: named_key_offset
                type: u4
                doc: The offset value is in bytes and relative from the start of the hive bin data
              - id: hash_value
                type: u4
                doc: A different hash function is used for different sub key list types
      sub_key_list_li:
        seq:
          - id: count
            type: u2
          - id: items
            type: item
            repeat: expr
            repeat-expr: count
        types:
          item:
            seq:
              - id: named_key_offset
                type: u4
                doc: The offset value is in bytes and relative from the start of the hive bin data
      sub_key_list_ri:
        seq:
          - id: count
            type: u2
          - id: items
            type: item
            repeat: expr
            repeat-expr: count
        types:
          item:
            seq:
              - id: sub_key_list_offset
                type: u4
                doc: The offset value is in bytes and relative from the start of the hive bin data
      sub_key_list_vk:
        seq:
          - id: value_name_size
            type: u2
            doc: If the value name size is 0 the value name is "(default)"
          - id: data_size
            type: u4
          - id: data_offset
            type: u4
            doc: The offset value is in bytes and relative from the start of the hive bin data.
          - id: data_type
            type: u4
            enum: data_type_enum
          - id: flags
            type: u2
            enum: vk_flags
          - id: padding
            type: u2
            doc: unknown
          - id: value_name
            size: value_name_size
            type: str
            encoding: iso-8859-1
            if: "flags == vk_flags::value_comp_name"
        enums:
          data_type_enum:
            0x00000000: reg_none # Undefined type
            0x00000001: reg_sz # String / [MSDN] states that this is either in ASCII or Unicode with an end-of-string character / Although the string seems to be always stored as UTF-16 little-endian and sometimes the end-of-string character is not included. / Also see: Corruption scenarios
            0x00000002: reg_expand_sz # String that contains expandable (environment) variables like %PATH% / Either in ASCII or Unicode with an end-of-string character
            0x00000003: reg_binary # binary_data
            0x00000004: reg_dword # REG_DWORD_LITTLE_ENDIAN: 32-bit integer (double word) little-endian
            0x00000005: reg_dword_big_endian # Integer 32-bit signed big-endian (double word)
            0x00000006: reg_link # String that contains a symbolic link / Either in ASCII or Unicode with an end-of-string character
            0x00000007: reg_multi_sz # Array of strings / Either in ASCII or Unicode with an end-of-string character
            0x00000008: reg_resource_list # Resource list
            0x00000009: reg_full_resource_descriptor # Full resource descriptor
            0x0000000a: reg_resource_requirements_list # Resource requirements list
            0x0000000b: reg_qword # REG_QWORD_LITTLE_ENDIAN: Integer 64-bit signed little-endian (quad word)
          vk_flags:
            0x0001: value_comp_name # Name is an ASCII string / Otherwise the name is an Unicode (UTF-16 little-endian) string
      sub_key_list_sk:
        seq:
          - id: unknown1
            type: u2
          - id: previous_security_key_offset
            type: u4
          - id: next_security_key_offset
            type: u4
          - id: reference_count
            type: u4
  hive_bin:
    seq:
      - id: signature
        type: u4
      - id: hive_bin_content
        type:
          switch-on: signature
          cases:
            0x6E696268: hive_bin_filled # hbin
            _ : hive_bin_empty
  hive_bin_filled:
    seq:
      - id: header
        type: hive_bin_header
      - id: cells
        size: header.size - 0x20
        type: hive_bin_cells
  hive_bin_cells:
    seq:
      - id: cells
        type: hive_bin_cell
        repeat: eos
  hive_bin_empty:
    seq:
      - id: content
        size: 0x1000 - 0x4
  winfiletime:
    doc: |
      timestamp: timestamp * (1e-07) --> seconds
      offset: 11644473600
    seq:
      - id: ts
        type: u8
    instances:
      unixts:
        value: (ts * 1e-07) - 11644473600
    -webide-representation: "{value}"
