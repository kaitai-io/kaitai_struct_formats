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
        type: explicit(true)
        if: fspec.size >= 27 and fspec.octects[3].bits[5]

      - id: ire #,"E","1","Reserved Expansion Field","N.A."),
        type: explicit(true)
        if: fspec.size >= 28 and fspec.octects[3].bits[6]

    instances:

      uap_list:
        value: uap.as<u2[]>

      loop_range:
        value: 'fspec.size > uap_list.size ? uap_list.size : fspec.size'

instances:
  i010:
    value: data.items[0].item
    if: data.loop_range-1 >= 0
#  - id: i010 #,"F","2","Data Source Identifier","N.A."),
#    type: c48_item(10)
#    if: fspec.octects[0].bits[0]
#
  i140:
    value: data.items[1].item
    if: data.loop_range-1 >= 1
#  - id: i140 #,"F","3","Time of Day","1/128 s"),
#    type: c48_item(140)
#    if: fspec.octects[0].bits[1]
#
  i020:
    value: data.items[2].item
    if: data.loop_range-1 >= 2
#  - id: i020 #,"X","1+1","Target Report Descriptor","N.A."),
#    type: c48_item(20)
#    if: fspec.octects[0].bits[2]
#
  i040:
    value: data.items[3].item
    if: data.loop_range-1 >= 3
#  - id: i040 #,"F","4","Measured Position in Slant Polar Co-ordinates","RHO: 1/256 NM, THETA: 360/(2 16)"),
#    type: c48_item(40)
#    if: fspec.octects[0].bits[3]
#
  i070:
    value: data.items[4].item
    if: data.loop_range-1 >= 4
#  - id: i070 #,"F","2","Mode-3/A Code in Octal Representation","N.A."),
#    type: c48_item(70)
#    if: fspec.octects[0].bits[4]
#
  i090:
    value: data.items[5].item
    if: data.loop_range-1 >= 5
#  - id: i090 #,"F","2","Flight Level in Binary Representation","1/4 FL"),
#    type: c48_item(90)
#    if: fspec.octects[0].bits[5]
#
  i130:
    value: data.items[6].item
    if: data.loop_range-1 >= 6
#  - id: i130 #,"C","1+F:1,F:1,F:1,F:1,F:1,F:1,F:1,F:0","Radar Plot Characteristics","N.A."),
#    type: c48_item(130)
#    if: fspec.octects[0].bits[6]
#
  i220:
    value: data.items[7].item
    if: data.loop_range-1 >= 7
#  - id: i220 #,"F","3","Aircraft Address","N.A."),
#    type: c48_item(220)
#    if: fspec.octects.size > 1 and fspec.octects[1].bits[0]
#
  i240:
    value: data.items[8].item
    if: data.loop_range-1 >= 8
#  - id: i240 #,"F","6","Aircraft Identification","N.A."),
#    type: c48_item(240)
#    if: fspec.octects.size > 1 and fspec.octects[1].bits[1]
#
  i250:
    value: data.items[9].item
    if: data.loop_range-1 >= 9
#  - id: i250 #,"R","1+8","Mode S MB Data","N.A."),
#    type: c48_item(250)
#    if: fspec.octects.size > 1 and fspec.octects[1].bits[2]
#
  i161:
    value: data.items[10].item
    if: data.loop_range-1 >= 10
#  - id: i161 #,"F","2","Track/Plot Number","N.A."),
#    type: c48_item(161)
#    if: fspec.octects.size > 1 and fspec.octects[1].bits[3]
#
  i042:
    value: data.items[11].item
    if: data.loop_range-1 >= 11
#  - id: i042 #,"F","4","Calculated Position in Cartesian Co-ordinates","X, Y: 1/128 NM"),
#    type: c48_item(42)
#    if: fspec.octects.size > 1 and fspec.octects[1].bits[4]
#
  i200:
    value: data.items[12].item
    if: data.loop_range-1 >= 12
#  - id: i200 #,"F","4","Calculated Track Velocity in Polar Representation","Speed: (2-14) NM/s Heading:360/(2 16)"),
#    type: c48_item(200)
#    if: fspec.octects.size > 1 and fspec.octects[1].bits[5]
#
  i170:
    value: data.items[13].item
    if: data.loop_range-1 >= 13
