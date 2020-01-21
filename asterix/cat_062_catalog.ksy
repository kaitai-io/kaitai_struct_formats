meta:
  id: cat_062_catalog
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

  Category 062 Catalog definition file

  ASTERIX Part 9 Category 062 SDPS Track Messages
  EUROCONTROL-SPEC-0149-9

  Edition Number : 1.18

params:
  - id: item_ref_num
    type: s2

seq:
  - id: item
    type:
      switch-on: item_ref_num
      cases:
        10:  fixed(true,2)
        15:  fixed(true,1)
        40:  fixed(true,2)
        60:  fixed(true,2)
        70:  fixed(true,3)
        80:  extended(true,1,1)
        100: fixed(true,6)
        105: fixed(true,8)
        110: compound("FFFFFFF",[1,4,6,2,2,1,1],[0,0,0,0,0,0,0])
        120: fixed(true,2)
        130: fixed(true,2)
        135: fixed(true,2)
        136: fixed(true,2)
        185: fixed(true,4)
        200: fixed(true,1)
        210: fixed(true,2)
        220: fixed(true,2)
        245: fixed(true,7)
        270: extended(true,1,1)
        290: compound("FFFFFFF"+"FFF",[1,1,1,1,2,1,1,1,1,1],[0,0,0,0,0,0,0,0,0,0])
        295: compound("FFFFFFF"+"FFFFFFF"+"FFFFFFF"+"FFFFFFF"+"FFF",[1,1,1,1,1,1,1,  1, 1,1,1,1,1,1,  1,1,1,1,1,1,1,  1,1,1,1,1,1,1,  1,1,1],[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0])
        300: fixed(true,1)
        340: compound("FFFFFF",[2,4,2,2,2,1],[0,0,0,0,0,0])
        380: compound("FFFFFFF"+"FRFFFFF"+"FFFFFFF"+"FFFRFFF",      [3,6,2,2,2,2,2,  1,15,2,2,7,2,2,  2,2,2,2,1,8,1,  6,2,1,8,2,2,2],        [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0])
        390: compound("FFFFFFF"+"FFFFRFF"+"FFFF", [2,7,4,1,4,1,4,  4,3,2,2,4,6,1,  7,7,2,7],[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,])
        500: compound("FFFFFFF"+"F",[4,2,4,1,1,2,2,  1],[0,0,0,0,0,0,0,0])
        510: extended(true,3,3)






instances:
  category:
    value: '"062"'

  version:
    value: '"1.00"'
