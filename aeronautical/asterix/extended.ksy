meta:
  id: extended
  license: GPL-3.0-only
  endian: be
  ks-version: 0.9

doc: |
  Implementantion of ASTERIX format.

  From Eurocontrol Asterix web page at
  https://www.eurocontrol.int/asterix

  Extended Standard Field format.

  The extended field format is a variable lenght format.

  It uses four parameters:

  item, which is just the item name, as I001/010, or I062/390. It is just
  informative, and is not used during parsing, but permits to consult the item
  name later in the target language.

  flag: this is a bool parameter, which determines if there have to be parsed or
  just skipped, mainly used by compound. In Catalog files, the flag is always true

  f_pri_size: is the size of the primary part of the field.

  f_sec_size: is the size of the secondaries parts.

params:
  - id: name
    type: str
  - id: flag
    type: b1
  - id: f_pri_size
    type: u1
  - id: f_sec_size
    type: u1

seq:
  - id: pri_part
    size: f_pri_size
    if: flag
  - id: sec_part
    size: f_sec_size
    repeat: until
    repeat-until: _.as<u1[]>.last & 1 == 0
    if: flag and has_sec

instances:
  has_sec:
    value: 'flag ? pri_part.as<u1[]>.last & 1 == 1 : false'
  tot_size:
    value: >
      flag ?
      (f_pri_size +
      (has_sec ? sec_part.size * f_sec_size : 0)) : 0

  type:
    value: '"Extended"'
