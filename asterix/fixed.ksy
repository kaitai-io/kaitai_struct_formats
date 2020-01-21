meta:
  id: fixed
  license: GPL-3.0-only
  endian: be
  ks-version: 0.9

doc: |
  Implementantion of ASTERIX format.

  From Eurocontrol Asterix web page at
  https://www.eurocontrol.int/asterix

  Fixed Size Standard Field format.

  The fixed size field format comprises a predefined number of bytes.

  It uses three parameters:

  item, which is just the item name, as I001/010 or I062/390. It is just
  informative, and is not used during parsing, but permits to consult the item
  name later in the target language.

  flag: this is a bool parameter, which determines if there have to be parsed or
  just skipped, mainly used by compound. In Catalog files, the flag is always true

  f_size: is the size of the field.

  This field is read as a byte array.

params:
  - id: item
    type: str
  - id: flag
    type: b1
  - id: f_size
    type: u1
seq:
  - id: value
    size: f_size
    if: flag

instances:
  tot_size:
    value: 'flag ? f_size : 0'

  type:
    value: '"Fixed"'
