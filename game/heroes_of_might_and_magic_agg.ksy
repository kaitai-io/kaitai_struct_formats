meta:
  id: heroes_of_might_and_magic_agg
  application: Heroes of Might and Magic
  file-extension: agg
  license: CC0-1.0
  endian: le
doc-ref: http://rewiki.regengedanken.de/wiki/.AGG_(Heroes_of_Might_and_Magic)
seq:
  - id: num_files
    type: u2
  - id: entries
    type: entry
    repeat: expr
    repeat-expr: num_files
types:
  entry:
    seq:
      - id: hash
        type: u2
      - id: offset
        type: u4
      - id: size
        type: u4
      - id: size2
        type: u4
    instances:
      body:
        pos: offset
        size: size
  filename:
    seq:
      - id: str
        type: strz
        encoding: ASCII
instances:
  filenames:
    pos: entries.last.offset + entries.last.size
    type: filename
    size: 15
    repeat: expr
    repeat-expr: num_files
