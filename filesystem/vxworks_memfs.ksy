meta:
  id: vxworks_memfs
  title: VxWorks memfs
  license: MIT
  endian: be
  encoding: UTF-8
doc-ref:
  - https://blog.quarkslab.com/reverse-engineering-a-vxworks-os-based-router.html
  - https://web.archive.org/web/20110831171246/devttys0.com/2011/06/mystery-file-system
seq:
  - id: header
    type: header
  - id: entries
    type: entry
    repeat: expr
    repeat-expr: header.num_files
types:
  header:
    seq:
      - id: magic
        contents: "owowowowowowowowowowowowowowowow"
        size: 32
      - id: version
        type: u4
        valid: 1
      - id: num_files
        type: u4
      - id: data_2
        size: 4
  entry:
    seq:
      - id: name
        size: 40
        type: strz
      - id: len_data
        type: u4
      - id: ofs_data
        type: u4
    instances:
      data:
        io: _root._io
        pos: ofs_data
        size: len_data
