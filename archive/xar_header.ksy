meta:
  id: xar_header
  title: eXtensible ARchiver
  file-extension:
    - pkg
    - xar
    - xip
  xref:
    mime: application/x-xar
    pronom: fmt/600
    wikidata: Q1093556
  license: CC0-1.0
  ks-version: 0.9
  endian: be
doc-ref: https://github.com/mackyle/xar/wiki/xarformat
seq:
  - id: magic
    contents: 'xar!'
  - id: header_size
    type: u2
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
  - id: toc
    size: len_toc_compressed
    process: zlib
    doc: zlib compressed XML further describing the content of the archive
enums:
  checksum_algorithms:
    0: none
    1: sha1
    2: md5
