meta:
  id: cat_001
  license: GPL-3.0-only
  endian: be
  imports:
      - field_spec
      - explicit
      - cat_001_catalog
  ks-version: 0.9

doc: |
  Implementantion of ASTERIX format.

  From Eurocontrol Asterix web page at
  https://www.eurocontrol.int/asterix

  Category 001 definition file
  RADAR DATA EXCHANGE Part 2a
  Transmission of Monoradar Data Target Reports

  SUR.ET1.ST05.2000-STD-02a-01

  Edition : 1.2

seq:
  - id: fspec
    type: field_spec

  - id: data
    type:
      switch-on: is_plot
      cases:
        true:  uap_type(fspec, [10,20,40,70,90,130,141,50,120,131,80,100,60,30,150].as<s2[]>.as<str>)
        false: uap_type(fspec, [10,20,161,40,42,200,70,90,141,130,131,120,170,210,50,80,100,60,30].as<s2[]>.as<str>)

  - id: isp #("SP","E","1","SP-Data Item Special Purpose Field","N.A."),
    type: explicit("SP",true)
    if: fspec.octects.size > 2 and fspec.octects[2].bits[5]

  - id: irfs #("RFS","E","1","RE-Data Item Reserved Expansion Field","N.A."),
    type: explicit("RFS",true)
    if: fspec.octects.size > 2 and fspec.octects[2].bits[6]

  - id: i150
    type: cat_001_catalog("150")
    if: is_track and fspec.octects.size > 3 and fspec.octects[3].bits[1]


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
            true: cat_001_catalog(uap_list[ _index ])
        repeat: expr
        repeat-expr: loop_range

    instances:

      uap_list:
        value: uap.as<s2[]>

      loop_range:
        value: 'fspec.size > uap_list.size ? uap_list.size : fspec.size'

instances:

  uap_select:
    pos: _root._io.pos + 2 #+ fspec.octects.size + 2
    type: u1

  is_track:
    value: (uap_select >> 7).as<b1>

  is_plot:
    value: not is_track

  category:
    value: '"001"'

  version:
    value: '"1.20"'
