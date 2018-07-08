meta:
  id: cso
  title: Compressed ISO
  application:
    - PSP
    - maxcso
  file-extension:
    - cso
    - zso
  xref:
    mime: application/x-compressed-iso
    wikidata: Q2347127
  endian: le
  encoding: ascii
  license: ISC

doc: |
  The original CSO format was created by BOOSTER.
  This document includes an experimental v2 format of CSO, proposed by Unknown W. Brackets.
  A CSO file consists of a file header, index section, and data section.
doc-ref:
  - "https://github.com/unknownbrackets/maxcso/blob/master/README_CSO.md"
  - "https://github.com/unknownbrackets/maxcso/blob/master/README_ZSO.md"
seq:
  - id: header
    type: header
  - id: indexes
    type: index(_index)
    repeat: expr
    repeat-expr: header.count_of_indexes
    doc: |
      The final index entry indicates the end of the data segment and normally EOF.
      v2: The final index entry must not have the high bit set.
enums:
  compression:
    0: unknown
    1: none
    2: deflate
    3: lz4
types:
  index:
    params:
      - id: idx
        type: u8
    seq:
      - id: val_
        type: u4
    instances:
      ptr:
        value: (val_ & 0x7FFFFFFF) << _root.header.index_shift
        doc: |
          The lower 31 bits of each index entry, when shifted left by `index_shift`, indicate the position within the file of the block's compressed data.  The length of the block is the difference between this entry's offset and the following index entry's offset value.
          Note that this size may be larger than the compressed or uncompressed data, if `index_shift` is greater than 0.  The space between blocks may be padded with any byte, but NUL is recommended.
          Note also that this means index entries must be incrementing.  Reordering or deduplication of blocks is not supported.
          zso v1: The lower 31 bits of each index entry, when shifted left by `index_shift`, indicate the position within the file of the block's compressed data.  The length of the block is the difference between this entry's offset and the following index entry's offset value.
          Note that this size may be larger than the compressed or uncompressed data, if `index_shift` is greater than 0.  The space between blocks may be padded with any byte, but NUL is recommended.
          Note also that this means index entries must be incrementing.  Reordering or deduplication of blocks is not supported.
      msb:
        value: val_ >> 31 == 1
      size:
        value: _root.indexes[idx+1].ptr-ptr
      compression_cso_v1:
        value: (msb?(compression::none):(compression::deflate))
      compression_zso_v1:
        value: (msb?(compression::none):(compression::lz4))
      compression_cso_v2:
        value: ((size < _root.header.block_size)?(msb?(compression::lz4):(compression::deflate)):(compression::none))
      compression:
        value: |
          (
            _root.header.flavour == "C"
            ?
            (_root.header.version<=1?compression_cso_v1:compression_cso_v2)
            :
            (_root.header.flavour == "Z"?compression_zso_v1:(compression::unknown))
          )
      block_uncompressed:
        pos: ptr
        io: _root._io
        size: size
      block_deflate:
        pos: ptr
        io: _root._io
        size: size
        process: kaitai.compress.zlib(15, "raw")
      block_lz4:
        pos: ptr
        io: _root._io
        size: size
        process: kaitai.compress.lz4
      block:
        value: ((compression==(compression::deflate))?block_deflate:((compression==(compression::lz4))?block_lz4:block_uncompressed))
        if: compression!=compression::unknown
  header:
    seq:
      - id: flavour
        type: str
        size: 1
        doc: |
          "Z" for ZSO, "C" for CSO"
      - id: signature
        -orig-id: magic
        contents: ["ISO"]
      - id: header_size
        -orig-id: header_size
        type: u4
        doc: |
          v1: Does not always contain a reliable value.
          v2: Must always be 0x18
      - id: uncompressed_size
        -orig-id: uncompressed_size
        type: u8
        doc: Total size of original ISO.
      - id: block_size
        -orig-id: block_size
        type: u4
        doc: Size of each block, usually 2048.
      - id: version
        -orig-id: version
        type: u1
        doc: May be 0 or 1 (v1) or 2 (v2).
      - id: index_shift
        -orig-id: index_shift
        type: u1
        doc: Indicates left shift of index values.
      - id: reserved
        -orig-id: unused
        size: 2
        doc: May contain any values.
    instances:
      block_count:
        value: "(uncompressed_size + block_size - 1) / block_size" #ceil(uncompressed_size / block_size)
      count_of_indexes:
        value: block_count + 1
