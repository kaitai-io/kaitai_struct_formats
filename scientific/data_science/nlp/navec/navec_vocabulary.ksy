meta:
  id: navec_vocabulary
  title: navec vocabulary
  license: MIT
  -file-regex: ^vocab\.bin$
  endian: le
  bit-endian: le
  encoding: utf-8

doc: |
  Vocabulary files of navec word embedding library. Shipped in compressed form, must be decompressed first.
  Sample files can be extracted from https://storage.yandexcloud.net/natasha-navec/packs/navec_news_v1_1B_250K_300d_100q.tar

doc-ref:
  - https://github.com/natasha/navec/blob/f56e74ab07b64b888ca1cb8788fcb1d77988ca90/README.md
  - https://github.com/natasha/navec/blob/f56e74ab07b64b888ca1cb8788fcb1d77988ca90/navec/vocab.py#L99

seq:
  - id: header
    type: header
  - id: counts
    type: u4
    repeat: expr
    repeat-expr: header.count
  - id: words_in_lines
    type: str
    size-eos: true
    doc: |
      Words splitted by line breaks.
      Count of words must match `header.count`. The 2 last words must be `<unk>` (some vector of non-zeros) and `<pad>` (must have all zeros) in this order.

types:
  header:
    seq:
      - id: count
        -orig-id: size
        type: u4
        valid:
          min: 2
