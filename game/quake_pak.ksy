meta:
  id: quake_pak
  application: Quake game engine
  file-extension: pak
  license: CC0-1.0
  endian: le
doc-ref: 'https://quakewiki.org/wiki/.pak#Format_specification'
seq:
  - id: magic
    contents: 'PACK'
  - id: ofs_index
    type: u4
  - id: len_index
    type: u4
instances:
  index:
    pos: ofs_index
    size: len_index
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
        io: _root._io
        pos: ofs
        size: size
