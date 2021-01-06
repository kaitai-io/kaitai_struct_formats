meta:
  id: gran_turismo_vol
  title: Gran Turismo File System (GTFS)
  file-extension: vol
  xref:
    wikidata: Q32096599
  license: CC0-1.0
  endian: le
seq:
  - id: magic
    contents: ["GTFS", 0, 0, 0, 0]
  - id: num_files
    type: u2
  - id: num_entries
    type: u2
  - id: reserved
    contents: [0, 0, 0, 0]
  - id: offsets
    type: u4
    repeat: expr
    repeat-expr: num_files
instances:
  ofs_dir:
    value: offsets[1]
  files:
    pos: ofs_dir & 0xFFFFF800
    type: file_info
    repeat: expr
    repeat-expr: _root.num_entries
types:
  file_info:
    seq:
      - id: timestamp
        type: u4
      - id: offset_idx
        type: u2
      - id: flags
        type: u1
      - id: name
        type: str
        encoding: ASCII
        size: 25
        pad-right: 0
        terminator: 0
    instances:
      size:
        value: '(_root.offsets[offset_idx + 1] & 0xFFFFF800) - _root.offsets[offset_idx]'
      body:
        pos: _root.offsets[offset_idx] & 0xFFFFF800
        size: size
        if: not is_dir
      is_dir:
        value: 'flags & 1 != 0'
      is_last_entry:
        value: 'flags & 0x80 != 0'
