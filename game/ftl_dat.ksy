meta:
  id: ftl_dat
  endian: le
  application: Faster Than Light (FTL)
  file-extension: dat
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
      - id: meta_ofs
        type: u4
    instances:
      meta:
        pos: meta_ofs
        type: meta
        if: meta_ofs != 0
  meta:
    seq:
      - id: file_size
        type: u4
      - id: filename_size
        type: u4
      - id: filename
        type: str
        size: filename_size
        encoding: UTF-8
      - id: body
        size: file_size
