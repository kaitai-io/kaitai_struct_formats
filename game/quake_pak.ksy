meta:
  id: quake_pak
  file-extension: pak
  application: Quake game engine
  endian: le
  # https://quakewiki.org/wiki/.pak#Format_specification
seq:
  - id: magic
    contents: 'PACK'
  - id: index_ofs
    type: u4
  - id: index_size
    type: u4
instances:
  index:
    pos: index_ofs
    size: index_size
    type: index_struct
types:
  index_struct:
    seq:
      - id: entries
        type: index_entry
        repeat: eos
  index_entry:
    seq:
      - id: name
        type: str
        size: 56
        encoding: UTF-8
        terminator: 0
        pad-right: 0
      - id: ofs
        type: u4
      - id: size
        type: u4
    instances:
      body:
        pos: ofs
        size: size
        io: _root._io
