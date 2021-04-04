meta:
  id: windows_lnk_file
  title: Windows shell link file
  file-extension: lnk
  xref:
    forensicswiki: LNK
    justsolve: Windows_Shortcut
    mime: application/x-ms-shortcut
    pronom: x-fmt/428
    wikidata: Q29000599
  license: CC0-1.0
  imports:
    - windows_shell_items
  encoding: cp437
  endian: le
doc: |
  Windows .lnk files (AKA "shell link" file) are most frequently used
  in Windows shell to create "shortcuts" to another files, usually for
  purposes of running a program from some other directory, sometimes
  with certain preconfigured arguments and some other options.
doc-ref: 'https://winprotocoldoc.blob.core.windows.net/productionwindowsarchives/MS-SHLLINK/[MS-SHLLINK].pdf'
seq:
  - id: header
    type: file_header
  - id: target_id_list
    type: link_target_id_list
    if: header.flags.has_link_target_id_list
  - id: info
    type: link_info
    if: header.flags.has_link_info
  - id: name
    -orig-id: NAME_STRING
    type: string_data
    if: header.flags.has_name
  - id: rel_path
    -orig-id: RELATIVE_PATH
    type: string_data
    if: header.flags.has_rel_path
  - id: work_dir
    -orig-id: WORKING_DIR
    type: string_data
    if: header.flags.has_work_dir
  - id: arguments
    -orig-id: COMMAND_LINE_ARGUMENTS
    type: string_data
    if: header.flags.has_arguments
  - id: icon_location
    -orig-id: ICON_LOCATION
    type: string_data
    if: header.flags.has_icon_location
