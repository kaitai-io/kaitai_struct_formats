meta:
  id: ftl_dat
  application: Faster Than Light (FTL)
  file-extension: dat
  license: CC0-1.0
  endian: le
seq:
  - id: num_files
    type: u4
    doc: Number of files in the archive
  - id: files
    type: file
    repeat: expr
    repeat-expr: num_files
types:
  file:
    seq:
      - id: ofs_meta
        type: u4
    instances:
      meta:
        pos: ofs_meta
        type: meta
        if: ofs_meta != 0
  meta:
    seq:
      - id: len_file
        type: u4
      - id: len_filename
        type: u4
      - id: filename
        type: str
        size: len_filename
        encoding: UTF-8
      - id: body
        size: len_file
