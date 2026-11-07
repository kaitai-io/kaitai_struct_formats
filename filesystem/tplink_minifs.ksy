meta:
  id: tplink_minifs
  title: TP-Link MiniFS
  license: CC0-1.0
  encoding: ASCII
  endian: be
doc: |
  MiniFS is a file system found in certain firmware files from TP-Link
  (including its Mercusys brand) and Mercury. Such firmware contains an RTOS
  kernel, e.g. VxWorks in
  [`RE450(V4)_210531.zip`](https://static.tp-link.com/firmware/2021/202107/20210709/RE450(V4)_210531.zip)
  ([archived](https://web.archive.org/web/20261105175157/https://static.tp-link.com/firmware/2021/202107/20210709/RE450(V4)_210531.zip))
  or TPOS, TP-Link's RTOS, in
  [`TL-WA850RE(EU)_V7.0_250808.zip`](https://static.tp-link.com/upload/firmware/2025/202509/20250919/TL-WA850RE(EU)_V7.0_250808.zip)
  ([archived](https://web.archive.org/web/20260903180047/https://static.tp-link.com/upload/firmware/2025/202509/20250919/TL-WA850RE(EU)_V7.0_250808.zip)).

  According to a TP-Link manager quoted in a
  [2021 article](https://shiftdelete.net/tp-link-mercusys-ile-ilgili-hedeflerini-paylasti)
  ([archived](https://web.archive.org/web/20230513175833/https://shiftdelete.net/tp-link-mercusys-ile-ilgili-hedeflerini-paylasti)),
  Mercusys has been sold in China as Mercury since 2001. All Mercury images
  examined contain a certificate with `O=tplink` in its issuer and subject.

  All versions share the same header, and its `version` field determines the
  layout of the rest of the image.

  In version 3, the header is followed by a table of directory paths and file
  names, followed by meta information for each file, meta information about
  the LZMA compressed blobs including length, offset and uncompressed length,
  and then a number of LZMA compressed blobs.

  The LZMA blobs can contain the concatenated contents of multiple files.
  The meta information of a file contains the offsets of its directory path
  and file name, the LZMA blob (numbering starts at 0), the offset of the file
  in the uncompressed data and the size of the uncompressed file.

  Some version 3 images have no uncompressed length in the meta information
  about the blobs (see `has_8_byte_lzma_metas` in `body_v3`).

  In version 2, the header is followed by the length of the files area and a
  meta information record for each file, each followed directly by the file's
  data. Unlike versions 1 and 3, version 2 stores no paths or file names at
  all, only the MD5 hash of each file's path.

  In version 1, the header is followed by a record with the path, the compressed
  length and the offset of each file, and then one LZMA blob per file.

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
  - https://arxiv.org/html/2407.05064v1#S4 The paper, section 4 (version 3)
  - https://github.com/zh-explorer/tp_research/blob/a42f9d0427ad0c453a7060f3236c4174bb883441/Minifs.py tp_research's `Minifs.py` (version 2)
  - https://github.com/onekey-sec/unblob/blob/678dbce13dcabe3b4ff16b2b958d6f2cfce9ae3f/python/unblob/handlers/filesystem/minifs.py unblob's MiniFS handler (version 3)
seq:
  - id: header
    type: minifs_header
    -affected-by: 86
  - id: body
    type:
      switch-on: header.version
      cases:
        1: body_v1
        2: body_v2
        3: body_v3
types:
  dummy: {}
  minifs_header:
    doc-ref:
      - https://arxiv.org/html/2407.05064v1#S4.SS1
      - https://github.com/onekey-sec/unblob/blob/678dbce13dcabe3b4ff16b2b958d6f2cfce9ae3f/python/unblob/handlers/filesystem/minifs.py#L27-L34
    -webide-representation: 'version {version:dec}, {num_files:dec} files'
    seq:
      - id: magic
        contents: "MINIFS\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00"
      - id: version
        type: u4
        valid:
          any-of:
            - 1
            - 2
            # https://github.com/onekey-sec/unblob/blob/678dbce13dcabe3b4ff16b2b958d6f2cfce9ae3f/python/unblob/handlers/filesystem/minifs.py#L192-L194
            - 3
      - id: num_files
        type: u4
      - id: len_largest_file
        type: u4
        doc: |
          The uncompressed size of the largest file. In all images examined with
          version 3, the inodes are sorted by size in descending order, so it is
          also the size of the first file. In all images examined with versions
          1 and 2, the value is rounded up to a multiple of 4.
  body_v1:
    doc-ref: https://arxiv.org/html/2407.05064v1#S2.SS2
    seq:
      - id: inodes
        type: 'inode_v1((_index != 0 ? inodes[_index - 1].ofs_end : 0).as<u4>)'
        -affected-by: 1333
        repeat: expr
        repeat-expr: _root.header.num_files
      - id: blobs_area
        size: inodes.last.ofs_end
        type: dummy
  inode_v1:
    -webide-representation: '{path} ({len_blob:dec} bytes compressed)'
    params:
      - id: prev_ofs_end
        type: u4
    seq:
      - id: path
        size: 80
        type: strz
      - id: len_blob
        type: u4
      - id: ofs_blob
        type: u4
        valid: prev_ofs_end
        doc: Relative to the start of `<body_v1>.blobs_area`.
    instances:
      ofs_end:
        value: ofs_blob + len_blob
      blob:
        io: _parent.blobs_area._io
        pos: ofs_blob
        size: len_blob
        doc: |
          An LZMA stream in the `.lzma` format (also known as LZMA_Alone) with
          the contents of the file. Decompress it in the same way as
          `<lzma_meta>.blob`.

          In all images examined, the `.lzma` header specifies the properties
          lc = 0, lp = 0, pb = 2 and an 8 MiB dictionary, so it starts with the
          bytes `5A 00 00 80 00`. It also specifies the uncompressed size of the
          stream, and there is no end-of-payload marker.
  body_v2:
    seq:
      - id: len_files_area
        type: u4
      - id: files_area
        size: len_files_area
        type: files_area_v2
  files_area_v2:
    seq:
      - id: files
        type: file_v2
        repeat: expr
        repeat-expr: _root.header.num_files
  file_v2:
    doc-ref: https://github.com/zh-explorer/tp_research/blob/a42f9d0427ad0c453a7060f3236c4174bb883441/Minifs.py#L41-L52
    -webide-representation: '{len_data_uncompressed:dec} bytes, {compression}'
    seq:
      - id: path_md5
        size: 16
        doc: |
          The MD5 hash of the absolute path of the file, e.g. of
          `/conf/priv-key.pem`.

          Version 2 images store only these hashes, not the paths, so a path can
          only be found by hashing candidate paths and comparing.
          [`Minifs.py`](https://github.com/zh-explorer/tp_research/blob/a42f9d0427ad0c453a7060f3236c4174bb883441/Minifs.py#L181-L209)
          takes the candidates from path-like strings in the files' contents.
      - id: len_data
        type: u4
      - id: ofs_data
        type: u4
        # `data` follows `len_data_uncompressed` and `compression` (8 bytes)
        valid: _io.pos + 8
        doc: Offset of `data` relative to the start of `<body_v2>.files_area`.
      - id: len_data_uncompressed
        type: u4
      - id: compression
        type: u4
        enum: compression_type
      - id: data
        size: len_data
        doc: |
          With `compression_type::lzma`, an LZMA stream in the `.lzma` format
          (also known as LZMA_Alone). Decompress it in the same way as
          `<lzma_meta>.blob`.

          In all images examined, the `.lzma` header specifies the properties
          lc = 0, lp = 0, pb = 2 and an 8 MiB dictionary, so it starts with the
          bytes `5A 00 00 80 00`. It also specifies the uncompressed size of the
          stream, and there is no end-of-payload marker.
  body_v3:
    -webide-representation: '{num_lzma_blobs:dec} blobs, {len_lzma_meta:dec}-byte records'
    seq:
      - id: len_name_table
        type: u4
      - id: name_table
        size: len_name_table
        type: name_table
      - id: inodes
        type: 'inode((_index != 0 ? inodes[_index - 1].cur_max_lzma_blob : 0).as<u4>)'
        -affected-by: 1333
        repeat: expr
        repeat-expr: _root.header.num_files
      - size: 0
        if: ofs_lzma_metas < 0
      - id: lzma_metas
        type: 'lzma_meta((_index != 0 ? lzma_metas[_index - 1].ofs_end : 0).as<u4>)'
        -affected-by: 1333
        repeat: expr
        repeat-expr: num_lzma_blobs
      - id: lzma_blobs_area
        size: lzma_metas.last.ofs_end
        type: dummy
    instances:
      ofs_lzma_metas:
        value: _io.pos
      num_lzma_blobs:
        value: inodes.last.cur_max_lzma_blob + 1
        doc: Count starts at 0, so there is one more blob than the highest blob number
        doc-ref: https://github.com/onekey-sec/unblob/blob/678dbce13dcabe3b4ff16b2b958d6f2cfce9ae3f/python/unblob/handlers/filesystem/minifs.py#L129-L130
      len_lzma_meta:
        value: 'has_8_byte_lzma_metas ? 8 : 12'
        doc: The size of each record in `lzma_metas` (8 or 12 bytes).
      has_8_byte_lzma_metas:
        value: len_first_blob_uncompressed_if_8_byte_metas == 0xffff_ffff_ffff_ffff
        doc: |
          Whether each record in `lzma_metas` lacks `len_blob_uncompressed` and
          is therefore 8 bytes in size instead of 12.

          The MiniFS header doesn't say which size is used (both use version 3),
          so this Kaitai Struct implementation infers it using a heuristic based
          on the `.lzma` header of the first blob. Bytes 5 to 12 of that header
          are the uncompressed size, which was unknown (all bits set) for all
          blobs in all version 3 images examined. So with 8-byte records,
          `len_first_blob_uncompressed_if_8_byte_metas` has all bits set. With
          12-byte records, the same 8 bytes aren't the uncompressed size. With 3
          or more blobs, they include a whole offset or length in `lzma_metas`,
          which would have to be 4 GiB. With 1 or 2 blobs, they include the
          first blob's dictionary size, which is 8 MiB in all images examined.

          An image with 8-byte records and a known uncompressed size would be
          rejected, or misparsed if it has a single blob and other data follows it.

          In the images examined, 8-byte records occur in firmware files with
          modification times from 2018 to 2022 (as stored in their ZIPs), e.g. in
          [`MW301R(EU)_V2_180821.zip`](https://static.mercusys.com/software/MW301R(EU)_V2_180821.zip)
          ([archived](https://web.archive.org/web/20261105093950/https://static.mercusys.com/software/MW301R(EU)_V2_180821.zip)),
          listed on <https://www.mercusys.com/en/download/mw301r/v2/>
          ([archived](https://web.archive.org/web/20261105142659/https://www.mercusys.com/en/download/mw301r/v2/)).

          As far as we know, this implementation is the first description of
          8-byte records. The other descriptions and tools found either assume
          12 bytes or don't read `lzma_metas` at all. So there is no reference
          to compare it with, and the evidence comes from the images. In all 49
          distinct images examined with 8-byte records, the bytes at each
          record's offset and length are exactly one complete LZMA stream. Each
          such stream decompresses to exactly the length that the files packed
          into it need. The file that ends last in it ends exactly where the
          decompressed data ends. In addition:

          * 2614 of the 7230 files in these 49 images have the same path and
            contents as a file in an image with 12-byte records. For example,
            49 files are the same in the image with 8-byte records in
            [`TL-WA850RE(EU)_V7_201029.zip`](https://static.tp-link.com/2021/202102/20210209/TL-WA850RE(EU)_V7_201029.zip)
            ([archived](https://web.archive.org/web/20220326032207/https://static.tp-link.com/2021/202102/20210209/TL-WA850RE(EU)_V7_201029.zip))
            and the image with 12-byte records in
            [`TL-WA850RE(EU)_V7.0_250808.zip`](https://static.tp-link.com/upload/firmware/2025/202509/20250919/TL-WA850RE(EU)_V7.0_250808.zip)
            ([archived](https://web.archive.org/web/20260903180047/https://static.tp-link.com/upload/firmware/2025/202509/20250919/TL-WA850RE(EU)_V7.0_250808.zip)).
          * The repository
            [NurMohammadDuari/mw325r-hack-lab](https://github.com/NurMohammadDuari/mw325r-hack-lab/tree/024da680dbf4f9ca287d562622f02d7d8875bd45)
            has the [files](https://github.com/NurMohammadDuari/mw325r-hack-lab/tree/024da680dbf4f9ca287d562622f02d7d8875bd45/extracted-minifs)
            of the image with 8-byte records in
            [`MW325R(EU)_V2_20111620201211065426.zip`](https://static.mercusys.com/software/MW325R(EU)_V2_20111620201211065426.zip)
            ([archived](https://web.archive.org/web/20261105093427/https://static.mercusys.com/software/MW325R(EU)_V2_20111620201211065426.zip)).
            They match the files parsed by this implementation in all 92 files
            that can be compared. Its
            [extractor](https://github.com/NurMohammadDuari/mw325r-hack-lab/blob/024da680dbf4f9ca287d562622f02d7d8875bd45/analysis/minifs_extract.py)
            finds the blobs by searching for LZMA headers instead of reading
            `lzma_metas`.
      len_first_blob_uncompressed_if_8_byte_metas:
        pos: ofs_lzma_metas + 8 * num_lzma_blobs + 5
        type: u8le
        doc: |
          The uncompressed size in the `.lzma` header of the first blob, if
          `lzma_metas` have 8-byte records. It follows the properties byte and the
          4-byte dictionary size.
  lzma_meta:
    doc-ref:
      - https://arxiv.org/html/2407.05064v1#S4.SS4
      - https://github.com/onekey-sec/unblob/blob/678dbce13dcabe3b4ff16b2b958d6f2cfce9ae3f/python/unblob/handlers/filesystem/minifs.py#L44-L48
    -webide-representation: '{len_blob:dec} bytes at {ofs_blob}'
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
        if: not _parent.has_8_byte_lzma_metas
    instances:
      ofs_end:
        value: ofs_blob + len_blob
      blob:
        io: _parent.lzma_blobs_area._io
        pos: ofs_blob
        size: len_blob
        doc: |
          An LZMA stream in the `.lzma` format (also known as LZMA_Alone):
          a 13-byte header followed by the compressed data. Decompress it
          with a ready-made LZMA decoder that reads this header, e.g. in
          Python with `lzma.decompress(blob, format=lzma.FORMAT_ALONE)`. The
          size of the decompressed data is `len_blob_uncompressed`, if present.

          In all images examined with `header.version` = 3, the `.lzma` header
          specifies the properties lc = 3, lp = 0, pb = 2 and an 8 MiB
          dictionary, so it starts with the bytes `5D 00 00 80 00`. The
          uncompressed size in the header is unknown (`0xFFFF_FFFF_FFFF_FFFF`),
          so the stream ends with an end-of-payload marker.
        doc-ref:
          - https://arxiv.org/html/2407.05064v1#S4.SS5
          - https://github.com/onekey-sec/unblob/blob/678dbce13dcabe3b4ff16b2b958d6f2cfce9ae3f/python/unblob/handlers/filesystem/minifs.py#L175-L187
  name_table:
    doc: |
      Table of null-terminated directory paths and file names, referenced by
      `<inode>.ofs_directory_path` and `<inode>.ofs_file_name`. In all images
      examined, each non-empty string occurs only once, which saves space in
      flash memory, as many files share a directory or a name.

      In all images examined, the table is padded with null bytes to a multiple
      of 4 bytes, so `names` can end with up to 3 empty strings (one for each
      padding byte).
    doc-ref: https://arxiv.org/html/2407.05064v1#S4.SS2
    seq:
      - id: names
        type: strz
        repeat: eos
  inode:
    doc-ref:
      - https://arxiv.org/html/2407.05064v1#S4.SS3
      - https://github.com/onekey-sec/unblob/blob/678dbce13dcabe3b4ff16b2b958d6f2cfce9ae3f/python/unblob/handlers/filesystem/minifs.py#L36-L42
    -webide-representation: '/{directory_path}/{file_name} ({len_file:dec} bytes, blob {lzma_blob:dec})'
    params:
      - id: prev_max_lzma_blob
        type: u4
    seq:
      - id: ofs_directory_path
        type: u4
      - id: ofs_file_name
        type: u4
      - id: lzma_blob
        type: u4
      - id: ofs_file
        type: u4
      - id: len_file
        type: u4
    instances:
      cur_max_lzma_blob:
        value: 'lzma_blob > prev_max_lzma_blob ? lzma_blob : prev_max_lzma_blob'
      file_name:
        io: _parent.name_table._io
        pos: ofs_file_name
        type: strz
        -webide-parse-mode: eager
      directory_path:
        io: _parent.name_table._io
        pos: ofs_directory_path
        type: strz
        -webide-parse-mode: eager
enums:
  # https://github.com/zh-explorer/tp_research/blob/a42f9d0427ad0c453a7060f3236c4174bb883441/Minifs.py#L31
  compression_type:
    0:
      id: lzma
      doc: The only value in all images examined.
    2:
      id: raw
    4:
      id: lzma_2014
