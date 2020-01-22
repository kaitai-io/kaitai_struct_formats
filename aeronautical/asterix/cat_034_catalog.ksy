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

doc-ref: |
  https://www.eurocontrol.int/publication/cat034-eurocontrol-specification-surveillance-data-exchange-part-2b

params:
  - id: item_ref_num
    type: s2

seq:
  - id: item
    type:
      switch-on: item_ref_num
      cases:
        0:       fixed("I000",true,1)
        10:       fixed("I010",true,2)
        20:       fixed("I020",true,1)
        30:       fixed("I030",true,3)
        41:       fixed("I041",true,2)
        50:    compound("I050","FZZF"+"FFZ",[1,0,0,1,1,2,0],[0,0,0,0,0,0,0])
        60:    compound("I060","FZZF"+"FFZ",[1,0,0,1,1,1,0],[0,0,0,0,0,0,0])
        70:  repetitive("I070",true,2)
        90:       fixed("I090",true,2)
        100:       fixed("I100",true,8)
        110:       fixed("I110",true,1)
        120:       fixed("I120",true,8)