#  - id: i170 #,"X","1+1","Track Status","N.A."),
#    type: c48_item(170)
#    if: fspec.octects.size > 1 and fspec.octects[1].bits[6]
#
#
  i210:
    value: data.items[14].item
    if: data.loop_range-1 >= 14
#  - id: i210 #,"F","4","Track Quality","N.A."),
#    type: c48_item(210)
#    if: fspec.octects.size > 2 and fspec.octects[2].bits[0]
#
  i030:
    value: data.items[15].item
    if: data.loop_range-1 >= 15
#  - id: i030 #,"X","1+1","Warning/Error Conditions","N.A."),
#    type: c48_item(30)
#    if: fspec.octects.size > 2 and fspec.octects[2].bits[1]
#
  i080:
    value: data.items[16].item
    if: data.loop_range-1 >= 16
#  - id: i080 #,"F","2","Mode-3/A Code Confidence Indicator","N.A."),
#    type: c48_item(80)
#    if: fspec.octects.size > 2 and fspec.octects[2].bits[2]
#
  i100:
    value: data.items[17].item
    if: data.loop_range-1 >= 17
#  - id: i100 #,"F","4","Mode-C Code and Confidence Indicator","N.A."),
#    type: c48_item(100)
#    if: fspec.octects.size > 2 and fspec.octects[2].bits[3]
#
  i110:
    value: data.items[18].item
    if: data.loop_range-1 >= 18
#  - id: i110 #,"F","2","Height Measured by a 3D Radar","25 ft"),
#    type: c48_item(110)
#    if: fspec.octects.size > 2 and fspec.octects[2].bits[4]
#
  i120:
    value: data.items[19].item
    if: data.loop_range-1 >= 19
#  - id: i120 #,"C","1+F:1,F:7,F:0,F:0,F:0,F:0,F:0,F:0","Radial Doppler Speed","(2-14) NM/s"),
#    type: c48_item(120)
#    if: fspec.octects.size > 2 and fspec.octects[2].bits[5]
#
  i230:
    value: data.items[20].item
    if: data.loop_range-1 >= 20
#  - id: i230 #,"F","2","Communications / ACAS Capability and Flight Status","N.A."),
#    type: c48_item(230)
#    if: fspec.octects.size > 2 and fspec.octects[2].bits[6]
#
#
  i260:
    value: data.items[21].item
    if: data.loop_range-1 >= 21
#  - id: i260 #,"F","7","ACAS Resolution Advisory Report","N.A."),
#    type: c48_item(260)
#    if: fspec.octects.size > 3 and fspec.octects[3].bits[0]
#
  i055:
    value: data.items[22].item
    if: data.loop_range-1 >= 22
#  - id: i055 #,"F","1","Mode-1 Code in Octal Representation","N.A."),
#    type: c48_item(55)
#    if: fspec.octects.size > 3 and fspec.octects[3].bits[1]
#
  i050:
    value: data.items[23].item
    if: data.loop_range-1 >= 23
#  - id: i050 #,"F","2","Mode-2 Code in Octal Representation","N.A."),
#    type: c48_item(50)
#    if: fspec.octects.size > 3 and fspec.octects[3].bits[2]
#
  i065:
    value: data.items[24].item
    if: data.loop_range-1 >= 24
#  - id: i065 #,"F","1","Mode 1 Code Confidence Indicator","N.A."),
#    type: c48_item(65)
#    if: fspec.octects.size > 3 and fspec.octects[3].bits[3]
#
  i060:
    value: data.items[25].item
    if: data.loop_range-1 >= 25
#  - id: i060 #,"F","2","Mode-2 Code Confidence Indicator","N.A."),
#    type: c48_item(60)
#    if: fspec.octects.size > 3 and fspec.octects[3].bits[4]
#
#  - id: isp #,"E","1","Special Purpose Field","N.A."),
#    type: field("E",[1],[0])
#    if: fspec.octects.size > 3 and fspec.octects[3].bits[5]
#
#  - id: ire #,"E","1","Reserved Expansion Field","N.A."),
#    type: field("E",[1],[0])
#    if: fspec.octects.size > 3 and fspec.octects[3].bits[6]
#
