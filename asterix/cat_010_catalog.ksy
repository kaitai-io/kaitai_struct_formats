meta:
  id: cat_010_catalog
  license: GPL-3.0-only
  endian: be
  imports:
#    - bit_map
    - fixed
    - explicit
    - extended
    - repetitive
    - compound
  ks-version: 0.9

doc: |
  Implementantion of ASTERIX format.

  From Eurocontrol Asterix web page at
  https://www.eurocontrol.int/asterix

  Category 010 Catalog definition file

  Part 7 : Category 010
  Transmission of Monosensor Surface Movement Data

  SUR.ET1.ST05.2000-STD-07-01
  Edition : 1.1

params:
  - id: item_ref_num
    type: s2

seq:
  - id: item
    type:
      switch-on: item_ref_num
      cases:
        0:   fixed(true,1)
        10:  fixed(true,2)
        20:  extended(true,1,1)
        40:  fixed(true,4)
        41:  fixed(true,8)
        42:  fixed(true,4)
        60:  fixed(true,2)
        90:  fixed(true,2)
        91:  fixed(true,2)
        131: fixed(true,1)
        140: fixed(true,3)
        161: fixed(true,2)
        170: extended(true,1,1)
        200: fixed(true,4)
        202: fixed(true,4)
        210: fixed(true,2)
        220: fixed(true,3)
        245: fixed(true,7)
        250: repetitive(true,8)
        270: extended(true,1,1)
        280: repetitive(true,2)
        300: fixed(true,1)
        310: fixed(true,1)
        500: fixed(true,4)
        550: fixed(true,1)


instances:
  category:
    value: '"010"'

  version:
    value: '"1.10"'
