meta:
  id: cat_002_catalog
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

  Category 002 Catalog definition file
  Radar Data Exchange Part 2b
  Transmission of Monoradar Service Messages
  SUR.ET1.ST05.2000-STD-02b-01
  Edition : 1.0

doc-ref: |
  https://www.eurocontrol.int/publication/cat002-eurocontrol-standard-document-radar-data-exchange-part-2b

params:
  - id: item_ref_num
    type: s2

seq:
  - id: item
    type:
      switch-on: item_ref_num
      cases:
        0:        fixed("I000",true,1)
        10:       fixed("I010",true,2)
        20:       fixed("I020",true,1)
        30:       fixed("I030",true,3)
        41:       fixed("I041",true,2)
        50:    extended("I050",true,1,1)
        60:    extended("I060",true,1,1)
        70:  repetitive("I070",true,2)
        080:   extended("I080",true,1,1)
        090:      fixed("I090",true,2)
        100:      fixed("I100",true,8)
