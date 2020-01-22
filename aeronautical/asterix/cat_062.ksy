meta:
  id: cat_062
  license: GPL-3.0-only
  endian: be
  imports:
      - field_spec
      - explicit
      - cat_062_catalog
  ks-version: 0.9

doc: |
  Implementantion of ASTERIX format.

  From Eurocontrol Asterix web page at
  https://www.eurocontrol.int/asterix

  Category 062 definition file

  ASTERIX Part 9 Category 062 SDPS Track Messages
  EUROCONTROL-SPEC-0149-9

  Edition Number : 1.18

doc-ref: |
  https://www.eurocontrol.int/publication/cat062-eurocontrol-specification-surveillance-data-exchange-asterix-part-9-category-062

seq:
  - id: fspec
    type: field_spec

  - id: data
    type: uap_type(fspec, [10,-1,15,70,105,100,185,210,60,245,380,40,80,290,200,295,136,130,135,220,390,270,300,110,120,510,500,340].as<s2[]>.as<str>)


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
            true: cat_062_catalog(uap_list[ _index ])
        repeat: expr
        repeat-expr: loop_range


      - id: ire #,"E","1","Reserved Expansion Field","N.A."),
        type: explicit("RE",true)
        if: fspec.size >= 34 and fspec.octects[4].bits[5]

      - id: isp #,"E","1","Special Purpose Field","N.A."),
        type: explicit("SP",true)
        if: fspec.size >= 35 and fspec.octects[4].bits[6]


    instances:

      uap_list:
        value: uap.as<s2[]>

      loop_range:
        value: 'fspec.size > uap_list.size ? uap_list.size : fspec.size'

instances:

  items:
    value: data.items

  category:
    value: '"062"'

  version:
    value: '"1.18"'
