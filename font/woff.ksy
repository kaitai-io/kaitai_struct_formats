meta:
  id: woff
  title: WOFF
  file-extension: woff
  license: CC0-1.0
  endian: be
doc-ref: https://www.w3.org/TR/2012/REC-WOFF-20121213/
seq:
  - id: preheader
    type: preheader
  - id: woff
    type: woff
    size: preheader.len_file - preheader._sizeof
types:
  preheader:
    seq:
      - id: signature
        contents: 'wOFF'
      - id: flavor
        type: u4
        doc: The "sfnt version" of the input font.
      - id: len_file
        type: u4
        doc: Total size of the WOFF file.
  woff:
    seq:
      - id: header
        type: header
      - id: table_directories
        type: table_directory
        repeat: expr
        repeat-expr: header.num_tables
    instances:
      extended_metadata:
        pos: header.ofs_meta
        size: header.len_meta
        io: _root._io
        if: header.len_meta != 0
      private_data:
        pos: header.ofs_private_data_block
        size: header.len_private_data_block
        io: _root._io
        if: header.len_private_data_block != 0
  header:
    seq:
      - id: num_tables
        type: u2
        doc: Number of entries in directory of font tables.
      - id: reserved
        contents: [0x00, 0x00]
      - id: total_sfnt_size
        type: u4
        doc: |
          Total size needed for the uncompressed font data, including
          the sfnt header, directory, and font tables (including padding).
      - id: major_version
        type: u2
        doc: Major version of the WOFF file.
      - id: minor_version
        type: u2
        doc: Minor version of the WOFF file.
      - id: ofs_meta
        type: u4
        valid:
          max: _root.preheader.len_file
        doc: Offset to metadata block, from beginning of WOFF file.
      - id: len_meta
        type: u4
        valid:
          max: _root.preheader.len_file - ofs_meta
        doc: Length of compressed metadata block.
      - id: meta_orig_length
        type: u4
        doc: Uncompressed size of metadata block.
      - id: ofs_private_data_block
        type: u4
        valid:
          max: _root.preheader.len_file
        doc: Offset to private data block, from beginning of WOFF file.
      - id: len_private_data_block
        type: u4
        valid:
          max: _root.preheader.len_file - ofs_private_data_block
        doc: Length of private data block.
  table_directory:
    seq:
      - id: tag
        type: u4
        doc: 4-byte sfnt table identifier.
      - id: ofs_data
        type: u4
        doc: Offset to the data, from beginning of WOFF file.
      - id: len_data
        type: u4
        doc: Length of the compressed data, excluding padding.
      - id: len_uncompressed_data
        type: u4
        doc: Length of the uncompressed table, excluding padding.
      - id: checksum
        type: u4
        doc: Checksum of the uncompressed table.
    instances:
      data:
        pos: ofs_data
        type: table_data(len_data)
        io: _root._io
  table_data:
    params:
      - id: len_data
        type: u4
    seq:
      - id: data
        size: len_data
      - id: padding
        size: (-len_data % 4)
