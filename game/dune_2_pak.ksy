meta:
  id: dune_2_pak
  application: Dune 2 game engine
  file-extension: pak
  license: CC0-1.0
  ks-version: 0.8
  encoding: ASCII
  endian: le
seq:
  - id: dir
    size: dir_size
    type: files
instances:
  dir_size:
    pos: 0
    type: u4
types:
  files:
    seq:
      - id: files
        type: file(_index)
        repeat: eos
  file:
    params:
      - id: idx
        type: u4
    seq:
      - id: ofs
        type: u4
      - id: file_name
        type: strz
        if: ofs != 0
    instances:
      next_ofs0:
        value: _root.dir.files[idx + 1].ofs
        if: ofs != 0
      next_ofs:
        value: 'next_ofs0 == 0 ? _root._io.size : next_ofs0'
        if: ofs != 0
      body:
        io: _root._io
        pos: ofs
        size: next_ofs - ofs
        if: ofs != 0
