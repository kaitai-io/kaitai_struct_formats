meta:
  id: cat_021
  license: GPL-3.0-only
  endian: be
  imports:
      - field_spec
      - explicit
      - cat_021_catalog
  ks-version: 0.9

doc: |
  Implementantion of ASTERIX format.

  From Eurocontrol Asterix web page at
  https://www.eurocontrol.int/asterix

  Category 021 definition file

  ASTERIX Part 12 Category 21 ADS-B Target Reports
  NOT backwards compatible to category 021 edition 2.1 or earlier
  EUROCONTROL-SPEC-0149-12

  Edition Number: 2.4

doc-ref: |
  https://www.eurocontrol.int/publication/cat021-eurocontrol-specification-surveillance-data-exchange-asterix-part-12-category-21

seq:
  - id: fspec
    type: field_spec

  - id: data
    type: uap_type(fspec, [10,40,161,15,71,130,131,72,150,151,80,73,74,75,76,140,90,210,70,230,145,152,200,155,157,160,165,77,170,20,220,146,148,110,16,8,271,132,250,260,400,295].as<u2[]>.as<str>)


types:
  uap_type:
    params:

      - id: fspec
        type: field_spec

      - id: uap
        type: str

    seq:
      - id: items
        type:
          switch-on: fspec.octects[_index/7].bits[_index % 7]
          cases:
            true: cat_021_catalog(uap_list[ _index ])
        repeat: expr
        repeat-expr: loop_range

      - id: re #,"E","1","Reserved Expansion Field","N.A."),
        type: explicit("RE",true)
        if: fspec.size >= 48 and fspec.octects[1].bits[5]

      - id: sp #,"E","1","Special Purpose Field","N.A."),
        type: explicit("SP",true)
        if: fspec.size >= 49 and fspec.octects[1].bits[6]

    instances:

      uap_list:
        value: uap.as<u2[]>

      loop_range:
        value: 'fspec.size > uap_list.size ? uap_list.size : fspec.size'

instances:
  category:
    value: '"021"'

  version:
    value: '"2.4"'

  items:
    value: data.items
