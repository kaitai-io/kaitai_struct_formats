meta:
  id: cat_048
  license: GPL-3.0-only
  endian: be
  imports:
      - field_spec
      - explicit
      - cat_048_catalog
  ks-version: 0.9

doc: |
  Implementantion of ASTERIX format.

  From Eurocontrol Asterix web page at
  https://www.eurocontrol.int/asterix

  Category 048 definition file

  ASTERIX Part 4 Category 048 Monoradar Target Reports
  Edition: 1.25
  Edition date: 08/08/2019
  Reference nr: EUROCONTROL-SPEC-0149-4

doc-ref: |
  https://www.eurocontrol.int/publication/cat048-eurocontrol-specification-surveillance-data-exchange-asterix-part4

seq:
  - id: fspec
    type: field_spec

  - id: data
    type: uap_type(fspec, [10, 140, 20, 40, 70, 90, 130, 220, 240, 250, 161, 42, 200, 170, 210, 30, 80, 100, 110, 120, 230, 260, 55, 50, 65, 60].as<u2[]>.as<str>)

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
            true: cat_048_catalog(uap_list[ _index ])
        repeat: expr
        repeat-expr: loop_range

      - id: sp #,"E","1","Special Purpose Field","N.A."),
        type: explicit("SP",true)
        if: fspec.size >= 27 and fspec.octects[3].bits[5]

      - id: ire #,"E","1","Reserved Expansion Field","N.A."),
        type: explicit("RE",true)
        if: fspec.size >= 28 and fspec.octects[3].bits[6]

    instances:

      uap_list:
        value: uap.as<u2[]>

      loop_range:
        value: 'fspec.size > uap_list.size ? uap_list.size : fspec.size'

instances:
  category:
    value: '"048"'

  version:
    value: '"1.25"'

  items:
    value: data.items
