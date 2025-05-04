meta:
  id: git_commit_graph
  endian: le
  license: Unlicense
  encoding: utf-8

doc: |
  Black-box reverse-engineered Git Commit Graph Blob format.
  Black-box reverse-enginneering was a requirement of Junio Hamano, who was unwiling to relicense Git Commit Graph Blob docs under a permissive license and [told](https://lore.kernel.org/git/xmqqeexbrffe.fsf@gitster-ct.c.googlers.com/) that [clean-room/black box reverse engineering](https://lore.kernel.org/git/4B11ADEA-8E8F-444F-B4CA-C4A3E9536F8C@mail.ru/#r) (this was my previous message) is "the necessary effort to comply with the license".
  Don't rely on types names, they will likely be changed.

seq:
  - id: records
    type: record
    repeat: eos

types:
  record:
    seq:
      - id: signature
        type: str
        size: 4
      - id: record
        type:
          switch-on: signature
          cases:
            '"CGBF"': header  # I guess, Git Commit graph Blob Format
            '"OIDF"': oidf
            '"OIDL"': oidl
            '"CDAT"': cdat
            #'"EDGE"': edges

  header:
    seq:
      - id: unkn
        type: u4
        doc: likely flags,
  oidf:
    seq:
      - id: unkn
        type: u8
  oidl:
    seq:
      - id: unkn
        type: u8
  cdat:
    seq:
      - id: unkn
        size: 7
  #edges:
  #  -
