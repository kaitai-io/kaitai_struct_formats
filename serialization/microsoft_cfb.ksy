meta:
  id: microsoft_cfb
  title: Microsoft Compound File Binary (CFB), AKA OLE (Object Linking and Embedding) file format
  xref:
    justsolve: Microsoft_Compound_File
    loc:
      - fdd000380 # CFB 3
      - fdd000392 # CFB 4
    wikidata: Q5156830
  license: CC0-1.0
  endian: le
doc: |
  Due to restrictions of Kaitai Struct we cannot fully parse CFB file format. In particular,
  index of an entry in a FAT corresponds to a sector in the parsed file, while a value in that FAT entry
  corresponds to an index of the next FAT entry in a given stream. The latter means that loading of
  full user data streams or directory streams becomes cumbersome or impossible at all (when we need
  to reference FAT entries at arbitrary indices in arbitrary sectors). Instead, we load as much as
  possible leaving binding of the loaded FAT entries outside of this KSY file. Below is a list of
  parsed entities:
    * DIFAT: fully loaded (with recursive references to subsequent DIFATs);
    * FAT: fully loaded and bound to corresponding DIFAT entries;
    * MiniFAT: fully loaded (see comment for mini_fat below);
    * MiniStream: only the first sector is loaded (subsequent sectors should be loaded according to FAT
      and parts within this stream should be bound to directory entries according to MiniFAT);
    * DirectoryStream: only the first sector is loaded (subsequent sectors should be loaded according to FAT);
    * UserStreams: only the first sector for each user stream is loaded and bound to corresponding
      directory entry (subsequent sectors should be loaded according to FAT).
seq:
  - id: header
    type: header
instances:
  len_sector:
    value: '1 << header.sector_shift'
  len_mini_sector:
    value: '1 << header.mini_sector_shift'
  dirs_beginning:
    pos: (header.first_dir_sector.to_i + 1) * len_sector
    size: len_sector
    type: dir_entries_type
    doc: The first sector of the directory stream.
  mini_fat:
    pos: (header.first_mini_fat_sector.to_i + 1) * len_sector
    size: len_sector
    type: mini_fat_entries_type
    doc: |
      Since the size of the mini stream is restricted to the mini_stream_cutoff_size value (which is normally 0x1000)
      and the size of the mini stream sector is normally 0x40, then this mini_fat stream should contain at most
      0x1000 / 0x40 = 0x40 entries, which means that full Mini FAT fits into only one sector (1 sector >= 0x80 entries).
enums:
  sector_type:
    0xffffffff: free
    0xfffffffe: endofchain
    0xfffffffd: fat
    0xfffffffc: difat
    0xfffffffa: max
