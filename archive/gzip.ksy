meta:
  id: gzip
  file-extension: gz
  xref:
    forensicswiki: Gzip
    mime: application/gzip
    pronom: x-fmt/266
    rfc: 1952
    wikidata: Q10287816
  license: CC0-1.0
  endian: le
doc: |
  Gzip is a popular and standard single-file archiving format. It
  essentially provides a container that stores original file name,
  timestamp and a few other things (like optional comment), basic
  CRCs, etc, and a file compressed by a chosen compression algorithm.

  As of 2019, there is actually only one working solution for
  compression algorithms, so it's typically raw DEFLATE stream
  (without zlib header) in all gzipped files.
doc-ref: https://tools.ietf.org/html/rfc1952
seq:
  - id: magic
    -orig-id: ID1, ID2
    contents: [0x1f, 0x8b]
  - id: compression_method
    -orig-id: CM
    type: u1
    enum: compression_methods
    doc: |
      Compression method used to compress file body. In practice, only
      one method is widely used: 8 = deflate.
  - id: flags
    -orig-id: FLG
    type: flags
  - id: mod_time
    -orig-id: MTIME
    type: u4
    doc: Last modification time of a file archived in UNIX timestamp format.
  - id: extra_flags
    -orig-id: XFL
    type:
      switch-on: compression_method
      cases:
        'compression_methods::deflate': extra_flags_deflate
    doc: Extra flags, specific to compression method chosen.
  - id: os
    -orig-id: OS
    type: u1
    enum: oses
    doc: OS used to compress this file.
  - id: extras
    type: extras
    if: flags.has_extra
  - id: name
    terminator: 0
    if: flags.has_name
  - id: comment
    terminator: 0
    if: flags.has_comment
  - id: header_crc16
    type: u2
    if: flags.has_header_crc
  - id: body
    size: _io.size - _io.pos - 8
    doc: |
      Compressed body of a file archived. Note that we don't make an
      attempt to decompress it here.
  - id: body_crc32
    -orig-id: CRC32
    type: u4
    doc: |
      CRC32 checksum of an uncompressed file body
  - id: len_uncompressed
    -orig-id: ISIZE
    type: u4
    doc: |
      Size of original uncompressed data in bytes (truncated to 32
      bits).
enums:
  compression_methods:
    8: deflate
  oses:
    0:
      id: fat
      doc: FAT filesystem (MS-DOS, OS/2, NT/Win32)
    1:
      id: amiga
      doc: Amiga
    2:
      id: vms
      doc: VMS (or OpenVMS)
    3:
      id: unix
      doc: Unix
    4:
      id: vm_cms
      doc: VM/CMS
    5:
      id: atari_tos
      doc: Atari TOS
    6:
      id: hpfs
      doc: HPFS filesystem (OS/2, NT)
    7:
      id: macintosh
      doc: Macintosh
    8:
      id: z_system
      doc: Z-System
    9:
      id: cp_m
      doc: CP/M
    10:
      id: tops_20
      doc: TOPS-20
    11:
      id: ntfs
      doc: NTFS filesystem (NT)
    12:
      id: qdos
      doc: QDOS
    13:
      id: acorn_riscos
      doc: Acorn RISCOS
    255:
      id: unknown
types:
  flags:
    seq:
      - id: reserved1
        type: b3
      - id: has_comment
        -orig-id: FCOMMENT
        type: b1
      - id: has_name
        -orig-id: FNAME
        type: b1
      - id: has_extra
        -orig-id: FEXTRA
        type: b1
        doc: If true, optional extra fields are present in the archive.
      - id: has_header_crc
        -orig-id: FHCRC
        type: b1
        doc: |
          If true, this archive includes a CRC16 checksum for the header.
      - id: is_text
        -orig-id: FTEXT
        type: b1
        doc: |
          If true, file inside this archive is a text file from
          compressor's point of view.
  extra_flags_deflate:
    seq:
      - id: compression_strength
        type: u1
        enum: compression_strengths
    enums:
      compression_strengths:
        2: best
        4: fast
  extras:
    seq:
      - id: len_subfields
        -orig-id: XLEN
        type: u2
      - id: subfields
        size: len_subfields
        type: subfields
  subfields:
    doc: |
      Container for many subfields, constrained by size of stream.
    seq:
      - id: entries
        type: subfield
        repeat: eos
  subfield:
    doc: |
      Every subfield follows typical [TLV scheme](https://en.wikipedia.org/wiki/Type-length-value):

      * `id` serves role of "T"ype
      * `len_data` serves role of "L"ength
      * `data` serves role of "V"alue

      This way it's possible to for arbitrary parser to skip over
      subfields it does not support.
    seq:
      - id: id
        -orig-id: SI1, SI2
        type: u2
        doc: Subfield ID, typically two ASCII letters.
      - id: len_data
        type: u2
      - id: data
        size: len_data
