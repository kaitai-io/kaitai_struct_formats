meta:
  id: odex
  title: Odex
  file-extension: odex
  license: Apache-2.0
  ks-version: 0.9
  imports:
    - /executable/dex
  endian: le
  encoding: UTF-8
doc-ref: http://web.archive.org/web/20180816094438/https://android.googlesource.com/platform/dalvik.git/+/master/libdex/DexFile.h
seq:
  - id: magic
    contents: "dey\n"
  - id: version
    type: strz
    size: 4
  - id: ofs_dex
    type: u4
    doc: file offset of DEX header
  - id: len_dex
    type: u4
  - id: ofs_deps
    type: u4
    doc: offset of optimized DEX dependency table
  - id: len_deps
    type: u4
  - id: ofs_opt
    type: u4
    doc: file offset of optimized data tables
  - id: len_opt
    type: u4
  - id: flags
    type: u4
  - id: adler32
    type: u4
    doc: adler32 checksum covering deps/deps_padding/opt
instances:
  raw_dex:
    pos: ofs_dex
    size: len_dex
  dex:
    pos: ofs_dex
    size: len_dex
    type: dex
  deps:
    pos: ofs_deps
    size: len_deps
  deps_padding:
    pos: ofs_deps + len_deps
    size: -len_deps%8
  opt:
    pos: ofs_opt
    size: len_opt
