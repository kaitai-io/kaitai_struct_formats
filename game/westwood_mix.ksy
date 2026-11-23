meta:
  id: westwood_mix
  application: Red Alert
  file-extension: mix
  license: CC0-1.0
  encoding: ASCII
  endian: le
doc-ref: https://moddingwiki.shikadi.net/wiki/MIX_Format_(Westwood)
seq:
  - id: magic
    type: u4
    valid: 0x00
    doc: without encryption
  - id: num_file_entries
    type: u2
  - id: data_size
    type: u4
  - id: file_entries
    type: file_entry
    repeat: expr
    repeat-expr: num_file_entries

types:
  file_entry:
    seq:
      - id: id
        type: u4
      - id: offset
        type: u4
      - id: size
        type: u4