types:
  file_header:
    -orig-id: ShellLinkHeader
    doc-ref: 'https://winprotocoldoc.blob.core.windows.net/productionwindowsarchives/MS-SHLLINK/[MS-SHLLINK].pdf Section 2.1'
    seq:
      - id: len_header
        -orig-id: HeaderSize
        contents: [0x4c, 0, 0, 0]
        doc: |
          Technically, a size of the header, but in reality, it's
          fixed by standard.
      - id: link_clsid
        contents: [0x01, 0x14, 0x02, 0x00, 0x00, 0x00, 0x00, 0x00, 0xc0, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x46]
        doc: |
          16-byte class identified (CLSID), reserved for Windows shell
          link files.
      - id: flags
        -orig-id: LinkFlags
        type: link_flags
        size: 4
      - id: file_attrs
        type: u4
      - id: time_creation
        -orig-id: CreationTime
        type: u8
      - id: time_access
        -orig-id: AccessTime
        type: u8
      - id: time_write
        -orig-id: WriteTime
        type: u8
      - id: target_file_size
        -orig-id: FileSize
        type: u4
        doc: Lower 32 bits of the size of the file that this link targets
      - id: icon_index
        -orig-id: IconIndex
        type: s4
        doc: Index of an icon to use from target file
      - id: show_command
        -orig-id: ShowCommand
        type: u4
        enum: window_state
        doc: Window state to set after the launch of target executable
      - id: hotkey
        type: u2
      - id: reserved
        contents: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
  link_flags:
    doc-ref: 'https://winprotocoldoc.blob.core.windows.net/productionwindowsarchives/MS-SHLLINK/[MS-SHLLINK].pdf Section 2.1.1'
    seq:
      # Byte #0
      - id: is_unicode
        -orig-id: IsUnicode (H)
        type: b1
      - id: has_icon_location
        -orig-id: HasIconLocation (G)
        type: b1
      - id: has_arguments
        -orig-id: HasArguments (F)
        type: b1
      - id: has_work_dir
        -orig-id: HasWorkingDir (E)
        type: b1
      - id: has_rel_path
        -orig-id: HasRelativePath (D)
        type: b1
      - id: has_name
        -orig-id: HasName (C)
        type: b1
      - id: has_link_info
        -orig-id: HasLinkInfo (B)
        type: b1
      - id: has_link_target_id_list
        -orig-id: HasLinkTargetIDList (A)
        type: b1
      # Byte #1, 2
      - type: b16
      # Byte #3
      - id: reserved
        type: b5
      - id: keep_local_id_list_for_unc_target
        -orig-id: KeepLocalIDListForUNCTarget (AA)
        type: b1
      - type: b2
  link_target_id_list:
    -orig-id: LinkTargetIDList
    doc-ref: 'https://winprotocoldoc.blob.core.windows.net/productionwindowsarchives/MS-SHLLINK/[MS-SHLLINK].pdf Section 2.2'
    seq:
      - id: len_id_list
        -orig-id: IDListSize
        type: u2
      - id: id_list
        -orig-id: IDList
        size: len_id_list
        type: windows_shell_items
  link_info:
    -orig-id: LinkInfo
    doc-ref: 'https://winprotocoldoc.blob.core.windows.net/productionwindowsarchives/MS-SHLLINK/[MS-SHLLINK].pdf Section 2.3'
    seq:
      - id: len_all
        -orig-id: LinkInfoSize
        type: u4
      - id: all
        size: len_all - 4
        type: all
    types:
      all:
        doc-ref: 'https://winprotocoldoc.blob.core.windows.net/productionwindowsarchives/MS-SHLLINK/[MS-SHLLINK].pdf Section 2.3'
        seq:
          - id: len_header
            -orig-id: LinkInfoHeaderSize
            type: u4
          - id: header
            size: len_header - 8 # LinkInfoSize and LinkInfoHeaderSize
            type: header
        instances:
          volume_id:
            -orig-id: VolumeID
            pos: header.ofs_volume_id - 4
            type: volume_id_spec
            if: header.flags.has_volume_id_and_local_base_path
          local_base_path:
            -orig-id: LocalBasePath
            pos: header.ofs_local_base_path - 4
            terminator: 0
            if: header.flags.has_volume_id_and_local_base_path
      header:
        doc-ref: 'https://winprotocoldoc.blob.core.windows.net/productionwindowsarchives/MS-SHLLINK/[MS-SHLLINK].pdf Section 2.3'
        seq:
          - id: flags
            -orig-id: LinkInfoFlags
            type: link_info_flags
          - id: ofs_volume_id
            -orig-id: VolumeIDOffset
            type: u4
          - id: ofs_local_base_path
            -orig-id: LocalBasePathOffset
            type: u4
          - id: ofs_common_net_rel_link
            -orig-id: CommonNetworkRelativeLinkOffset
            type: u4
          - id: ofs_common_path_suffix
            -orig-id: CommonPathSuffixOffset
            type: u4
          - id: ofs_local_base_path_unicode
            -orig-id: LocalBasePathOffsetUnicode
            type: u4
            if: not _io.eof
          - id: ofs_common_path_suffix_unicode
            -orig-id: CommonPathSuffixOffsetUnicode
            type: u4
            if: not _io.eof
      link_info_flags:
        -orig-id: LinkInfoFlags
        doc-ref: 'https://winprotocoldoc.blob.core.windows.net/productionwindowsarchives/MS-SHLLINK/[MS-SHLLINK].pdf Section 2.3'
        seq:
          - id: reserved1
            type: b6
          - id: has_common_net_rel_link
            -orig-id: CommonNetworkRelativeLinkAndPathSuffix (B)
            type: b1
          - id: has_volume_id_and_local_base_path
            -orig-id: VolumeIDAndLocalBasePath (A)
            type: b1
          - id: reserved2
            type: b24
      volume_id_spec:
        -orig-id: VolumeID
        doc-ref: 'https://winprotocoldoc.blob.core.windows.net/productionwindowsarchives/MS-SHLLINK/[MS-SHLLINK].pdf Section 2.3.1'
        seq:
          - id: len_all
            -orig-id: VolumeIDSize
            type: u4
          - id: body
            size: len_all - 4
            type: volume_id_body
      volume_id_body:
        -orig-id: VolumeID
        doc-ref: 'https://winprotocoldoc.blob.core.windows.net/productionwindowsarchives/MS-SHLLINK/[MS-SHLLINK].pdf Section 2.3.1'
        seq:
          - id: drive_type
            -orig-id: DriveType
            type: u4
            enum: drive_types
          - id: drive_serial_number
            -orig-id: DriveSerialNumber
            type: u4
          - id: ofs_volume_label
            -orig-id: VolumeLabelOffset
            type: u4
          - id: ofs_volume_label_unicode
            -orig-id: VolumeLabelOffsetUnicode
            type: u4
            if: is_unicode
        instances:
          is_unicode:
            value: ofs_volume_label == 0x14
          volume_label_ansi:
            pos: ofs_volume_label - 4
            type: strz
            if: not is_unicode
  string_data:
    seq:
      - id: chars_str
        -orig-id: CountCharacters
        type: u2
      - id: str
        size: chars_str * 2
        type: str
        encoding: UTF-16LE
enums:
  window_state:
    1: normal
    3: maximized
    7: min_no_active
  drive_types:
    0: unknown
    1: no_root_dir
    2: removable
    3: fixed
    4: remote
    5: cdrom
    6: ramdisk
