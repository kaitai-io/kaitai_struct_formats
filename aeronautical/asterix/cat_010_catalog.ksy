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

doc-ref: |
  https://www.eurocontrol.int/publication/cat010-eurocontrol-specification-surveillance-data-exchange-part-7-category-010


params:
  - id: item_ref_num
    type: s2

seq:
  - id: item
    type:
      switch-on: item_ref_num
      cases:
        0:      fixed("I000",true,1)
        10:      fixed("I010",true,2)
        20:   extended("I020",true,1,1)
        40:      fixed("I040",true,4)
        41:      fixed("I041",true,8)
        42:      fixed("I042",true,4)
        60:      fixed("I060",true,2)
        90:      fixed("I090",true,2)
        91:      fixed("I091",true,2)
        131:      fixed("I131",true,1)
        140:      fixed("I140",true,3)
        161:      fixed("I161",true,2)
        170:   extended("I170",true,1,1)
        200:      fixed("I200",true,4)
        202:      fixed("I202",true,4)
        210:      fixed("I210",true,2)
        220:      fixed("I220",true,3)
        245:      fixed("I245",true,7)
        250: repetitive("I250",true,8)
        270:   extended("I270",true,1,1)
        280: repetitive("I280",true,2)
        300:      fixed("I300",true,1)
        310:      fixed("I310",true,1)
        500:      fixed("I500",true,4)
        550:      fixed("I550",true,1)


instances:
  category:
    value: '"010"'

  version:
    value: '"1.10"'
