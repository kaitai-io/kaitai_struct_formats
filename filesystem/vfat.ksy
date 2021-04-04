meta:
  id: vfat
  # actually FAT12
  xref:
    forensicswiki: FAT
    justsolve: FAT
    wikidata: Q190167
  tags:
    - dos
  license: CC0-1.0
  ks-version: 0.9
  imports:
    - /common/dos_datetime
  endian: le
  bit-endian: le
doc-ref: https://download.microsoft.com/download/0/8/4/084c452b-b772-4fe5-89bb-a0cbf082286a/fatgen103.doc
seq:
  - id: boot_sector
    type: boot_sector
instances:
  fats:
    pos: boot_sector.pos_fats
    size: boot_sector.size_fat
    repeat: expr
    repeat-expr: boot_sector.bpb.num_fats
  root_dir:
    pos: boot_sector.pos_root_dir
    size: boot_sector.size_root_dir
    type: root_directory
types:
  boot_sector:
    seq:
      - id: jmp_instruction
        size: 3
      - id: oem_name
        type: str
        encoding: ASCII
        pad-right: 0x20
        size: 8
      - id: bpb
        type: bios_param_block
        doc: Basic BIOS parameter block, present in all versions of FAT
      - id: ebpb_fat16
        type: ext_bios_param_block_fat16
        if: not is_fat32
        doc: FAT12/16-specific extended BIOS parameter block
      - id: ebpb_fat32
        type: ext_bios_param_block_fat32
        if: is_fat32
        doc: FAT32-specific extended BIOS parameter block
    instances:
      is_fat32:
        value: bpb.max_root_dir_rec == 0
        doc: |
          Determines if filesystem is FAT32 (true) or FAT12/16 (false)
          by analyzing some preliminary conditions in BPB. Used to
          determine whether we should parse post-BPB data as
          `ext_bios_param_block_fat16` or `ext_bios_param_block_fat32`.
      pos_fats:
        value: bpb.bytes_per_ls * bpb.num_reserved_ls
        doc: Offset of FATs in bytes from start of filesystem
      ls_per_fat:
        value: 'is_fat32 ? ebpb_fat32.ls_per_fat : bpb.ls_per_fat'
      size_fat:
        value: bpb.bytes_per_ls * ls_per_fat
        doc: Size of one FAT in bytes
      pos_root_dir:
        value: bpb.bytes_per_ls * (bpb.num_reserved_ls + ls_per_fat * bpb.num_fats)
        doc: Offset of root directory in bytes from start of filesystem
      ls_per_root_dir:
        -orig-id: RootDirSectors
        value: (bpb.max_root_dir_rec * 32 + bpb.bytes_per_ls - 1) / bpb.bytes_per_ls
        doc: Size of root directory in logical sectors
        doc-ref: 'FAT: General Overview of On-Disk Format, section "FAT Data Structure"'
      size_root_dir:
        value: ls_per_root_dir * bpb.bytes_per_ls
        doc: Size of root directory in bytes
  bios_param_block:
    seq:
      # Basic BIOS Parameter block, DOS 2.0+
      - id: bytes_per_ls
        -orig-id: BPB_BytsPerSec
        type: u2
        doc: Bytes per logical sector
      - id: ls_per_clus
        -orig-id: BPB_SecPerClus
        type: u1
        doc: Logical sectors per cluster
      - id: num_reserved_ls
        -orig-id: BPB_RsvdSecCnt
        type: u2
        doc: |
          Count of reserved logical sectors. The number of logical
          sectors before the first FAT in the file system image.
      - id: num_fats
        -orig-id: BPB_NumFATs
        type: u1
        doc: Number of File Allocation Tables
      - id: max_root_dir_rec
        -orig-id: BPB_RootEntCnt
        type: u2
        doc: |
          Maximum number of FAT12 or FAT16 root directory entries. 0
          for FAT32, where the root directory is stored in ordinary
          data clusters.
      - id: total_ls_2
        -orig-id: BPB_TotSec16
        type: u2
        doc: Total logical sectors (if zero, use total_ls_4)
      - id: media_code
        -orig-id: BPB_Media
        type: u1
        doc: Media descriptor
      - id: ls_per_fat
        -orig-id: BPB_FATSz16
        type: u2
        doc: |
          Logical sectors per File Allocation Table for
          FAT12/FAT16. FAT32 sets this to 0 and uses the 32-bit value
          at offset 0x024 instead.
      # FIXME: DOS 3.0 and 3.2 BPBs continuation should follow here
      # and they differ from DOS 3.31+ that most modern
      # implementations use. We'll skip them for now, as they seem to
      # be very rare.
      #
      # DOS 3.31+ BPB
      - id: ps_per_track
        -orig-id: BPB_SecPerTrk
        type: u2
        doc: |
          Physical sectors per track for disks with INT 13h CHS
          geometry, e.g., 15 for a "1.20 MB" (1200 KB) floppy. A zero
          entry indicates that this entry is reserved, but not used.
      - id: num_heads
        -orig-id: BPB_NumHeads
        type: u2
        doc: |
          Number of heads for disks with INT 13h CHS geometry,[9]
          e.g., 2 for a double sided floppy.
      - id: num_hidden_sectors
        -orig-id: BPB_HiddSec
        type: u4
        doc: |
          Number of hidden sectors preceding the partition that
          contains this FAT volume. This field should always be zero
          on media that are not partitioned. This DOS 3.0 entry is
          incompatible with a similar entry at offset 0x01C in BPBs
          since DOS 3.31.  It must not be used if the logical sectors
          entry at offset 0x013 is zero.
      - id: total_ls_4
        -orig-id: BPB_TotSec32
        type: u4
        doc: |
          Total logical sectors including hidden sectors. This DOS 3.2
          entry is incompatible with a similar entry at offset 0x020
          in BPBs since DOS 3.31. It must not be used if the logical
          sectors entry at offset 0x013 is zero.
  ext_bios_param_block_fat16:
    doc: |
      Extended BIOS Parameter Block (DOS 4.0+, OS/2 1.0+). Used only
      for FAT12 and FAT16.
    seq:
      - id: phys_drive_num
        type: u1
        doc: |
          Physical drive number (0x00 for (first) removable media,
          0x80 for (first) fixed disk as per INT 13h).
      - id: reserved1
        type: u1
      - id: ext_boot_sign
        type: u1
        doc: |
          Should be 0x29 to indicate that an EBPB with the following 3
          entries exists.
      - id: volume_id
        size: 4
        doc: |
          Volume ID (serial number).

          Typically the serial number "xxxx-xxxx" is created by a
          16-bit addition of both DX values returned by INT 21h/AH=2Ah
          (get system date) and INT 21h/AH=2Ch (get system time) for
          the high word and another 16-bit addition of both CX values
          for the low word of the serial number. Alternatively, some
          DR-DOS disk utilities provide a /# option to generate a
          human-readable time stamp "mmdd-hhmm" build from BCD-encoded
          8-bit values for the month, day, hour and minute instead of
          a serial number.
      - id: partition_volume_label
        size: 11
        type: str
        encoding: ASCII
        pad-right: 0x20
      - id: fs_type_str
        size: 8
        type: str
        encoding: ASCII
        pad-right: 0x20
  ext_bios_param_block_fat32:
    doc: Extended BIOS Parameter Block for FAT32
    seq:
      - id: ls_per_fat
        type: u4
        doc: |
          Logical sectors per file allocation table (corresponds with
          the old entry `ls_per_fat` in the DOS 2.0 BPB).
      - id: has_active_fat
        type: b1
        doc: |
          If true, then there is "active" FAT, which is designated in
          `active_fat` attribute. If false, all FATs are mirrored as
          usual.
      - id: reserved1
        type: b3
      - id: active_fat_id
        type: b4
        doc: |
          Zero-based number of active FAT, if `has_active_fat`
          attribute is true.
      - id: reserved2
        contents: [0]
      - id: fat_version
        type: u2
      - id: root_dir_start_clus
        type: u4
        doc: |
          Cluster number of root directory start, typically 2 if it
          contains no bad sector. (Microsoft's FAT32 implementation
          imposes an artificial limit of 65,535 entries per directory,
          whilst many third-party implementations do not.)
      - id: ls_fs_info
        type: u2
        doc: |
          Logical sector number of FS Information Sector, typically 1,
          i.e., the second of the three FAT32 boot sectors. Values
          like 0 and 0xFFFF are used by some FAT32 implementations to
          designate abscence of FS Information Sector.
      - id: boot_sectors_copy_start_ls
        type: u2
        doc: |
          First logical sector number of a copy of the three FAT32
          boot sectors, typically 6.
      - id: reserved3
        size: 12
      - id: phys_drive_num
        type: u1
        doc: |
          Physical drive number (0x00 for (first) removable media,
          0x80 for (first) fixed disk as per INT 13h).
      - id: reserved4
        type: u1
      - id: ext_boot_sign
        type: u1
        doc: |
          Should be 0x29 to indicate that an EBPB with the following 3
          entries exists.
      - id: volume_id
        size: 4
        doc: |
          Volume ID (serial number).

          Typically the serial number "xxxx-xxxx" is created by a
          16-bit addition of both DX values returned by INT 21h/AH=2Ah
          (get system date) and INT 21h/AH=2Ch (get system time) for
          the high word and another 16-bit addition of both CX values
          for the low word of the serial number. Alternatively, some
          DR-DOS disk utilities provide a /# option to generate a
          human-readable time stamp "mmdd-hhmm" build from BCD-encoded
          8-bit values for the month, day, hour and minute instead of
          a serial number.
      - id: partition_volume_label
        size: 11
        type: str
        encoding: ASCII
        pad-right: 0x20
      - id: fs_type_str
        size: 8
        type: str
        encoding: ASCII
        pad-right: 0x20
  root_directory:
    seq:
      - id: records
        type: root_directory_rec
        repeat: expr
        repeat-expr: _root.boot_sector.bpb.max_root_dir_rec
  root_directory_rec:
    seq:
      - id: file_name
        size: 11
      - id: attrs
        size: 1
        type: attr_flags
      - id: reserved
        size: 10
      - id: last_write_time
        size: 4
        type: dos_datetime
      - id: start_clus
        type: u2
      - id: file_size
        type: u4
    types:
      attr_flags:
        seq:
          - id: read_only
            type: b1
          - id: hidden
            type: b1
          - id: system
            type: b1
          - id: volume_id
            type: b1
          - id: is_directory
            type: b1
          - id: archive
            type: b1
          - id: reserved
            type: b2
        instances:
          long_name:
            value: |
              read_only
              and hidden
              and system
              and volume_id
