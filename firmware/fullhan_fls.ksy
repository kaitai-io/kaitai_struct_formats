meta:
  id: fullhan_fls
  title: Fullhan FLS
  license: CC0-1.0
  endian: le
  encoding: UTF-8
doc: |
  Test files:
  - https://www.nvripc.com/new-chinese-ip-camera-firmwares-update/
  - https://www.herospeed.net/hs/ipc_test/fuhan/
seq:
  - id: header
    type: header
  - id: entries
    type: entry
    repeat: expr
    repeat-expr: header.num_entries
  - id: data
    size: header.len_file - ofs_data
    type: dummy
instances:
  ofs_data:
    value: header._sizeof + header.num_entries * sizeof<entry>
types:
  dummy: {}
  header:
    seq:
      - id: model
        size: 8
        type: strz
      - id: submodel
        size: 8
        type: strz
      - id: len_file
        type: u4
      - id: num_entries
        type: u4
  entry:
    seq:
      - id: name
        size: 128
        type: strz
      - id: len_data
        type: u4
      - id: ofs_data
        type: u4
      - id: unknown
        size: 120
    instances:
      data:
        io: _root.data._io
        pos: ofs_data - _root.ofs_data
        size: len_data
