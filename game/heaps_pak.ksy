meta:
  id: heaps_pak
  application: Games based on Haxe Game Framework "Heaps" (e.g. Dead Cells)
  file-extension: pak
  license: MIT
  encoding: UTF-8
  endian: le
doc-ref: 'https://github.com/HeapsIO/heaps/blob/2bbc2b386952dfd8856c04a854bb706a52cb4b58/hxd/fmt/pak/Reader.hx'
seq:
  - id: header
    type: header
types:
  header:
    seq:
      - id: magic1
        contents: 'PAK'
      - id: version
        type: u1
      - id: len_header
        type: u4
      - id: len_data
        type: u4
      - id: root_entry
        type: entry
        size: len_header - 16
      - id: magic2
        contents: 'DATA'
    types:
      entry:
        doc-ref: 'https://github.com/HeapsIO/heaps/blob/2bbc2b386952dfd8856c04a854bb706a52cb4b58/hxd/fmt/pak/Data.hx'
        seq:
          - id: len_name
            type: u1
          - id: name
            type: str
            size: len_name
          - id: flags
            type: flags
          - id: body
            type:
              switch-on: flags.is_dir
              cases:
                true : dir
                false : file
        types:
          flags:
            seq:
              - id: unused
                type: b7
              - id: is_dir
                type: b1
      file:
        seq:
          - id: ofs_data
            type: u4
          - id: len_data
            type: u4
          # Adler32 checksum
          - id: checksum
            size: 4
        instances:
          data:
            io: _root._io
            pos: _root.header.len_header + ofs_data
            size: len_data
      dir:
        seq:
          - id: num_entries
            type: u4
          - id: entries
            type: entry
            repeat: expr
            repeat-expr: num_entries
