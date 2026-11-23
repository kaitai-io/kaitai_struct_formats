meta:
  id: tortoise_git_log_cache_index
  title: TortoiseGit git log cache index
  application: TortoiseGit
  -filename-regexp: "^tortoisegit\\.index$"
  xref:
    wikidata: Q178572
  license: GPL-3.0+
  endian: le
  encoding: utf-16le
  ks-version: 0.9

doc: |
  TortoiseGit is a GUI frontend for git SCM. It caches some data to `tortoisegit.data` file in `.git` dir. `tortoisegit.index is an index for that file.

doc-ref:
  - https://gitlab.com/tortoisegit/tortoisegit/raw/master/src/TortoiseProc/gitlogcache.h
  - https://gitlab.com/tortoisegit/tortoisegit/raw/master/src/TortoiseProc/GitLogCache.cpp

seq:
  - id: signature
    contents: [0x66, 0x55, 0xAA, 0x88]
    -orig-id: m_Magic
  - id: version
    type: u4
    doc: "current one is 0x11"
    -orig-id: m_Version
  - id: item_count
    type: u4
    -orig-id: m_ItemCount
  - id: items
    type: item
    repeat: expr
    repeat-expr: item_count
types:
  c_git_hash:
    seq:
      - id: hash
        size: 20
  item:
    -orig-id: SLogCacheIndexItem
    seq:
      - id: hash
        type: c_git_hash
        -orig-id: m_Hash
      - id: offset
        type: u8 # ULONGLONG
        -orig-id: m_Offset
