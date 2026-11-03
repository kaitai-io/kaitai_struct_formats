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

  This Kaitai Struct implementation was written independently of the paper
  [Reverse Engineered MiniFS File System](https://arxiv.org/abs/2407.05064v1).
  It was started in the firmware analysis project
  [BANG](https://github.com/armijnhemel/binaryanalysis-ng) (Binary Analysis
  Next Generation) in
  [2021](https://github.com/armijnhemel/binaryanalysis-ng/commit/531203a076e3761116320b77b2b9c64a9dca6186)
  and submitted to the Kaitai Struct format gallery in
  [September 2023](https://github.com/kaitai-io/kaitai_struct_formats/pull/682),
  whereas the paper was published in July 2024.
doc-ref:
  - https://arxiv.org/html/2407.05064v1#S4
  - https://github.com/onekey-sec/unblob/blob/678dbce13dcabe3b4ff16b2b958d6f2cfce9ae3f/python/unblob/handlers/filesystem/minifs.py
seq:
  - id: header
    type: header
  - id: body
    type:
      switch-on: header.version
      cases:
        3: body_v3
types:
  dummy: {}
  header:
    doc-ref:
      - https://arxiv.org/html/2407.05064v1#S4.SS1
      - https://github.com/onekey-sec/unblob/blob/678dbce13dcabe3b4ff16b2b958d6f2cfce9ae3f/python/unblob/handlers/filesystem/minifs.py#L27-L34
    seq:
      - id: magic
        contents: "MINIFS\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00"
      - id: version
        type: u4
      - id: num_files
        type: u4
      - id: unknown_2
        type: u4
  body_v3:
    seq:
      - id: len_filenames
        type: u4
      - id: filenames
        size: len_filenames
        type: filenames
      - id: inodes
        type: 'inode(_index != 0 ? inodes[_index - 1].cur_max_lzma_blob : 0)'
        repeat: expr
        repeat-expr: _root.header.num_files
      - id: lzma_metas
        type: 'lzma_meta(_index != 0 ? lzma_metas[_index - 1].ofs_end : 0)'
        repeat: expr
        repeat-expr: inodes.last.cur_max_lzma_blob + 1
        doc: Count starts at 0, so there is one more blob than the highest blob number
        doc-ref: https://github.com/onekey-sec/unblob/blob/678dbce13dcabe3b4ff16b2b958d6f2cfce9ae3f/python/unblob/handlers/filesystem/minifs.py#L129-L130
      - id: lzma_blobs_area
        size: lzma_metas.last.ofs_end
        type: dummy
    instances:
      lzma_blobs:
        io: lzma_blobs_area._io
        type: lzma_blob(_index)
        repeat: expr
        repeat-expr: inodes.last.cur_max_lzma_blob + 1
  filenames:
    doc-ref: https://arxiv.org/html/2407.05064v1#S4.SS2
    seq:
      - id: filename
        type: strz
        repeat: eos
  inode:
    doc-ref:
      - https://arxiv.org/html/2407.05064v1#S4.SS3
      - https://github.com/onekey-sec/unblob/blob/678dbce13dcabe3b4ff16b2b958d6f2cfce9ae3f/python/unblob/handlers/filesystem/minifs.py#L36-L42
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
        io: _parent.filenames._io
        pos: ofs_name
        type: strz
      directory_name:
        io: _parent.filenames._io
        pos: ofs_directory
        type: strz
  lzma_meta:
    doc-ref:
      - https://arxiv.org/html/2407.05064v1#S4.SS4
      - https://github.com/onekey-sec/unblob/blob/678dbce13dcabe3b4ff16b2b958d6f2cfce9ae3f/python/unblob/handlers/filesystem/minifs.py#L44-L48
    params:
      - id: prev_ofs_end
        type: u4
    seq:
      - id: ofs_blob
        type: u4
        valid: prev_ofs_end
      - id: len_blob
        type: u4
      - id: len_blob_uncompressed
        type: u4
    instances:
      ofs_end:
        value: ofs_blob + len_blob
  lzma_blob:
    doc-ref:
      - https://arxiv.org/html/2407.05064v1#S4.SS5
      - https://github.com/onekey-sec/unblob/blob/678dbce13dcabe3b4ff16b2b958d6f2cfce9ae3f/python/unblob/handlers/filesystem/minifs.py#L175-L187
    params:
      - id: index
        type: u4
    instances:
      data:
        pos: _parent.lzma_metas[index].ofs_blob
        size: _parent.lzma_metas[index].len_blob
