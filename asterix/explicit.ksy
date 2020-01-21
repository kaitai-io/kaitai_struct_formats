meta:
  id: explicit
  license: GPL-3.0-only
  endian: be
  ks-version: 0.9

doc: |
  Implementantion of ASTERIX format.
  
  From Eurocontrol Asterix web page at
  https://www.eurocontrol.int/asterix

  Explicit Standard Field format.

  The explicit field format is a variable lenght format.

  It uses two parameters:

  item, which is just the item name, as I001/010 or I062/390. It is just
  informative, and is not used during parsing, but permits to consult the item
  name later in the target language.

  flag: this is a bool parameter, which determines if there have to be parsed or
  just skipped, mainly used by compound. In Catalog files, the flag is always true

params:
  - id: item
    type: str
  - id: flag
    type: b1

seq:
  - id: len
    type: u1
    if: flag

  - id: val
    size: len - 1
    if: flag

instances:
  tot_size:
    value: 'flag ? len : 0'

  type:
    value: '"Explicit"'
