meta:
  id: cat_034_catalog
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

  Category 034 Catalog definition file

  ASTERIX Part 2b Category 34
  Transmission of Monoradar Service Messages

  SUR.ET1.ST05.2000-STD-02b-01

  Edition Number: 1.27

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
        20:  fixed(true,1)
        30:  fixed(true,3)
        41:  fixed(true,2)
        50:  compound("FZZF"+"FFZ",[1,0,0,1,1,2,0],[0,0,0,0,0,0,0])
        60:  compound("FZZF"+"FFZ",[1,0,0,1,1,1,0],[0,0,0,0,0,0,0])
        70:  repetitive(true,2)
        90:  fixed(true,2)
        100: fixed(true,8)
        110: fixed(true,1)
        120: fixed(true,8)
