meta:
  id: cat_021_catalog
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

  Category 021 Catalog definition file

  ASTERIX Part 12 Category 21 ADS-B Target Reports
  NOT backwards compatible to category 021 edition 2.1 or earlier
  EUROCONTROL-SPEC-0149-12

  Edition Number: 2.4

params:
  - id: item_ref_num
    type: s2

seq:
  - id: item
    type:
      switch-on: item_ref_num
      cases:
        8: fixed(true,1)
        10: fixed(true,2)
        15: fixed(true,1)
        16: fixed(true,1)
        20: fixed(true,1)
        40: extended(true,1,1)
        70: fixed(true,2)
        71: fixed(true,3)
        72: fixed(true,3)
        73: fixed(true,3)
        74: fixed(true,4)
        75: fixed(true,3)
        76: fixed(true,4)
        77: fixed(true,3)
        80: fixed(true,3)
        90: extended(true,1,1)
        110: compound("ERZZ"+"ZZZ",[1,15,0,0,0,0,0],[1,0,0,0,0,0,0])
        130: fixed(true,6)
        131: fixed(true,8)
        132: fixed(true,1)
        140: fixed(true,2)
        145: fixed(true,2)
        146: fixed(true,2)
        148: fixed(true,2)
        150: fixed(true,2)
        151: fixed(true,2)
        152: fixed(true,2)
        155: fixed(true,2)
        157: fixed(true,2)
        160: fixed(true,4)
        161: fixed(true,2)
        165: fixed(true,2)
        170: fixed(true,6)
        200: fixed(true,1)
        210: fixed(true,1)
        220: compound("FFFF"+"ZZZ",[2,2,2,1,0,0,0],[0,0,0,0,0,0,0])
        230: fixed(true,2)
        250: repetitive(true,8)
        260: fixed(true,7)
        271: extended(true,1,1)
        295: compound("FFFF"+"FFF"+"FFFF"+"FFF"+"FFFF"+"FFF"+"FF",[1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1],[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0])
        400: fixed(true,1)
