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

doc-ref: |
  https://www.eurocontrol.int/publication/cat021-eurocontrol-specification-surveillance-data-exchange-asterix-part-12-category-21

params:
  - id: item_ref_num
    type: s2

seq:
  - id: item
    type:
      switch-on: item_ref_num
      cases:
        8:      fixed("I008",true,1)
        10:      fixed("I010",true,2)
        15:      fixed("I015",true,1)
        16:      fixed("I016",true,1)
        20:      fixed("I020",true,1)
        40:   extended("I040",true,1,1)
        70:      fixed("I070",true,2)
        71:      fixed("I071",true,3)
        72:      fixed("I072",true,3)
        73:      fixed("I073",true,3)
        74:      fixed("I074",true,4)
        75:      fixed("I075",true,3)
        76:      fixed("I076",true,4)
        77:      fixed("I077",true,3)
        80:      fixed("I080",true,3)
        90:   extended("I090",true,1,1)
        110:   compound("I110","ERZZ"+"ZZZ",[1,15,0,0,0,0,0],[1,0,0,0,0,0,0])
        130:      fixed("I130",true,6)
        131:      fixed("I131",true,8)
        132:      fixed("I132",true,1)
        140:      fixed("I140",true,2)
        145:      fixed("I145",true,2)
        146:      fixed("I146",true,2)
        148:      fixed("I148",true,2)
        150:      fixed("I150",true,2)
        151:      fixed("I151",true,2)
        152:      fixed("I152",true,2)
        155:      fixed("I155",true,2)
        157:      fixed("I157",true,2)
        160:      fixed("I160",true,4)
        161:      fixed("I161",true,2)
        165:      fixed("I165",true,2)
        170:      fixed("I170",true,6)
        200:      fixed("I200",true,1)
        210:      fixed("I210",true,1)
        220:   compound("I220","FFFF"+"ZZZ",[2,2,2,1,0,0,0],[0,0,0,0,0,0,0])
        230:      fixed("I230",true,2)
        250: repetitive("I250",true,8)
        260:      fixed("I260",true,7)
        271:   extended("I271",true,1,1)
        295:   compound("I295","FFFF"+"FFF"+"FFFF"+"FFF"+"FFFF"+"FFF"+"FF",[1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1],[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0])
        400:      fixed("I400",true,1)
