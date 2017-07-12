meta:
  id: saints_row_2_vpp_pc
  endian: le
  encoding: UTF-8
  license: MIT
  title: Saints Rows 2 game packages
  file-extension: vpp_pc
seq:
  - id: magic
    contents: [0xce, 0x0a, 0x89, 0x51, 0x04]
  - id: pad1
    size: 0x14f
  - id: num_files
    type: s4
  - id: container_size
    type: s4
  - id: len_offsets
    type: s4
  - id: len_filenames
    type: s4
  - id: len_extensions
    type: s4
  - id: smth5
    type: s4
  - id: smth6
    type: s4
  - id: smth7
    type: s4
  - id: smth8
    type: s4
  - id: smth9
    type: s4
instances:
  files:
    pos: 0x800
    size: len_offsets
    type: offsets
  ofs_filenames:
    value: ((0x800 + len_offsets) & 0xfffff800) + 0x800
  filenames:
    pos: ofs_filenames
    size: len_filenames
    type: strings
  ofs_extensions:
    value: ((ofs_filenames + len_filenames) & 0xfffff800) + 0x800
  extensions:
    pos: ofs_extensions
    size: len_extensions
    type: strings
  data_start:
    value: ((ofs_extensions + len_extensions) & 0xfffff800) + 0x800
types:
  offsets:
    seq:
      - id: entries
        type: offset
        repeat: eos
    types:
      offset:
        seq:
          - id: name_ofs
            type: u4
          - id: ext_ofs
            type: u4
          - id: smth2
            type: s4
          - id: ofs_body
            type: s4
          - id: len_body
            type: s4
          - id: always_minus_1
            type: s4
          - id: always_zero
            type: s4
        instances:
          filename:
            pos: name_ofs
            io: _root.filenames._io
            type: strz
          ext:
            pos: ext_ofs
            io: _root.extensions._io
            type: strz
          body:
            pos: _root.data_start + ofs_body
            io: _root._io
            size: len_body
  strings:
    seq:
      - id: entries
        type: strz
        repeat: eos
