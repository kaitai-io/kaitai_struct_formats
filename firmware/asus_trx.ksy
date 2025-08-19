meta:
  id: asus_trx
  title: ASUS devices .trx firmware packaging
  file-extension: trx
  license: GPL-2.0-or-later
  ks-version: 0.9
  encoding: utf-8
  endian: le
  bit-endian: le
  imports:
    - /firmware/broadcom_trx

-license: |
  Copyright (C) 2007 Jonathan Zarate
  Copyright (C) 2015 Rafał Miłecki <zajec5@gmail.com>
  And also maybe (according to copyright header in wl500g asustrx.c):
    Copyright (C) 2005 Konstantin A. Klubnichkin and Oleg I. Vdovikin
    Copyright (C) 2004  Manuel Novoa III  <mjn3@codepoet.org>

  This program is free software; you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation; either version 2 of the License, or
  (at your option) any later version.

  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
  General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with this program; if not, write to the Free Software
  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA

doc: |
  .trx file format is widely used for distribution of firmware updates of ASUS routers.

  Fundamentally, it includes a footer which acts as a safeguard
  against installing a firmware package on a wrong hardware model or
  version. If it is broadcom-based, it also may contain this header.

  trx files not necessarily contain all these headers. There are some files with `trx` extensions neither containing the header, nor the footer.

  Sample files:
    https://github.com/wl500g/wl500g/releases
    https://vampik.ru/post/1/
    https://sourceforge.net/projects/asuswrt-merlin/files/
    https://www.asus.ru/ftp/NW_TO_TEST/RT-N12C1_3.0.0.4_188.trx
    https://www.asus.ru/ftp/NW_TO_TEST/RT-AC66U_3.0.0.4_189.trx
    https://www.asus.ru/ftp/NW_TO_TEST/RT-N15U_3.0.0.4_260.trx
    https://www.asus.ru/ftp/NW_TO_TEST/RT-N66U_3.0.0.4_321.trx


doc-ref:
  - https://github.com/wl500g/wl500g/blob/master/asustrx/asustrx.c  # A well-known "Enthusiasts'" firmware (which is a continuation of the firmware bu Oleg I. Vdovikin's (known as just "Oleg's")). Contrary to the name (wl500g) supports multiple models of routers.
  - https://github.com/openwrt/openwrt/blob/052a30d65e90ac9b3359f4a23aa3024d102c178c/tools/firmware-utils/src/asustrx.c
  - https://github.com/RMerl/asuswrt-merlin.ng/blob/6b60627c8c9c5c0271e956c914afb5277f81f9c4/release/src-rt-6.x.4708/btools/fpkg.c
  - https://github.com/openwrt/openwrt/blob/7faee1bc9f9ede0e23de19d6156dc8d769431bb3/tools/firmware-utils/src/trx.c
  - https://github.com/openwrt/openwrt/blob/4d9f69322cdaaec10a8f37c67c772f5c3b21e841/tools/firmware-utils/src/otrx.c
  - https://web.archive.org/web/20190127154419/https://openwrt.org/docs/techref/header

instances:
  header:
    pos: 0
    type: broadcom_trx
    doc: this may be present, or may not. The images will still have `trx` extension even if they are not ASUS trx.
  footer:
    pos: _io.size - sizeof<footer>
    type: footer

types:
  footer:
    -orig-id: tail
    doc: A safeguard against installation of firmware to an incompatible device
    seq:
      - id: versions
        type: versions
        doc: (1.9, 2.7) is used by Enthusiasts' "wl500g" firmware
      - id: product_id
        -orig-id:
          - prod_id
          - productid
        type: strz
        size: 12
      - id: comp_hw
        type: hw_comp_info
        repeat: expr
        repeat-expr: 4
        doc: 0.02 - 2.99 is used by Enthusiasts' "wl500g" firmware
      - id: reserved
        size: 32
    types:
      hw_comp_info:
        seq:
          - id: min
            type: revision
          - id: max
            type: revision
      revision:
        seq:
          - id: major
            type: u1
          - id: minor
            type: u1
      versions:
        seq:
          - id: kernel
            type: version
          - id: rootfs
            type: version
        types:
          version:
            seq:
              - id: major
                type: u1
              - id: minor
                type: u1
