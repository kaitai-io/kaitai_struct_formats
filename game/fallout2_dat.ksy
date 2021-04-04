meta:
  id: fallout2_dat
  application: Fallout 2
  xref:
    wikidata: Q32097899
  license: CC0-1.0
  endian: le
types:
  pstr:
    seq:
      - id: size
        type: u4
      - id: str
        type: str
        size: size
        encoding: ASCII
  footer:
    seq:
      - id: index_size
        type: u4
      - id: file_size
        type: u4
  index:
    seq:
      - id: file_count
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
        type: u1
        enum: compression
      - id: size_unpacked
        type: u4
      - id: size_packed
        type: u4
      - id: offset
        type: u4
    instances:
      contents_raw:
        io: _root._io
        pos: offset
        size: size_unpacked
        if: flags == compression::none
      contents_zlib:
        io: _root._io
        pos: offset
        size: size_packed
        process: zlib
        if: flags == compression::zlib
      contents:
        value: 'flags == compression::zlib ? contents_zlib : contents_raw'
        if: flags == compression::zlib or flags == compression::none
instances:
  footer:
    pos: _io.size - 8
    type: footer
  index:
    pos: _io.size - 8 - footer.index_size
    type: index
enums:
  compression:
    0: none
    1: zlib
