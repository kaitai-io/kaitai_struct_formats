meta:
  id: tplink_minifs
  title: TP-Link MINIFS
  license: CC0-1.0
  endian: be
  encoding: ASCII
doc: |
  MINIFS is a file system found in certain TP-Link firmware files, such as
  RE450(V4)_210531.zip, for TP-Link's own TPOS RTOS.

  It consists of a header, followed by a list of file names, followed by
  meta information for each file, meta information about the LZMA compressed
  blobs including length, offset and uncompressed length, and then a number
  of LZMA compressed blobs.

  The LZMA blobs can contain the concatenated contents of multiple files.
  The meta information of a file contains an offset to the directory name,
  a file name, the LZMA blob (numbering starts at 0), the offset of the file
  in the uncompressed data and the size of the uncompressed file.
seq:
  - id: header
    type: header
    size: 32
  - id: filenames
    type: filenames
    size: header.len_filenames
  - id: inodes
    type: 'inode(_index != 0 ? inodes[_index - 1].cur_max_lzma_blob : 0)'
    repeat: expr
    repeat-expr: header.num_files
  - id: lzma_metas
    type: 'lzma_meta(_index != 0 ? lzma_metas[_index - 1].cur_max_lzma_blob_len : 0)'
    repeat: expr
    repeat-expr: inodes.last.cur_max_lzma_blob + 1
    doc: Count starts at 0, so there is one more blob than the highest blob number
  - id: lzma_blobs_area
    size: lzma_metas.last.cur_max_lzma_blob_len
    type: dummy
instances:
  lzma_blobs:
    type: lzma_blob(_index)
    repeat: expr
    repeat-expr: _root.inodes.last.cur_max_lzma_blob + 1
    io: _root.lzma_blobs_area._io
types:
  dummy: {}
  lzma_blob:
    params:
      - id: index
        type: u4
    instances:
      data:
        pos: _root.lzma_metas[index].ofs_blob
        size: _root.lzma_metas[index].len_blob
  header:
    seq:
      - id: magic
        contents: "MINIFS\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00"
      - id: unknown_1
        type: u4
      - id: num_files
        type: u4
      - id: unknown_2
        type: u4
      - id: len_filenames
        type: u4
  filenames:
    seq:
      - id: filename
        type: strz
        repeat: eos
  inode:
    params:
      - id: prev_max_lzma_blob
        type: u4
    seq:
      - id: ofs_directory
        type: u4
      - id: ofs_name
        type: u4
      - id: lzma_blob
        type: u4
      - id: ofs_file
        type: u4
      - id: size
        type: u4
    instances:
      cur_max_lzma_blob:
        value: 'lzma_blob > prev_max_lzma_blob ? lzma_blob : prev_max_lzma_blob'
      filename:
        pos: ofs_name
        type: strz
        io: _root.filenames._io
      directory_name:
        pos: ofs_directory
        type: strz
        io: _root.filenames._io
  lzma_meta:
    params:
      - id: prev_max_lzma_blob_len
        type: u4
    seq:
      - id: ofs_blob
        type: u4
        valid: prev_max_lzma_blob_len
      - id: len_blob
        type: u4
      - id: len_blob_uncompressed
        type: u4
    instances:
      cur_max_lzma_blob_len:
        value: 'ofs_blob + len_blob > prev_max_lzma_blob_len ? ofs_blob + len_blob : prev_max_lzma_blob_len'
