meta:
  id: xar
  title: eXtensible ARchiver
  file-extension:
    - pkg
    - xar
    - xip
  xref:
    justsolve: Xar_(Extensible_Archive)
    mime: application/x-xar
    pronom: fmt/600
    wikidata: Q1093556
  license: CC0-1.0
  ks-version: 0.9
  encoding: UTF-8
  endian: be
doc: |
  From Wikipedia:

  "XAR (short for eXtensible ARchive format) is an open source file archiver
  and the archiver’s file format. It was created within the OpenDarwin project
  and is used in macOS X 10.5 and up for software installation routines, as
  well as browser extensions in Safari 5.0 and up."

  It should be noted that there is a different version from Apple uses the
  same version number as the (unmaintained) version described here, but that
  supports additional checksums, but doesn't have checksum_name.
doc-ref: https://github.com/mackyle/xar/wiki/xarformat
seq:
  - id: magic
    contents: 'xar!'
  - id: len_header
    type: u2
  - id: header
    type:
      switch-on: len_header
      cases:
        28: apple_header
        _: regular_header
types:
  regular_header:
    seq:
      - id: version
        type: u2
        valid: 1
      - id: len_toc_compressed
        -orig-id: toc_length_compressed
        type: u8
      - id: toc_length_uncompressed
        type: u8
      - id: checksum_algorithm
        type: u4
        enum: checksum_algorithms
      - id: checksum_name
        type: strz
        size: 36
        if: checksum_algorithm == checksum_algorithms::other
      - id: toc
        size: len_toc_compressed
        process: zlib
        doc: zlib compressed XML further describing the content of the archive
  apple_header:
    seq:
      - id: version
        type: u2
        valid: 1
      - id: len_toc_compressed
        -orig-id: toc_length_compressed
        type: u8
      - id: toc_length_uncompressed
        type: u8
      - id: checksum_algorithm
        type: u4
        enum: checksum_algorithms_apple
      - id: toc
        size: len_toc_compressed
        process: zlib
        doc: zlib compressed XML further describing the content of the archive
enums:
  checksum_algorithms:
    0: none
    1: sha1
    2: md5
    3: other
  checksum_algorithms_apple:
    0: none
    1: sha1
    2: md5
    3: sha256
    4: sha512
