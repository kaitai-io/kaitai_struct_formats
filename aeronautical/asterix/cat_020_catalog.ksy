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

doc-ref: |
  https://www.eurocontrol.int/publication/cat020-eurocontrol-specification-surveillance-data-exchange-asterix-part-14-category-20

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
        41:      fixed("I041",true,8)
        42:      fixed("I042",true,6)
        50:      fixed("I050",true,2)
        55:      fixed("I055",true,1)
        70:      fixed("I070",true,2)
        90:      fixed("I090",true,2)
        100:      fixed("I100",true,4)
        105:      fixed("I105",true,2)
        110:      fixed("I110",true,2)
        140:      fixed("I140",true,3)
        161:      fixed("I161",true,2)
        170:   extended("I170",true,1,1)
        202:      fixed("I202",true,2)
        210:      fixed("I210",true,2)
        220:      fixed("I220",true,3)
        230:      fixed("I230",true,2)
        245:      fixed("I245",true,7)
        250: repetitive("I250",true,1,8)
        260:      fixed("I260",true,7)
        300:      fixed("I300",true,1)
        310:      fixed("I310",true,1)
        400: repetitive("I400",true,1)
        500:   compound("I500","FFF",[6,6,2],[0,0,0])
