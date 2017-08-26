meta:
  id: fallout_dat
  endian: be
  application: Fallout
  license: CC0-1.0
seq:
  - id: folder_count
    type: u4
  - id: unknown1
    type: u4
  - id: unknown2
    type: u4
  - id: timestamp
    type: u4
  - id: folder_names
    type: pstr
    repeat: expr
    repeat-expr: folder_count
  - id: folders
    type: folder
    repeat: expr
    repeat-expr: folder_count
types:
  pstr:
    seq:
      - id: size
        type: u1
      - id: str
        type: str
        size: size
        encoding: ASCII
  folder:
    seq:
      - id: file_count
        type: u4
      - id: unknown
        type: u4
      - id: flags
        type: u4
      - id: timestamp
        type: u4
      - id: files
        type: file
        repeat: expr
        repeat-expr: file_count
  file:
    seq:
      - id: name
        type: pstr
      - id: flags
        type: u4
        enum: compression
      - id: offset
        type: u4
      - id: size_unpacked
        type: u4
      - id: size_packed
        type: u4
    instances:
      contents:
        io: _root._io
        pos: offset
        size: "(flags == compression::none) ? size_unpacked : size_packed"
enums:
  compression:
    32: none
    64: lzss
