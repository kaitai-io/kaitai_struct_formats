meta:
  id: cat_034
  license: GPL-3.0-only
  endian: be
  imports:
      - field_spec
      - explicit
      - cat_034_catalog
  ks-version: 0.9

doc: |
  Implementantion of ASTERIX format.

  From Eurocontrol Asterix web page at
  https://www.eurocontrol.int/asterix

  Category 034 definition file

  ASTERIX Part 2b Category 34
  Transmission of Monoradar Service Messages

  SUR.ET1.ST05.2000-STD-02b-01

  Edition Number: 1.27

doc-ref: |
  https://www.eurocontrol.int/publication/cat034-eurocontrol-specification-surveillance-data-exchange-part-2b

seq:
  - id: fspec
    type: field_spec

  - id: data
    type: uap_type(fspec, [10,0,30,20,41,50,60,70,100,110,120,90].as<u2[]>.as<str>)

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
            true: cat_034_catalog(uap_list[ _index ])
        repeat: expr
        repeat-expr: loop_range


      - id: sp #,"E","1","Special Purpose Field","N.A."),
        type: explicit("SP",true)
        if: fspec.size >= 13 and fspec.octects[1].bits[5]

      - id: ire #,"E","1","Reserved Expansion Field","N.A."),
        type: explicit("RE",true)
        if: fspec.size >= 14 and fspec.octects[1].bits[6]


    instances:

      uap_list:
        value: uap.as<u2[]>

      loop_range:
        value: 'fspec.size > uap_list.size ? uap_list.size : fspec.size'

instances:

  category:
    value: '"034"'

  version:
    value: '"1.27"'

  items:
    value: data.items

  i010:
    value: data.items[0].item
    if: data.loop_range-1 >= 0
#  - id: i010 #("I034/010","F","2","Data Source Identifier","N.A."),
#    type: c34_item(10)
#    if: fspec.octects[0].bits[0]
#
  i000:
    value: data.items[1].item
    if: data.loop_range-1 >= 1
#  - id: i000 #("I034/000","F","1","Message Type","N.A."),
#    type: c34_item(0)
#    if: fspec.octects[0].bits[1]
#
  i030:
    value: data.items[2].item
    if: data.loop_range-1 >= 2
#  - id: i030 #("I034/030","F","3","Time of Day","1/128 s"),
#    type: c34_item(30)
#    if: fspec.octects[0].bits[2]
#
  i020:
    value: data.items[3].item
    if: data.loop_range-1 >= 3
#  - id: i020 #("I034/020","F","1","Sector Number ","360/(28)"),
#    type: c34_item(20)
#    if: fspec.octects[0].bits[3]
#
  i041:
    value: data.items[4].item
    if: data.loop_range-1 >= 4
#  - id: i041 #("I034/041","F","2","Antenna Rotation Period","1/128 s"),
#    type: c34_item(41)
#    if: fspec.octects[0].bits[4]
#
  i050:
    value: data.items[5].item
    if: data.loop_range-1 >= 5
#  - id: i050 #("I034/050","C","1+F:1,F:0,F:0,F:1,F:1,F:2,F:0,F:0","System Configuration & Status","N.A."),
#    type: c34_item(50)
#    if: fspec.octects[0].bits[5]
#
  i060:
    value: data.items[6].item
    if: data.loop_range-1 >= 6
#  - id: i060 #("I034/060","C","1+F:1,F:0,F:0,F:1,F:1,F:1,F:0,F:0","System Processing Mode","N.A."),
#    type: c34_item(60)
#    if: fspec.octects[0].bits[6]
#
  i070:
    value: data.items[7].item
    if: data.loop_range-1 >= 7
#  - id: i070 #("I034/070","R","1+2","Message Count Values","N.A."),
#    type: c34_item(70)
#    if: fspec.octects.size > 1 and fspec.octects[1].bits[0]
#
  i100:
    value: data.items[8].item
    if: data.loop_range-1 >= 8
#  - id: i100 #("I034/100","F","8","Generic Polar Window","RHO: 1/256 NM THETA: 360/(216)"),
#    type: c34_item(100)
#    if: fspec.octects.size > 1 and fspec.octects[1].bits[1]
#
  i110:
    value: data.items[9].item
    if: data.loop_range-1 >= 9
#  - id: i110 #("I034/110","F","1","Data Filter","N.A."),
#    type: c34_item(110)
#    if: fspec.octects.size > 1 and fspec.octects[1].bits[2]
#
  i120:
    value: data.items[10].item
    if: data.loop_range-1 >= 10
#  - id: i120 #("I034/120","F","8","3D-position of source","Height : 1 m Latitude: 180/(223) Longitude: 180/(223)"),
#    type: c34_item(120)
#    if: fspec.octects.size > 1 and fspec.octects[1].bits[3]
#
  i090:
    value: data.items[11].item
    if: data.loop_range-1 >= 11
#  - id: i090 #("I034/090","F","2","Collimation Error","Range: 1/128 NM Azimuth: 360/(214)"),
#    type: c34_item(90)
#    if: fspec.octects.size > 1 and fspec.octects[1].bits[4]
#
#  - id: ire #("RE","E","1","RE-Data Item Reserved Expansion Field","N.A."),
#    type: field('E',[0],[0])
#    if: fspec.octects.size > 1 and fspec.octects[1].bits[5]
#
#  - id: isp #("SP","E","1","SP-Data Item Special Purpose Field","N.A."),
#    type: field('E',[0],[0])
#    if: fspec.octects.size > 1 and fspec.octects[1].bits[6]
#
