meta:
  id: zyimage_footer
  license: GPL-2.0
  title: Image header used in Zyxel devices official firmware
  xref:
    wikidata: Q245283
  endian: le
  encoding: utf-8

-license: |
  Copyright (C) 2014 Soul Trace <S-trace@list.ru>

  This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License version 2 as published by the Free Software Foundation.

doc: |
  The free open source tool has been created by [S-trace](https://4pda.ru/forum/index.php?showuser=1718487), who brought OpenWRT support to Keenetic devices.
  The purpose of this footer is to prevent users from accidentially flashing an incompatible or corrupt firmware into own devices.
doc-ref: https://github.com/openwrt/openwrt/blob/master/tools/firmware-utils/src/zyimage.c

instances:
  footer:
    pos: _io.size - sizeof<footer>
    type: footer

types:
  footer:
    seq:
      - id: signature
        contents: ZNBG
      - id: device_id
        type: u4
        enum: device_id
      - id: firmware_version
        type: strz
        size: 48
      - id: crc32
        type: u4

enums:
  device_id:
    0x000417:
      id: keenetic_lite_rev_a
      doc: RT3050, 4/16
    0x004104:
      id: keenetic_lite_rev_b
      doc: RT5350, 8/32
    0x001202:
      id: keenetic_start
      doc: RT5350, 4/32
    0x001212:
      id: keenetic_4g_ii
      doc: RT5350, 4/32
    0x001300:
      id: keenetic_start_ii
      doc: MT7628NN, 16/64
    0x101312:
      id: keenetic_4g_iii_rev_a
      doc: MT7620N, 8/64
    0x001301:
      id: keenetic_4g_iii_rev_b
      doc: MT7628NN, 16/64
    0x001302:
      id: keenetic_lite_ii
      doc: MT7620N, 8/64
    0x201302:
      id: keenetic_lite_iii_rev_a
      doc: MT7620N, 8/64
    0x001311:
      id: keenetic_lite_iii_rev_b
      doc: MT7628N, 16/64
    0x001312:
      id: keenetic_omni
      doc: MT7620N, 8/64
    0x001800:
      id: keenetic_air
      doc: MT7628AN, 16/64
    0x001812:
      id: keenetic_extra_ii
      doc: MT7628AN, 32/128
    0x002325:
      id: keenetic_viva
      doc: MT7620N, 16/128
    0x002525:
      id: keenetic_extra
      doc: MT7620A, 16/128
    0x002880:
      id: keenetic_giga_iii
      doc: MT7621ST, 128/256
    0x002885:
      id: keenetic_ultra_ii
      doc: MT7621AT, 128/256
    0x004115:
      id: keenetic_4g_rev_a
      doc: RT3050, 4/32
    0x005115:
      id: keenetic_4g_rev_b
      doc: RT5350, 8/32
    0x004215:
      id: keenetic
      doc: RT3052, 8/32
    0x004310:
      id: keenetic_iii
      doc: MT7620A, 16/128
    0x004615:
      id: keenetic_giga
      doc: RT3052, 8/64
    0x005215:
      id: keenetic_ii
      doc: RT6856, 16/128
    0x005321:
      id: keenetic_lte
      doc: RT63368F, 128/128
    0x005615:
      id: keenetic_ultra
      doc: RT6856, 16/256
    0x006215:
      id: keenetic_giga_ii
      doc: RT6856, 16/256
    0x007215:
      id: keenetic_dsl
    0x0072a5:
      id: keenetic_vox
    0x201312:
      id: keenetic_omni_ii

    0x801010:
      id: kn_1010
      doc: Giga, MT7621A, 128/256
    0x801110:
      id: kn_1110
      doc: Start, MT7628N, 16/64
    0x801111:
      id: kn_1111
      doc: Starter, MT7628N, 32/64
    0x801210:
      id: kn_1210
      doc: 4G, MT7628N, 16/64
    0x801211:
      id: kn_1211
      doc: 4G (Launcher), MT7628N, 32/64
    0x801310:
      id: kn_1310
      doc: Lite, MT7628N, 16/64
    0x801311:
      id: kn_1311
      doc: Lite (Sprinter), MT7628N, 32/64
    0x801410:
      id: kn_1410
      doc: Omni, MT7628N, 32/128
    0x801510:
      id: kn_1510
      doc: City, MT7628N, 16/64
    0x801511:
      id: kn_1511
      doc: City (Glider), MT7628N, 32/128
    0x801610:
      id: kn_1610
      doc: Air, MT7628N, 16/64
    0x801611:
      id: kn_1611
      doc: Air (Explorer), MT7628N, 32/128
    0x801710:
      id: kn_1710
      doc: Extra, MT7628N, 32/128
    0x801711:
      id: kn_1711
      doc: Extra (Carrier), MT7628N, 32/128
    0x801810:
      id: kn_1810
      doc: Ultra (Titan), MT7621A, 128/256
    0x801910:
      id: kn_1910
      doc: Viva, MT7621A, 128/128
    0x802010:
      id: kn_2010
      doc: DSL, EN7512U, 128/128
    0x802110:
      id: kn_2110
      doc: Duo, EN7513T, 128/128
    0x803010:
      id: kn_3010
      doc: Speedster, MT7621A, 32/128
