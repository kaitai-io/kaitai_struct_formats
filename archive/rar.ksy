meta:
  id: rar
  title: RAR (Roshall ARchiver) archive files
  application: RAR archiver
  file-extension: rar
  xref:
    forensicswiki: RAR
    justsolve: RAR
    loc: fdd000450
    mime:
      - application/vnd.rar
      - application/x-rar-compressed
    pronom:
      - x-fmt/264 # RAR 2.0
      - fmt/411 # RAR 2.9
      - fmt/613 # RAR 5.0
    wikidata: Q243303
  license: CC0-1.0
  ks-version: 0.7
  imports:
    - /common/dos_datetime
  endian: le
doc: |
  RAR is a archive format used by popular proprietary RAR archiver,
  created by Eugene Roshal. There are two major versions of format
  (v1.5-4.0 and RAR v5+).

  File format essentially consists of a linear sequence of
  blocks. Each block has fixed header and custom body (that depends on
  block type), so it's possible to skip block even if one doesn't know
  how to process a certain block type.
doc-ref: http://acritum.com/winrar/rar-format
seq:
  - id: magic
    type: magic_signature
    doc: File format signature to validate that it is indeed a RAR archive
  - id: blocks
    type:
      switch-on: magic.version
      cases:
        0: block
        1: block_v5
    repeat: eos
    doc: Sequence of blocks that constitute the RAR file
types:
  magic_signature:
    doc: |
      RAR uses either 7-byte magic for RAR versions 1.5 to 4.0, and
      8-byte magic (and pretty different block format) for v5+. This
      type would parse and validate both versions of signature. Note
      that actually this signature is a valid RAR "block": in theory,
      one can omit signature reading at all, and read this normally,
      as a block, if exact RAR version is known (and thus it's
      possible to choose correct block format).
    seq:
      - id: magic1
        contents:
          - 'Rar!'
          - 0x1a
          - 0x07
        doc: "Fixed part of file's magic signature that doesn't change with RAR version"
      - id: version
        type: u1
        doc: |
          Variable part of magic signature: 0 means old (RAR 1.5-4.0)
          format, 1 means new (RAR 5+) format
      - id: magic3
        contents: [0]
        if: version == 1
        doc: New format (RAR 5+) magic contains extra byte
  block:
    doc: |
      Basic block that RAR files consist of. There are several block
      types (see `block_type`), which have different `body` and
      `add_body`.
    seq:
      - id: crc16
        type: u2
        doc: CRC16 of whole block or some part of it (depends on block type)
      - id: block_type
        type: u1
        enum: block_types
      - id: flags
        type: u2
      - id: block_size
        type: u2
        doc: Size of block (header + body, but without additional content)
      - id: add_size
        type: u4
        if: has_add
        doc: Size of additional content in this block
      - id: body
        size: body_size
        type:
          switch-on: block_type
          cases:
            'block_types::file_header': block_file_header
      - id: add_body
        size: add_size
        if: has_add
        doc: Additional content in this block
    instances:
      has_add:
        value: 'flags & 0x8000 != 0'
        doc: True if block has additional content attached to it
      header_size:
        value: 'has_add ? 11 : 7'
      body_size:
        value: block_size - header_size
  block_file_header:
    seq:
      - id: low_unp_size
        type: u4
        doc: Uncompressed file size (lower 32 bits, if 64-bit header flag is present)
      - id: host_os
        type: u1
        enum: oses
        doc: Operating system used for archiving
      - id: file_crc32
        type: u4
      - id: file_time
        size: 4
        type: dos_datetime
        doc: Date and time in standard MS DOS format
      - id: rar_version
        type: u1
        doc: RAR version needed to extract file (Version number is encoded as 10 * Major version + minor version.)
      - id: method
        type: u1
        enum: methods
        doc: Compression method
      - id: name_size
        type: u2
        doc: File name size
      - id: attr
        type: u4
        doc: File attributes
      - id: high_pack_size
        type: u4
        doc: Compressed file size, high 32 bits, only if 64-bit header flag is present
        if: '_parent.flags & 0x100 != 0'
      - id: file_name
        size: name_size
      - id: salt
        type: u8
        if: '_parent.flags & 0x400 != 0'
#     - id: ext_time
#       variable size
#       if: '_parent.flags & 0x1000 != 0'
  block_v5:
    {}
    # not yet implemented
enums:
  block_types:
    0x72: marker
    0x73: archive_header
    0x74: file_header
    0x75: old_style_comment_header
    0x76: old_style_authenticity_info_76
    0x77: old_style_subblock
    0x78: old_style_recovery_record
    0x79: old_style_authenticity_info_79
    0x7a: subblock
    0x7b: terminator
  oses:
    0: ms_dos
    1: os_2
    2: windows
    3: unix
    4: mac_os
    5: beos
  methods:
    0x30: store
    0x31: fastest
    0x32: fast
    0x33: normal
    0x34: good
    0x35: best
