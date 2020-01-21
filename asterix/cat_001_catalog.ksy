meta:
  id: cat_001_catalog
  title: Eurocontrol Asterix Category 001 CAT001 data items catalog. Edition 1.0
  license: GPL-3.0-only
  endian: be
  imports:
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

  Category 001 Catalog definition file
  RADAR DATA EXCHANGE Part 2a
  Transmission of Monoradar Data Target Reports

  SUR.ET1.ST05.2000-STD-02a-01

  Edition : 1.2

params:
  - id: item_ref_num
    type: s2

seq:
  - id: item
    type:
      switch-on: item_ref_num
      cases:
        10:      fixed("I010",true,2)
        20:   extended("I020",true,1,1)
        30:   extended("I030",true,1,1)
        40:      fixed("I040",true,4)
        42:      fixed("I042",true,4)
        50:      fixed("I050",true,2)
        60:      fixed("I060",true,2)
        70:      fixed("I070",true,2)
        80:      fixed("I080",true,2)
        90:      fixed("I090",true,2)
        100:     fixed("I100",true,4)
        120:     fixed("I120",true,1)
        130:  extended("I130",true,1,1)
        131:     fixed("I131",true,1)
        141:     fixed("I141",true,2)
        150:     fixed("I150",true,1)
        161:     fixed("I161",true,2)
        170:  extended("I170",true,1,1)
        200:     fixed("I200",true,4)
        210:  extended("I210",true,1,1)
