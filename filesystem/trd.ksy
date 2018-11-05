meta:
  id: tr_dos_image
  file-extension: trd
  title: "TR-DOS flat-file disk image"
  license: CC0-1.0
  # It's extended ascii (with ZX Spectrum Basic tokens, UDG, etc), but
  # "unknown-8bit" can't be used for some reason
  encoding: ascii
  endian: le
doc: |
  .trd file is a raw dump of TR-DOS (ZX-Spectrum) floppy. .trd files are
  headerless and contain consequent "logical tracks", each logical track
  consists of 16 256-byte sectors.

  Logical tracks are defined the same way as used by TR-DOS: for single-side
  floppies it's just a physical track number, for two-side floppies sides are
  interleaved, i.e. logical_track_num = (physical_track_num << 1) | side

  So, this format definition is more for TR-DOS filesystem than for .trd files,
  which are formatless.

  Strings (file names, disk label, disk password) are padded with spaces and use
  ZX Spectrum character set, including UDGs, block drawing chars and Basic
  tokens. ASCII range is mostly standard ASCII, with few characters (^, `, DEL)
  replaced with (up arrow, pound, copyright symbol).
seq:
  - id: files
    type: file
    repeat: until
    # After 128 files there is disk info entry, which also has 0x00 terminator
    # in the same position as file name. So usually even with 128 files you can
    # just read until 0x00.
    repeat-until: _.is_terminator
instances:
  volume_info:
    pos: 0x800
    type: volume_info
types:
  file:
    seq:
      - id: name
        type: str
        size: 8
      - id: extension
        type: str
        size: 1
      - id: position_and_length
        type:
          switch-on: extension
          cases:
            '"B"': position_and_length_basic
            '"C"': position_and_length_code
            '"#"': position_and_length_print
            _: position_and_length_generic
      - id: length_sectors
        type: u1
      - id: starting_sector
        type: u1
      - id: starting_track
        type: u1
    instances:
      is_deleted:
        value: name.substring(0, 1) == "\1"
      is_terminator:
        value: name.substring(0, 1) == "\0"
      contents:
        pos: starting_track * 256 * 16 + starting_sector * 256
        size: length_sectors * 256
  position_and_length_basic:
    seq:
      - id: program_and_data_length
        type: u2
      - id: program_length
        type: u2
  position_and_length_code:
    seq:
      - id: start_address
        type: u2
        doc: Default memory address to load this byte array into
      - id: length
        type: u2
  position_and_length_print:
    seq:
      - id: extent_no
        type: u1
      - id: reserved
        type: u1
      - id: length
        type: u2
  position_and_length_generic: # used for standard 'D' type and unknown types
    seq:
      - id: reserved
        type: u2
      - id: length
        type: u2
  volume_info:
    seq:
      # This is 0x00 at the same position as first character of filename in
      # file entries for convenience. When disk has 128 files, it acts as
      # "last file" terminator.
      - id: catalog_end
        contents: [0]
      - id: unused
        size: 224
      - id: first_free_sector_sector
        type: u1
      - id: first_free_sector_track
        doc: |
          track number is logical, for double-sided disks it's
          (physical_track << 1) | side, the same way that tracks are stored
          sequentially in .trd file
        type: u1
      - id: disk_type
        type: u1
        enum: disk_type
      - id: number_of_files
        doc: |
          Number of non-deleted files. Directory can have more than
          number_of_files entries due to deleted files
        type: u1
      - id: number_of_free_sectors
        type: u2
      - id: tr_dos_id
        contents: [0x10]
      - id: unused_2
        size: 2
      - id: password
        type: str
        size: 9
      - id: unused_3
        size: 1
      - id: number_of_deleted_files
        type: u1
      - id: label
        type: str
        size: 8
      - id: unused_4
        size: 3
    instances:
      number_of_tracks:
        value: "disk_type.to_i & 0x01 != 0 ? 40 : 80"
      number_of_sides:
        value: "disk_type.to_i & 0x08 != 0 ? 1 : 2"
enums:
  disk_type:
    0x16: type_80_tracks_double_side
    0x17: type_40_tracks_double_side
    0x18: type_80_tracks_single_side
    0x19: type_40_tracks_single_side
