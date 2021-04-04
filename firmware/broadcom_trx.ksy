meta:
  id: broadcom_trx
  title: Broadcom devices .trx firmware packaging
  file-extension: trx
  license: GPL-2.0-or-later
  ks-version: 0.9
  bit-endian: le
  encoding: utf-8
  endian: le

-license: |
  Copyright (C) 2004  Manuel Novoa III  <mjn3@codepoet.org>

  This program is free software; you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation; either version 2 of the License, or
  (at your option) any later version.

  This program is distributed in the hope that it will be useful, but
  WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
  General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with this program; if not, write to the Free Software
  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307
  USA

doc: |
  .trx file format is widely used for distribution of firmware
  updates for Broadcom devices. The most well-known are ASUS routers.

  Fundamentally, it includes a footer which acts as a safeguard
  against installing a firmware package on a wrong hardware model or
  version, and a header which list numerous partitions packaged inside
  a single .trx file.

  trx files not necessarily contain all these headers.

doc-ref:
  - https://github.com/openwrt/openwrt/blob/3f5619f/tools/firmware-utils/src/trx.c
  - https://web.archive.org/web/20190127154419/https://openwrt.org/docs/techref/header
  - https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/Documentation/devicetree/bindings/mtd/partitions/brcm,trx.txt

instances:
  header:
    pos: 0
    type: header
  tail:
    pos: _io.size - sizeof<tail>
    type: tail

types:
  revision:
    seq:
      - id: major
        type: u1
      - id: minor
        type: u1
  version:
    seq:
      - id: major
        type: u1
      - id: minor
        type: u1
      - id: patch
        type: u1
      - id: tweak
        type: u1

  tail:
    doc: "A safeguard against installation of firmware to an incompatible device"
    seq:
      - id: version
        type: version
        doc: "1.9.2.7 by default"
      - id: product_id
        type: strz
        size: 12
      - id: comp_hw
        type: hw_comp_info
        repeat: expr
        repeat-expr: 4
        doc: "0.02 - 2.99"
      - id: reserved
        size: 32
    types:
      hw_comp_info:
        seq:
          - id: min
            type: revision
          - id: max
            type: revision

  header:
    seq:
      - id: magic
        contents: "HDR0"
      - id: len
        type: u4
        doc: Length of file including header
      - id: crc32
        type: u4
        doc: "CRC from `version` (??? todo: see the original and disambiguate) to end of file"
      - id: version
        type: u2
      - id: flags
        type: flags
      - id: partitions
        type: partition(_index)
        doc: "Offsets of partitions from start of header"
        repeat: until
        repeat-until: _index >= 4 or not _.is_present

    types:
      partition:
        params:
          - id: idx
            type: u1
        seq:
          - id: ofs_body
            type: u4
        instances:
          is_present:
            value: ofs_body != 0
          is_last:
            value: "(idx == _parent.partitions.size - 1) or (not _parent.partitions[idx + 1].is_present)"
            if: is_present
          len_body:
            value: "is_last ? (_root._io.size - ofs_body) : _parent.partitions[idx + 1].ofs_body"
            if: is_present
          body:
            io: _root._io
            pos: ofs_body
            size: len_body
            if: is_present
      flags:
        seq:
          - id: flags
            type: b1
            repeat: expr
            repeat-expr: 16
