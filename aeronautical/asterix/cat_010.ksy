meta:
  id: cat_010
  license: GPL-3.0-only
  endian: be
  imports:
      - field_spec
      - explicit
      - cat_010_catalog
  ks-version: 0.9

doc: |
  Implementantion of ASTERIX format.

  From Eurocontrol Asterix web page at
  https://www.eurocontrol.int/asterix

  Category 010 definition file

  Part 7 : Category 010
  Transmission of Monosensor Surface Movement Data

  SUR.ET1.ST05.2000-STD-07-01
  Edition : 1.1

doc-ref: |
  https://www.eurocontrol.int/publication/cat010-eurocontrol-specification-surveillance-data-exchange-part-7-category-010

seq:
  - id: fspec
    type: field_spec

  - id: data
    type: uap_type(fspec, [10,0,20,140,41,40,42,200,202,161,170,60,220,245,250,300,90,91,270,550,310,500,280,131,210].as<s2[]>.as<str>)



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
            true: cat_010_catalog(uap_list[ _index ])
        repeat: expr
        repeat-expr: loop_range


      - id: sp #,"E","1","Special Purpose Field","N.A."),
        type: explicit("SP",true)
        if: fspec.size >= 27 and fspec.octects[3].bits[5]

      - id: re #,"E","1","Reserved Expansion Field","N.A."),
        type: explicit("RE",true)
        if: fspec.size >= 28 and fspec.octects[3].bits[6]


    instances:

      uap_list:
        value: uap.as<s2[]>

      loop_range:
        value: 'fspec.size > uap_list.size ? uap_list.size : fspec.size'

instances:

  category:
    value: '"010"'

  version:
    value: '"1.1"'

  items:
    value: data.items
