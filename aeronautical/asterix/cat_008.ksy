meta:
  id: cat_008
  license: GPL-3.0-only
  endian: be
  imports:
      - field_spec
      - explicit
      - cat_008_catalog
  ks-version: 0.9

doc: |
  Implementantion of ASTERIX format.

  From Eurocontrol Asterix web page at
  https://www.eurocontrol.int/asterix

  Category 008 definition file

  ASTERIX Part 3 Category 008
  Monoradar Derived Weather Information

  EUROCONTROL-SPEC-0149-3

  Edition : 1.2

doc-ref: |
  https://www.eurocontrol.int/publication/cat008-eurocontrol-specification-surveillance-data-exchange-asterix-part-3-category-008

seq:
  - id: fspec
    type: field_spec

  - id: data
    type: uap_type(fspec, [10,0,20,36,34,40,50,90,100,110,120,38].as<u2[]>.as<str>)

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
            true: cat_008_catalog(uap_list[ _index ])
        repeat: expr
        repeat-expr: loop_range


      - id: sp #,"E","1","Special Purpose Field","N.A."),
        type: explicit("SP",true)
        if: fspec.size >= 13 and fspec.octects[1].bits[5]

      - id: irfs #,"E","1","Reserved Expansion Field","N.A."),
        type: explicit("RFS",true)
        if: fspec.size >= 14 and fspec.octects[1].bits[6]


    instances:

      uap_list:
        value: uap.as<u2[]>

      loop_range:
        value: 'fspec.size > uap_list.size ? uap_list.size : fspec.size'

instances:

  category:
    value: '"008"'

  version:
    value: '"1.20"'

  items:
    value: data.items
