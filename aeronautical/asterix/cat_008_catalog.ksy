meta:
  id: cat_008_catalog
  title: Eurocontrol Asterix Category 008 CAT008 data items catalog. Edition 1.2
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

  Category 008 Catalog definition file

  ASTERIX Part 3 Category 008
  Monoradar Derived Weather Information

  EUROCONTROL-SPEC-0149-3

  Edition : 1.2

doc-ref: |
  https://www.eurocontrol.int/publication/cat008-eurocontrol-specification-surveillance-data-exchange-asterix-part-3-category-008

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
        20:    extended("I020",true,1,1)
        34:  repetitive("I034",true,4)
        36:  repetitive("I036",true,3)
        38:  repetitive("I038",true,4)
        40:       fixed("I040",true,2)
        50:  repetitive("I050",true,2)
        90:       fixed("I090",true,3)
        100:    extended("I100",true,3,1)
        110:    extended("I110",true,1,1)
        120:       fixed("I120",true,2)


instances:
  category:
    value: '"008"'

  version:
    value: '"1.20"'
