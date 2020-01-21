meta:
  id: cat_048_catalog
  license: GPL-3.0-only
  endian: be
  imports:
#    - field
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

  Category 048 Catalog definition file

  ASTERIX Part 4 Category 048 Monoradar Target Reports
  Edition: 1.25
  Edition date: 08/08/2019
  Reference nr: EUROCONTROL-SPEC-0149-4

params:
  - id: item_ref_num
    type: s2

seq:
  - id: item
    type:
      switch-on: item_ref_num
      cases:
        0: fixed(true,1)
        10: fixed(true,2)
        20: extended(true,1,1)
        30: extended(true,1,1)
        40: fixed(true,4)
        42: fixed(true,4)
        50: fixed(true,2)
        55: fixed(true,1)
        60: fixed(true,2)
        65: fixed(true,1)
        70: fixed(true,2)
        80: fixed(true,2)
        90: fixed(true,2)
        100: fixed(true,4)
        110: fixed(true,2)
        120: compound("FFFF"+"FFF",[1,7,0,0,0,0,0],[0,0,0,0,0,0,0])
        130: compound("FFFF"+"FFF",[1,1,1,1,1,1,1],[0,0,0,0,0,0,0])
        140: fixed(true,3)
        161: fixed(true,2)
        170: extended(true,1,1)
        200: fixed(true,4)
        210: fixed(true,4)
        220: fixed(true,3)
        240: fixed(true,6)
        250: repetitive(true,8)
        230: fixed(true,2)
        260: fixed(true,7)


        #i048_010 #,"F","2","Data Source Identifier","N.A."),
        #i048_140 #,"F","3","Time of Day","1/128 s"),
        #i048_020 #,"X","1+1","Target Report Descriptor","N.A."),
        #i048_040 #,"F","4","Measured Position in Slant Polar Co-ordinates","RHO: 1/256 NM, THETA: 360/(2 16)"),
        #i048_070 #,"F","2","Mode-3/A Code in Octal Representation","N.A."),
        #i048_090 #,"F","2","Flight Level in Binary Representation","1/4 FL"),
        #i048_130 #,"C","1+F:1,F:1,F:1,F:1,F:1,F:1,F:1,F:0","Radar Plot Characteristics","N.A."),
        #i048_220 #,"F","3","Aircraft Address","N.A."),
        #i048_240 #,"F","6","Aircraft Identification","N.A."),
        #i048_250 #,"R","1+8","Mode S MB Data","N.A."),
        #i048_161 #,"F","2","Track/Plot Number","N.A."),
        #i048_042 #,"F","4","Calculated Position in Cartesian Co-ordinates","X, Y: 1/128 NM"),
        #i048_200 #,"F","4","Calculated Track Velocity in Polar Representation","Speed: (2-14) NM/s Heading:360/(2 16)"),
        #i048_170 #,"X","1+1","Track Status","N.A."),
        #i048_210 #,"F","4","Track Quality","N.A."),
        #i048_030 #,"X","1+1","Warning/Error Conditions","N.A."),
        #i048_080 #,"F","2","Mode-3/A Code Confidence Indicator","N.A."),
        #i048_100 #,"F","4","Mode-C Code and Confidence Indicator","N.A."),
        #i048_110 #,"F","2","Height Measured by a 3D Radar","25 ft"),
        #i048_120 #,"C","1+F:1,F:7,F:0,F:0,F:0,F:0,F:0,F:0","Radial Doppler Speed","(2-14) NM/s"),
        #i048_230 #,"F","2","Communications / ACAS Capability and Flight Status","N.A."),
        #i048_260 #,"F","7","ACAS Resolution Advisory Report","N.A."),
        #i048_055 #,"F","1","Mode-1 Code in Octal Representation","N.A."),
        #i048_050 #,"F","2","Mode-2 Code in Octal Representation","N.A."),
        #i048_065 #,"F","1","Mode 1 Code Confidence Indicator","N.A."),
        #i048_060 #,"F","2","Mode-2 Code Confidence Indicator","N.A."),
        #i048_sp #,"E","1","Special Purpose Field","N.A."),
        #i048_re #,"E","1","Reserved Expansion Field","N.A."),  #

enums:
  c048:
    0: i000
    10: i010
    20: i020
    30: i030
    40: i040
    42: i042
    50: i050
    55: i055
    60: i060
    65: i065
    70: i070
    80: i080
    90: i090
    100: i100
    110: i110
    120: i120
    130: i130
    140: i140
    161: i161
    170: i170
    200: i200
    210: i210
    220: i220
    240: i240
    250: i250
    230: i230
    260: i260
