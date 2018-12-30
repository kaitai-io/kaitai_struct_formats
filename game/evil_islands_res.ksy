meta:
  id: evil_islands_res
  title: Evil Islands, RES file (resources archive)
  application: Evil Islands
  file-extension: res
  license: MIT
  endian: le
doc: Resources archive
doc-ref: https://github.com/aspadm/EIrepack/wiki/res
seq:
  - id: magic
    contents: [0x3C, 0xE2, 0x9C, 0x01]
  - id: num_files
    type: u4
    doc: Number of files in archive
  - id: ofs_filetable
    type: u4
    doc: Filetable offset
  - id: len_nametable
    type: u4
    doc: Size of all filenames
instances:
  ofs_nametable:
    value: ofs_filetable + 22 * num_files
    doc: Offset of filenames table
  filetable:
    pos: ofs_filetable
    type: file_record
    repeat: expr
    repeat-expr: num_files
    doc: Files metadata table
types:
  file_record:
    doc: File metadata
    seq:
      - id: next_index
        type: s4
      - id: len_file
        type: u4
      - id: ofs_file
        type: u4
      - id: last_change
        type: u4
        doc: Unix timestamp of file's last change
      - id: len_name
        type: u2
      - id: ofs_name
        type: u4
        doc: Filename offset in nametable
    instances:
      name:
        io: _root._io
        pos: ofs_name + _parent.ofs_nametable
        type: str
        encoding: cp1251
        size: len_name
      data:
        io: _root._io
        pos: ofs_file
        size: len_file
        doc: Content of file
