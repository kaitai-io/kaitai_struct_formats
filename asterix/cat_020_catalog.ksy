meta:
  id: cat_020_catalog
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

  Category 020 Catalog definition file

  ASTERIX Part 14 Category 20 Multilateration Target Reports
  EUROCONTROL-SPEC-0149-14

  Edition Number: 1.9

params:
  - id: item_ref_num
    type: s2

seq:
  - id: item
    type:
      switch-on: item_ref_num
      cases:
        10:  fixed(true,2)
        20:  extended(true,1,1)
        30:  extended(true,1,1)
        41:  fixed(true,8)
        42:  fixed(true,6)
        50:  fixed(true,2)
        55:  fixed(true,1)
        70:  fixed(true,2)
        90:  fixed(true,2)
        100: fixed(true,4)
        105: fixed(true,2)
        110: fixed(true,2)
        140: fixed(true,3)
        161: fixed(true,2)
        170: extended(true,1,1)
        202: fixed(true,2)
        210: fixed(true,2)
        220: fixed(true,3)
        230: fixed(true,2)
        245: fixed(true,7)
        250: repetitive(true,1,8)
        260: fixed(true,7)
        300: fixed(true,1)
        310: fixed(true,1)
        400: repetitive(true,1)
        500: compound("FFF",[6,6,2],[0,0,0])
