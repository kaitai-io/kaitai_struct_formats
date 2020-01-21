meta:
  id: repetitive
  license: GPL-3.0-only
  endian: be
  ks-version: 0.9

doc: |
  Implementantion of ASTERIX format.

  From Eurocontrol Asterix web page at
  https://www.eurocontrol.int/asterix

  Repetitive Standard Field format.

  The repetitive field format is a variable lenght format.

  It uses three parameters:

  item, which is just the item name, as I001/010 or I062/390. It is just
  informative, and is not used during parsing, but permits to consult the item
  name later in the target language.

  flag: this is a bool parameter, which determines if there have to be parsed or
  just skipped, mainly used by compound. In Catalog files, the flag is always true

  f_size, which is the size of the repetitive parts.

params:
  - id: item
    type: str
  - id: flag
    type: b1
  - id: f_size
    type: u1

seq:
  - id: rep_idx
    type: u1
    if: flag

  - id: val
    size: f_size
    repeat: expr
    repeat-expr: rep_idx
    if: flag

instances:
  tot_size:
    value: >
      flag ?
      (1 +
      (rep_idx > 0 ? val.size * f_size : 0)) : 0

  type:
    value: '"Repetitive"'
