meta:
  id: xar
  title: XAR (eXtensible ARchive)
  file-extension:
    - xar
    - pkg
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
  From [Wikipedia](https://en.wikipedia.org/wiki/Xar_(archiver)):

  "XAR (short for eXtensible ARchive format) is an open source file archiver
  and the archiver’s file format. It was created within the OpenDarwin project
  and is used in macOS X 10.5 and up for software installation routines, as
  well as browser extensions in Safari 5.0 and up."
doc-ref: https://github.com/mackyle/xar/wiki/xarformat
seq:
  - id: header_prefix
    type: file_header_prefix
    doc: internal; access `_root.header` instead
  - id: header
    size: header_prefix.len_header - header_prefix._sizeof
    type: file_header
  - id: toc
    size: header.len_toc_compressed
    type: toc_type
    process: zlib
    doc: zlib compressed XML further describing the content of the archive
instances:
  checksum_algorithm_other:
    -orig-id: XAR_CKSUM_OTHER
    value: 3
    doc-ref: https://github.com/mackyle/xar/blob/66d451d/xar/include/xar.h.in#L85
types:
  file_header_prefix:
    seq:
      - id: magic
        contents: 'xar!'
      - id: len_header
        type: u2
        doc: internal; access `_root.header.len_header` instead
  file_header:
    seq:
      - id: version
        type: u2
        valid: 1
      - id: len_toc_compressed
        -orig-id: toc_length_compressed
        type: u8
      - id: toc_length_uncompressed
        type: u8
      - id: checksum_algorithm_int
        type: u4
        doc: internal; access `checksum_algorithm_name` instead
      - id: checksum_alg_name
        size-eos: true
        type: strz
        valid:
          expr: _ != "" and _ != "none"
        if: has_checksum_alg_name
        doc: internal; access `checksum_algorithm_name` instead
    instances:
      checksum_algorithm_name:
        value: |
          has_checksum_alg_name ? checksum_alg_name
          : checksum_algorithm_int == checksum_algorithms_apple::none.to_i ? "none"
          : checksum_algorithm_int == checksum_algorithms_apple::sha1.to_i ? "sha1"
          : checksum_algorithm_int == checksum_algorithms_apple::md5.to_i ? "md5"
          : checksum_algorithm_int == checksum_algorithms_apple::sha256.to_i ? "sha256"
          : checksum_algorithm_int == checksum_algorithms_apple::sha512.to_i ? "sha512"
          : ""
        doc: |
          If it is not

          * `""` (empty string), indicating an unknown integer value (access
            `checksum_algorithm_int` for debugging purposes to find out
            what that value is), or
          * `"none"`, indicating that the TOC checksum is not provided (in that
            case, the `<checksum>` property or its `style` attribute should be
            missing, or the `style` attribute must be set to `"none"`),

          it must exactly match the `style` attribute value of the
          `<checksum>` property in the root node `<toc>`. See
          <https://github.com/mackyle/xar/blob/66d451d/xar/lib/archive.c#L345-L371>
          for reference.

          The `xar` (eXtensible ARchiver) program [uses OpenSSL's function
          `EVP_get_digestbyname`](
            https://github.com/mackyle/xar/blob/66d451d/xar/lib/archive.c#L328
          ) to verify this value (if it's not `""` or `"none"`, of course).
          So it's reasonable to assume that this can only have one of the values
          that OpenSSL recognizes.
      has_checksum_alg_name:
        value: |
          checksum_algorithm_int == _root.checksum_algorithm_other
          and len_header >= 32
          and len_header % 4 == 0
      len_header:
        value: _root.header_prefix.len_header
  toc_type:
    seq:
      - id: xml_string
        type: str
        size-eos: true
enums:
  # https://github.com/apple-opensource/xar/blob/03d10ac/xar/include/xar.h.in#L67-L73
  checksum_algorithms_apple:
    0: none
    1: sha1
    2: md5
    3: sha256
    4: sha512
