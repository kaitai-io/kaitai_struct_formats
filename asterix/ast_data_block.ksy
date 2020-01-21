meta:
  id: ast_data_block
  file-extension: ast
  endian: be
  license: GPL-3.0-only
  imports:
    - ast_record

  ks-version: 0.9

doc: |
  Implementantion of ASTERIX format.

  From Eurocontrol Asterix web page at
  https://www.eurocontrol.int/asterix

  Asterix Data Block, consisting in a Category and lengh, and a list of sequential
  records as defined by Asterix.

seq:
  - id: cat
    type: u1
  - id: len
    type: u2
  - id: data_records
    type: ast_record(cat)
    size: len - 3


instances:
  records:
    value: data_records.records.as<ast_record[]>