types:
  header:
    seq:
      - id: magic
        contents: [0xd0, 0xcf, 0x11, 0xe0, 0xa1, 0xb1, 0x1a, 0xe1]
        doc: Magic bytes that confirm that this is a CFB file
      - id: clsid
        contents: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
        doc: Reserved class ID field, must be all 0
      - id: version_minor
        type: u2
      - id: version_major
        type: u2
        enum: version_type
      - id: byte_order
        contents: [0xfe, 0xff]
        doc: In theory, specifies a byte order. In practice, no other values besides FE FF (which imply little endian order) are used.
      - id: sector_shift
        type: u2
        doc: For major version 3, must be 0x9 (sector size = 512 bytes). For major version 4, must be 0xc (sector size = 4096 bytes).
      - id: mini_sector_shift
        type: u2
        doc: This field must be 0x6 (mini sector size = 64 bytes).
      - id: reserved
        size: 6
      - id: num_dir_sectors
        type: u4
        doc: Number of directory sectors in this file. For major version 3, must be 0.
      - id: num_fat_sectors
        type: u4
        doc: Number of FAT sectors in this file.
      - id: first_dir_sector
        type: u4
        enum: sector_type
        doc: Starting sector number for directory stream.
      - id: transaction_seq
        type: u4
        doc: A transaction sequence number, which is incremented each time the file is saved if transactions are implemented, 0 otherwise.
      - id: mini_stream_cutoff_size
        type: u4
        doc: This value must be equal to 0x1000.
      - id: first_mini_fat_sector
        type: u4
        enum: sector_type
        doc: Starting sector number for mini FAT.
      - id: num_mini_fat_sectors
        type: u4
        doc: Number of mini FAT sectors in this file.
      - id: first_difat_sector
        type: difat_chain_entry_type
        doc: Starting sector number for DIFAT (outside the header sector).
      - id: num_difat_sectors
        type: u4
        doc: Number of DIFAT sectors in this file.
      - id: difat
        repeat: expr
        repeat-expr: 109
        type: difat_entry_type
    enums:
      version_type:
        3: three
        4: four
    types:
      difat_entry_type:
        seq:
          - id: sector
            type: u4
            enum: sector_type
        instances:
          fat:
            io: _root._io
            pos: (sector.to_i + 1) * _root.len_sector
            size: _root.len_sector
            type: fat_entries_type
            if: sector != sector_type::free
      difat_chain_entry_type:
        seq:
          - id: sector
            type: u4
            enum: sector_type
        instances:
          difat:
            io: _root._io
            pos: (sector.to_i + 1) * _root.len_sector
            size: _root.len_sector
            type: difat_entries_type
            if: sector != sector_type::endofchain
      difat_entries_type:
        seq:
          - id: entries
            repeat: expr
            repeat-expr: _root.len_sector / 4 - 1  # 4 - sizeof<difat_entry_type>
            type: difat_entry_type
          - id: chain_entry
            type: difat_chain_entry_type
      fat_entries_type:
        seq:
          - id: sectors
            type: u4
            enum: sector_type
            repeat: eos
  mini_fat_entries_type:
    seq:
      - id: sectors
        type: u4
        enum: sector_type
        repeat: eos
  dir_entries_type:
    seq:
      - id: dirs
        type: dir_entry_type
        repeat: eos
  dir_entry_type:
    seq:
      - id: name
        type: str
        size: 64
        encoding: UTF-16LE
      - id: name_length
        type: u2
      - id: object_type
        type: u1
        enum: object_type
      - id: color_flag
        type: u1
        enum: rb_color
      - id: left_sibling_id
        type: u4
        enum: stream_id_type
      - id: right_sibling_id
        type: u4
        enum: stream_id_type
      - id: child_id
        type: u4
        enum: stream_id_type
      - id: clsid
        size: 16
      - id: state
        type: u4
        doc: User-defined flags for storage or root storage objects
      - id: ctime
        type: u8
        doc: Creation time, in Windows FILETIME format (number of 100-nanosecond intervals since January 1, 1601, UTC)
      - id: mtime
        type: u8
        doc: Modification time, in Windows FILETIME format (number of 100-nanosecond intervals since January 1, 1601, UTC).
      - id: sector
        type: u4
        enum: sector_type
        doc: For stream object, number of starting sector. For a root storage object, first sector of the mini stream, if the mini stream exists.
      - id: size
        type: u8
        doc: For stream object, size of user-defined data in bytes. For a root storage object, size of the mini stream.
    instances:
      mini_stream:
        io: _root._io
        pos: (sector.to_i + 1) * _root.len_sector
        size: _root.len_sector
        type: mini_sectors_type
        if: object_type == object_type::root_storage and sector != sector_type::endofchain
      stream:
        io: _root._io
        pos: (sector.to_i + 1) * _root.len_sector
        size: _root.len_sector
        if: object_type == object_type::stream and size > _root.header.mini_stream_cutoff_size
    enums:
      object_type:
        0: unknown
        1: storage
        2: stream
        5: root_storage
      stream_id_type:
        0xffffffff: nostream
        0xfffffffa: max
      rb_color:
        0: red
        1: black
    types:
      mini_sectors_type:
        seq:
          - id: sectors
            type: mini_sector_type
            repeat: eos
      mini_sector_type:
        seq:
          - id: data
            size: _root.len_mini_sector
