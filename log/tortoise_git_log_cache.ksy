meta:
  id: tortoise_git_log_cache
  title: TortoiseGit git log cache
  application: TortoiseGit
  -filename-regexp: "^tortoisegit\\.data$"
  xref:
    wikidata: Q178572
  license: GPL-3.0+
  endian: le
  encoding: utf-16le
  #ks-version: 0.9

doc: |
  TortoiseGit is a GUI frontend for git SCM. It caches some data to `tortoisegit.data` file in `.git` dir.

doc-ref:
  - https://gitlab.com/tortoisegit/tortoisegit/raw/master/src/TortoiseProc/gitlogcache.h
  - https://gitlab.com/tortoisegit/tortoisegit/raw/master/src/TortoiseProc/GitLogCache.cpp

seq:
  - id: signature
    contents: [0xFF, 0x0F, 0xBB, 0x99]
    -orig-id: m_Magic
  - id: version
    type: u4
    doc: "current one is 0x11"
    -orig-id: m_Version
  - id: items
    type: item
    repeat: eos
types:
  item:
    -orig-id: CLogCache::SaveOneItem
    seq:
      - id: signature
        contents: [0xCC, 0x9A, 0xCC, 0x0F]
        -orig-id: m_Magic
      - id: count
        type: u4
        -orig-id: m_FileCount
      - id: files
        type: file
        repeat: expr
        repeat-expr: count
    types:
      file:
        seq:
          - id: signature
            contents: [0xFF, 0x9D, 0xEE, 0x19]
            -orig-id: m_Magic
          - id: action
            type: action
            -orig-id: m_Action
          - id: stage
            type: u4
            -orig-id: m_Stage
          - id: parent_no
            type: u4
            -orig-id: m_ParentNo
          - id: added
            type: u4
            -orig-id: m_Add
          - id: deleted
            type: u4
            -orig-id: m_Del
          - id: is_submodule
            type: u4
            -orig-id: m_IsSubmodule
          - id: file_name_size
            type: u4
            -orig-id: m_FileNameSize
          - id: old_file_name_size
            type: u4
            -orig-id: m_OldFileNameSize
          - id: file_name
            type: str
            size: file_name_size * 2
            -orig-id: m_FileName, name
          - id: old_file_name
            type: str
            size: old_file_name_size * 2
            -orig-id: oldname
        types:
          action:
            meta:
              endian: be # to prevent breakage when https://github.com/kaitai-io/kaitai_struct/issues/155 is implemented
            doc-ref: https://gitlab.com/tortoisegit/tortoisegit/raw/master/src/Git/TGitPath.h
            seq:
              - id: merged
                type: b1
              - id: copy
                type: b1
              - id: reserved0
                type: b1
              - id: unmerged
                type: b1
              - id: deleted
                type: b1
              - id: replaced
                type: b1
              - id: modified
                type: b1
              - id: added
                type: b1

              - id: reserved1
                type: b3
              - id: missing
                type: b1
              - id: reserved2
                type: b1
              - id: skip_work_tree
                type: b1
              - id: assume_valid
                type: b1
              - id: reserved3
                type: b1

              - id: reserved4
                type: u1

              - id: unver
                type: b1
              - id: ignore
                type: b1
              - id: hide
                type: b1
              - id: gray
                type: b1
              - id: reserved5
                type: b4
