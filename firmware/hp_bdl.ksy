meta:
  id: hp_bdl
  title: HP BDL firmware
  license: MIT
  endian: le
  encoding: UTF-8
doc-ref:
  - https://github.com/tylerwhall/hpbdl
  - https://github.com/onekey-sec/unblob/blob/1521c2f9280f35e46bd11ed97f07d41e8d522c4e/python/unblob/handlers/archive/hp/bdl.py
  - https://github.com/onekey-sec/unblob/blob/1521c2f9280f35e46bd11ed97f07d41e8d522c4e/python/unblob/handlers/archive/hp/ipkg.py
seq:
  - id: header
    type: header
types:
  header:
    seq:
      - id: magic
        contents: 'ibdl'
      - id: major
        type: u2
      - id: minor
        type: u2
      - id: ofs_toc
        type: u4
      - id: unknown
        size: 4
      - id: num_toc_entries
        type: u4
      - id: unknown_2
        size: 12
      - id: release
        size: 256
        type: strz
      - id: brand
        size: 256
        type: strz
      - id: device_id
        size: 256
        type: strz
      - id: unknown_3
        size: 9
      - id: version
        size: 256
        type: strz
      - id: revision
        size: 256
        type: strz
  toc:
    params:
      - id: num_toc_entries
        type: u4
    seq:
      - id: entries
        type: toc_entry
        repeat: expr
        repeat-expr: num_toc_entries
  toc_entry:
    seq:
      - id: ofs_entry
        type: u8
      - id: len_entry
        type: u8
    instances:
      entry:
        io: _root._io
        pos: ofs_entry
        size: len_entry
        type: ipkg
  ipkg:
    seq:
      - id: magic
        contents: 'ipkg'
      - id: major
        type: u2
      - id: minor
        type: u2
      - id: ofs_toc
        type: u4
      - id: unknown_1
        size: 4
      - id: num_toc_entries
        type: u4
      - id: unknown_2
        size: 8
      - id: reserved
        contents: [0, 0, 0, 0]
      - id: file_version
        size: 256
        type: strz
      - id: product_name
        size: 256
        type: strz
      - id: ipkg_name
        size: 256
        type: strz
      - id: signature
        size: 256
        #type: strz
    instances:
      entries:
        pos: ofs_toc
        type: entry
        repeat: expr
        repeat-expr: num_toc_entries
    types:
      entry:
        seq:
          - id: name
            size: 256
            type: strz
          - id: ofs_data
            type: u8
          - id: len_data
            type: u8
          - id: crc32
            type: u4
        instances:
          data:
            pos: ofs_data
            size: len_data
instances:
  file_offset_table:
    pos: header.ofs_toc
    type: toc(header.num_toc_entries)
