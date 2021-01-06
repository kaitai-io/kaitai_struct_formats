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
seq:
  - id: header
    type: cfb_header
instances:
  sector_size:
    value: '1 << header.sector_shift'
  fat:
    pos: sector_size
    size: header.size_fat * sector_size
    type: fat_entries
  dir:
    pos: (header.ofs_dir + 1) * sector_size
    type: dir_entry
types:
  cfb_header:
    seq:
      - id: signature
        contents: [0xd0, 0xcf, 0x11, 0xe0, 0xa1, 0xb1, 0x1a, 0xe1]
        doc: Magic bytes that confirm that this is a CFB file
      - id: clsid
        contents: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
        doc: Reserved class ID field, must be all 0
      - id: version_minor
        type: u2
      - id: version_major
        type: u2
      - id: byte_order
        contents: [0xfe, 0xff]
        doc: In theory, specifies a byte order. In practice, no other values besides FE FF (which imply little endian order) are used.
      - id: sector_shift
        type: u2
        doc: For major version 3, must be 0x9 (sector size = 512 bytes). For major version 4, must be 0xc (sector size = 4096 bytes).
      - id: mini_sector_shift
        type: u2
      - id: reserved1
        size: 6
      - id: size_dir
        type: s4
        doc: Number of directory sectors in this file. For major version 3, must be 0.
      - id: size_fat
        type: s4
        doc: Number of FAT sectors in this file.
      - id: ofs_dir
        type: s4
        doc: Starting sector number for directory stream.
      - id: transaction_seq
        type: s4
        doc: A transaction sequence number, which is incremented each time the file is saved if transactions are implemented, 0 otherwise.
      - id: mini_stream_cutoff_size
        type: s4
      - id: ofs_mini_fat
        type: s4
        doc: Starting sector number for mini FAT.
      - id: size_mini_fat
        type: s4
        doc: Number of mini FAT sectors in this file.
      - id: ofs_difat
        type: s4
        doc: Starting sector number for DIFAT.
      - id: size_difat
        type: s4
        doc: Number of DIFAT sectors in this file.
      - id: difat
        repeat: expr
        repeat-expr: 109
        type: s4
  fat_entries:
    seq:
      - id: entries
        type: s4
        repeat: eos
  dir_entry:
    seq:
      - id: name
        type: str
        size: 64
        encoding: UTF-16LE
      - id: name_len
        type: u2
      - id: object_type
        type: u1
        enum: obj_type
      - id: color_flag
        type: u1
        enum: rb_color
      - id: left_sibling_id
        type: s4
      - id: right_sibling_id
        type: s4
      - id: child_id
        type: s4
      - id: clsid
        size: 16
      - id: state
        type: u4
        doc: User-defined flags for storage or root storage objects
      - id: time_create
        type: u8
        doc: Creation time, in Windows FILETIME format (number of 100-nanosecond intervals since January 1, 1601, UTC)
      - id: time_mod
        type: u8
        doc: Modification time, in Windows FILETIME format (number of 100-nanosecond intervals since January 1, 1601, UTC).
      - id: ofs
        type: s4
        doc: For stream object, number of starting sector. For a root storage object, first sector of the mini stream, if the mini stream exists.
      - id: size
        type: u8
        doc: For stream object, size of user-defined data in bytes. For a root storage object, size of the mini stream.
    instances:
      mini_stream:
        io: _root._io
        pos: (ofs + 1) * _root.sector_size
        size: size
        if: object_type == obj_type::root_storage
      child:
        io: _root._io
        pos: (_root.header.ofs_dir + 1) * _root.sector_size + child_id * 0x80 # sizeof<dir_entry>
        type: dir_entry
        if: child_id != -1
      left_sibling:
        io: _root._io
        pos: (_root.header.ofs_dir + 1) * _root.sector_size + left_sibling_id * 0x80 # sizeof<dir_entry>
        type: dir_entry
        if: left_sibling_id != -1
      right_sibling:
        io: _root._io
        pos: (_root.header.ofs_dir + 1) * _root.sector_size + right_sibling_id * 0x80 # sizeof<dir_entry>
        type: dir_entry
        if: right_sibling_id != -1
    enums:
      obj_type:
        0: unknown
        1: storage
        2: stream
        5: root_storage
      rb_color:
        0: red
        1: black
