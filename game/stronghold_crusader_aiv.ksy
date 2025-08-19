meta:
  id: aiv
  title: AI Village
  application:
    - Stronghold Crusader
    - Stronghold Crusader Extreme
    - Village
  file-extension: aiv
  license: CC0-1.0
  endian: le
doc: |
  The structure of the Stronghold Crusader AI Village file format is similar to
  the one of the map file format. It consists of a directory, specifying
  properties of the following data sections. Some sections are compressed using
  blast compression, an implementation of which can be found at
  https://github.com/ladislav-zezula/StormLib/tree/master/src/pklib.
seq:
  - id: dir
    type: dir
  - id: x_view
    type: u4
  - id: y_view
    type: u4
  - id: random
    size: 40016
  - id: bmap_size
    type: compr_sec
  - id: bmap_tile
    type: compr_sec
  - id: tmap
    type: compr_sec
  - id: gmap
    size: 10000
  - id: bmap_id
    type: compr_sec
  - id: bmap_step
    type: compr_sec
  - id: step_cur
    type: u4
  - id: step_tot
    type: u4
  - id: parr
    type: s4
    repeat: expr
    repeat-expr: _root.dir.uncompr_size[11]/4 # always 10 or 50
  - id: tarr
    type: u4
    repeat: expr
    repeat-expr: 240
  - id: pause
    type: u4
types:
  dir:  # directory
    seq:
      - id: size    # always 2036
        type: u4
      - id: fswd    # file size without directory
        type: u4
      - id: sec_cnt # always 14
        type: u4
      - id: version # always 200
        type: u4
      - id: padding0
        contents: [0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
                    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00]
      - id: uncompr_size
        type: u4
        repeat: expr
        repeat-expr: 100
      - id: compr_size
        type: u4
        repeat: expr
        repeat-expr: 100
      - id: id
        type: u4
        repeat: expr
        repeat-expr: 100
      - id: is_compr
        type: u4
        repeat: expr
        repeat-expr: 100
      - id: offset
        type: u4
        repeat: expr
        repeat-expr: 100
      - id: padding1
        contents: [0x00, 0x00, 0x00, 0x00]
  uncompr_sec:  # uncompressed section
    params:
      - id: i
        type: u4
    seq:
      - id: data
        size: _root.dir.uncompr_size[i]
  compr_sec:    # compressed section
    seq:
      - id: uncompr_size
        type: u4
      - id: compr_size
        type: u4
      - id: crc32
        type: u4
      - id: data
        size: compr_size