meta:
  id: broadcom_trx
  title: Broadcom devices .trx firmware packaging
  file-extension: trx
  license: ISC
  ks-version: 0.9
  encoding: utf-8
  endian: le
  bit-endian: le

-license: |
  Copyright (C) 1999-2013, Broadcom Corporation

  Permission to use, copy, modify, and/or distribute this software for any
  purpose with or without fee is hereby granted, provided that the above
  copyright notice and this permission notice appear in all copies.

  THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
  WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
  MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY
  SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
  WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION
  OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF OR IN
  CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.

doc: |
  .trx file format is widely used for distribution of firmware for Broadcom devices.

  Fundamentally, it is a header which list numerous partitions packaged inside
  a single .trx file.

doc-ref:
  - https://android.googlesource.com/platform/hardware/broadcom/wlan/+/9eecfb9718ca9f68ce446efa0252774dad404f87/bcmdhd/dhdutil/include/trxhdr.h  # ISC, primary sources
  - https://android.googlesource.com/platform/hardware/broadcom/wlan/+/9eecfb9718ca9f68ce446efa0252774dad404f87/bcmdhd/dhdutil/dhdu.c  # ISC, primary sources
  - https://github.com/openwrt/openwrt/blob/7faee1bc9f9ede0e23de19d6156dc8d769431bb3/tools/firmware-utils/src/trx.c  # GPL-2.0-or-later
  - https://github.com/openwrt/openwrt/blob/052a30d65e90ac9b3359f4a23aa3024d102c178c/tools/firmware-utils/src/asustrx.c  # GPL-2.0-or-later
  - https://github.com/openwrt/openwrt/blob/4d9f69322cdaaec10a8f37c67c772f5c3b21e841/tools/firmware-utils/src/otrx.c  # GPL-2.0-or-later
  - https://github.com/RMerl/asuswrt-merlin.ng/blob/6b60627c8c9c5c0271e956c914afb5277f81f9c4/release/src-rt-6.x.4708/btools/fpkg.c  # GPL-2.0-or-later
  - https://web.archive.org/web/20190127154419/https://openwrt.org/docs/techref/header  # CC-BY-SA
  - https://github.com/ffainelli/firmware-tools/blob/90c8921bb24f71d534c4e519701399691641f681/untrx.c  # proprietary if proven otherwise. The sentence granting rights from 0BSD is missing.
  - https://github.com/NetBSD/src/blob/05082e19134c05f2f4b6eca73223cdc6b5ab09bf/sys/dev/usb/if_bwfm_usb.c  # ISC
  - https://github.com/openbsd/src/blob/2207c4325726fdc5c4bcd0011af0fdf7d3dab137/sys/dev/usb/if_bwfm_usb.c  # ISC
  - https://github.com/torvalds/linux/blob/c06a2ba62fc401b7aaefd23f5d0bc06d2457ccc1/Documentation/devicetree/bindings/mtd/partitions/brcm%2Ctrx.txt  # GPL-2.0-or-only
  - https://github.com/torvalds/linux/blob/c06a2ba62fc401b7aaefd23f5d0bc06d2457ccc1/drivers/mtd/parsers/parser_trx.c  # GPL-2.0-or-only
  - https://github.com/torvalds/linux/blob/c06a2ba62fc401b7aaefd23f5d0bc06d2457ccc1/drivers/mtd/parsers/bcm47xxpart.c#L45  # GPL-2.0-or-only

seq:
  - id: pre_header
    type: pre_header
  - id: flags
    -orig-id: flag_version
    type: flags
  - id: version
    -orig-id: flag_version
    type: u2
    valid:
      min: 1
      max: 2
  - id: partitions
    -orig-id: offsets
    type: partition(_index)
    repeat: until
    repeat-until: _index >= max_partition_idx or not _.is_present

instances:
  max_partition_count:
    value: "3 + (version >= 2 ? 1 : 0)"
    doc: Upper bound for count of partitions for this format version. Real count of partitions can be lower, if some partitions are not present.
  max_partition_idx:
    value: max_partition_count - 1
    doc: Upper bound for partition index for this format version.
  crc32_input:
    pos: sizeof<pre_header>
    size: pre_header.length - sizeof<pre_header>
  crc32:
    value: (~pre_header.jamcrc32 & 0xffff_ffff)
    doc: ISO 3309 HDLC CRC of `crc_material`. For python you can use `zlib.crc32`.

types:
  pre_header:
    seq:
      - id: magic
        contents: HDR0
      - id: length
        -orig-id: len
        type: u4
        doc: Length of file including header
      - id: jamcrc32
        -orig-id: crc32
        type: u4
        doc: JAMCRC - bitwise not of CRC. In Python you can get it as `~zlib.crc32(p.header.crc_material) & 0xffff_ffff`
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
        value: (idx == _parent.max_partition_idx) or (not _parent.partitions[idx + 1].is_present)
        if: is_present
      len_body:
        value: "is_last ? (_root._io.size - ofs_body) : (_parent.partitions[idx + 1].ofs_body - ofs_body)"
        if: is_present
      body:
        io: _root._io
        pos: ofs_body
        size: len_body
        if: is_present
      usual_purpose:
        value: idx
        enum: usual_purpose
    enums:
      usual_purpose:
        0: bootloader
        1: kernel
        2: rootfs
        3: some_header

  flags:
    doc: "the names of these flags will probably be changed: the names of Broadcom ones are a bit unclear"
    seq:
      - id: unkn1
        type: b1
      - id: is_gzipped_files
        -orig-id: TRX_GZ_FILES
        type: b1
      - id: contains_overlays
        -orig-id: TRX_OVERLAYS
        type: b1
        doc-ref: https://github.com/CyanogenMod/lge-kernel-sniper/blob/9907b1312e9b4c5c4f73ac9bf2e772b12e1c9145/drivers/net/wireless/bcm43291/src/dhd/exe/dhdu.c#L1622-L1721  # GPL-2.0-only with the exception allowing linking the unmodified binaries to own code with own licenses
      - id: contains_microcode
        -orig-id: TRX_EMBED_UCODE
        type: b1
        doc-ref: https://github.com/seemoo-lab/nexmon/blob/297ec9f4e591cee9d7256fa95d644d815222d9e5/utilities/dhdutil/ucode_download.c#L130  # ISC
      - id: is_rom_simulation
        -orig-id: TRX_ROMSIM_IMAGE
        type: b1
      - id: is_uncompressed
        -orig-id: TRX_UNCOMP_IMAGE
        type: b1
        doc: The image is uncompressed
      - id: is_bootloader
        -orig-id: TRX_BOOTLOADER
        type: b1
      - id: unkn
        type: b1
        repeat: expr
        repeat-expr: 9
