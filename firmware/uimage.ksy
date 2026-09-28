meta:
  id: uimage
  title: U-Boot Image wrapper
  license: CC0-1.0
  ks-version: '0.11'
  endian: be
doc: |
  The new uImage format allows more flexibility in handling images of various
  types (kernel, ramdisk, etc.), it also enhances integrity protection of images
  with sha1 and md5 checksums.
doc-ref: https://github.com/u-boot/u-boot/blob/ece349ade2973e220f524ce59e59711cc919263f/include/image.h Git tag "v2026.07"
seq:
  - id: header
    type: uheader
  - id: data
    size: header.len_image
types:
  uheader:
    seq:
      - id: magic
        type: u4
        enum: magic_types
        valid:
          in-enum: true
      - id: header_crc
        type: u4
      - id: timestamp
        type: u4
      - id: len_image
        type: u4
      - id: load_address
        type: u4
      - id: entry_address
        type: u4
      - id: data_crc
        type: u4
      - id: os_type
        type: u1
        enum: uimage_os
        valid:
          in-enum: true
      - id: architecture
        type: u1
        enum: uimage_arch
      - id: image_type
        type: u1
        enum: uimage_type
      - id: compression_type
        type: u1
        enum: uimage_comp
        valid:
          in-enum: true
      - id: name_or_asus_info
        size: 32
        type: name_or_asus_info
  name_or_asus_info:
    seq:
      - id: name
        type: strz
        encoding: UTF-8
        eos-error: false
        if: not has_asus_info
      - id: asus_info
        type: asus_firmware_information
        if: has_asus_info
    instances:
      has_asus_info:
        value: byte0 < 0x20 and byte4 >= 0x20 and byte4 < 0x7f
        doc: |
          Whether this type stores ASUS firmware information (`asus_info`)
          rather than an image name (`name`).

          The header doesn't say which one it is, so we infer it using a
          heuristic based on the layout of the `asus_firmware_information` type.
          If ASUS firmware info is present, the first byte (the major kernel
          version number) is a small integer (i.e. not a printable character),
          and byte 4 (first byte of the product ID/model name) is a printable
          character. An empty name is not mistaken for ASUS information, because
          its byte 4 is a null byte.

          The highest known major kernel version number is 9 (e.g. in
          `DSL-N55U_9.0.0.4_380_3925-gad8f412_Annex_A.trx` from
          <https://dlcdnets.asus.com/pub/ASUS/wireless/DSL-N55U/FW_DSL_N55U_90043803925.zip>,
          released on 2016-08-04 and listed on
          <https://www.asus.com/supportonly/dsl-n55u/helpdesk_bios/>). ASUS
          seems to use such high major versions (9, sometimes 7) for beta
          releases, whereas regular releases use 3 (or 1 in older firmware).

          It can also be 0, in particular due to a bug in the MediaTek MT798X
          build of ASUS's `mkimage` (it reads the `-V` values from fixed `argv`
          positions, even though it parses the options using `getopt()` - see
          <https://github.com/blocktrron/tuf-ax4200-gpl/blob/a4fe37f4d78473f97c6d47cf93d97c3811af90cc/release/src-mtk-MT798X/Uboot-upstream/tools/mkimage.c#L317-L333>).
          For example, this is the case in
          `RT-AX52_3.0.0.4_388_34015-g9488655.trx` from
          <https://dlcdnets.asus.com/pub/ASUS/wireless/RT-AX52/FW_RT-AX52_300438834015.zip>,
          released on 2026-03-20 and listed on
          <https://www.asus.com/supportonly/rt-ax52/helpdesk_bios/>.
      byte0:
        pos: 0
        type: u1
      byte4:
        pos: 4
        type: u1
  asus_firmware_information:
    doc: |
      ASUS firmware images [overlay the 32-byte image
      name](https://github.com/drag0njoe/RT-AC55U/blob/cf5874684ab6995ee07e91a52dfdd0562fcc2655/release/src/asustools/mkimage.src/include/image.h#L185-L188)
      with a [`TAIL`
      structure](https://github.com/drag0njoe/RT-AC55U/blob/cf5874684ab6995ee07e91a52dfdd0562fcc2655/release/src/asustools/mkimage.src/include/image.h#L151-L171)
      that contains version information and the product ID (model name).

      The first 16 bytes have the same structure in all three known variants of
      the `TAIL` structure. The meaning of the last 16 bytes differs across the
      variants - therefore, for simplicity, this Kaitai Struct implementation
      treats them as an opaque byte array named `extra_info`. For an overview of
      the variants, see the documentation for `extra_info`.
    seq:
      - id: kernel_version
        type: version
      - id: fs_version
        type: version
      - id: product_id
        type: strz
        encoding: UTF-8
        size: 12
        doc: |
          In the Ralink SDK variant (see `extra_info`), the product ID field is
          actually 23 bytes long, but no known product ID is longer than 12
          bytes.
      - id: extra_info
        size: 16
        doc: |
          The structure of these bytes varies among the three known variants of
          the `TAIL` structure, and the header doesn't say which one is used:

          * Plain: 8 hardware versions (using the `version` type) - see
            <https://github.com/drag0njoe/RT-AC55U/blob/cf5874684ab6995ee07e91a52dfdd0562fcc2655/release/src/asustools/mkimage.src/include/image.h#L170>

            Sample file: `RT-AC51U_3.0.0.4_380_8591-ga8dd632.trx` from
            <https://dlcdnets.asus.com/pub/ASUS/wireless/RT-AC51U/FW_RT_AC51U_30043808591.zip>,
            released on 2020-09-22 and listed on
            <https://www.asus.com/supportonly/rt-ac51u/helpdesk_bios/>.

            Source code links:

            - [ASUS GPL source, RT-AC55UHP
              3.0.0.4.382.51915](https://dlcdnets.asus.com/pub/ASUS/wireless/RT-AC55UHP/GPL_RT_AC55UHP_300438251915.zip)
              (`asuswrt/release/src/asustools/mkimage.src/` in
              `GPL_RT-AC55UHP_3.0.0.4.382.51915-g4086e57.tgz`)
            - [ASUS GPL source, RT-AC55U 3.0.0.4.382.50702 (unofficial
              mirror)](https://github.com/drag0njoe/RT-AC55U/tree/cf5874684ab6995ee07e91a52dfdd0562fcc2655/release/src/asustools/mkimage.src)

          * `TRX_NEW` (a macro defined when building `mkimage`): the
            build number and extended build number (`u2le` each), two key bytes
            and 5 hardware versions - see
            <https://github.com/drag0njoe/RT-AC55U/blob/cf5874684ab6995ee07e91a52dfdd0562fcc2655/release/src-qca/asustools/mkimage.src/include/image.h#L174-L180>

            `mkimage` [overwrites the first 3 hardware
            versions](https://github.com/drag0njoe/RT-AC55U/blob/cf5874684ab6995ee07e91a52dfdd0562fcc2655/release/src-qca/asustools/mkimage.src/mkimage.c#L546-L569)
            with values derived from the key bytes.

            Sample file: `RT-AC55UHP_3.0.0.4_382_52236-ga0f880d.trx` (build 382,
            extended build 52236) from
            <https://dlcdnets.asus.com/pub/ASUS/wireless/RT-AC55UHP/FW_RT_AC55UHP_300438252236.zip>,
            released on 2020-06-04 and listed on
            <https://www.asus.com/supportonly/rt-ac55uhp/helpdesk_bios/>.

            Source code links:

            - [ASUS GPL source, RT-AC55UHP
              3.0.0.4.382.51915](https://dlcdnets.asus.com/pub/ASUS/wireless/RT-AC55UHP/GPL_RT_AC55UHP_300438251915.zip)
              (`asuswrt/release/src-qca/asustools/mkimage.src/` in
              `GPL_RT-AC55UHP_3.0.0.4.382.51915-g4086e57.tgz`)
            - [ASUS GPL source, RT-AC55U 3.0.0.4.382.50702 (unofficial
              mirror)](https://github.com/drag0njoe/RT-AC55U/tree/cf5874684ab6995ee07e91a52dfdd0562fcc2655/release/src-qca/asustools/mkimage.src)

          * Ralink SDK: the rest of a 23-byte product ID (see `product_id`),
            a version suffix letter and the kernel part size (called `ih_ksz`) -
            see <https://github.com/andy-padavan/rt-n56u/blob/32a93db4026cc2cff585d7008373432d888fc1aa/trunk/tools/mkimage/include/image.h#L164-L165>

            Sample file: `RP-N12_1.0.1.1f.trx` from
            <https://dlcdnets.asus.com/pub/ASUS/wireless/RP-N12/FW_RP-N12_1.0.1.1f.zip>,
            released on 2019-11-12 and listed on
            <https://www.asus.com/supportonly/rp-n12/helpdesk_bios/>.

            Source code links:

            - [ASUS GPL source, RP-N12
              1.0.1.1f](https://dlcdnets.asus.com/pub/ASUS/wireless/RP-N12/GPL_RP_N12_1011f.zip)
              (`GPL_RP-N12_source.1011f/user/mkimage/include/image.h` in
              `GPL_RP-N12_source.1011f.tar.bz2`)
            - [rt-n56u custom firmware by Andy
              Padavan](https://github.com/andy-padavan/rt-n56u/blob/32a93db4026cc2cff585d7008373432d888fc1aa/trunk/tools/mkimage/include/image.h)

          In the plain and `TRX_NEW` variants, the last 4 bytes may instead
          contain the offset of the root file system, which is [written by
          `mkimage -r`](https://github.com/drag0njoe/RT-AC55U/blob/cf5874684ab6995ee07e91a52dfdd0562fcc2655/release/src/asustools/mkimage.src/mkimage.c#L527-L542)
          as the magic byte 0xA9
          ([`ROOTFS_OFFSET_MAGIC`](https://github.com/drag0njoe/RT-AC55U/blob/cf5874684ab6995ee07e91a52dfdd0562fcc2655/release/src/asustools/mkimage.src/include/image.h#L154-L159))
          followed by the offset as a 24-bit big-endian integer.
  version:
    seq:
      - id: major
        type: u1
      - id: minor
        type: u1
enums:
  uimage_os:
    0:
      id: invalid
      doc: Invalid OS
    1:
      id: openbsd
      doc: OpenBSD
    2:
      id: netbsd
      doc: NetBSD
    3:
      id: freebsd
      doc: FreeBSD
    4:
      id: bsd4_4
      doc: 4.4BSD
    5:
      id: linux
      doc: Linux
    6:
      id: svr4
      doc: SVR4
    7:
      id: esix
      doc: Esix
    8:
      id: solaris
      doc: Solaris
    9:
      id: irix
      doc: Irix
    10:
      id: sco
      doc: SCO
    11:
      id: dell
      doc: Dell
    12:
      id: ncr
      doc: NCR
    13:
      id: lynxos
      doc: LynxOS
    14:
      id: vxworks
      doc: VxWorks
    15:
      id: psos
      doc: pSOS
    16:
      id: qnx
      doc: QNX
    17:
      id: u_boot
      doc: Firmware
    18:
      id: rtems
      doc: RTEMS
    19:
      id: artos
      doc: ARTOS
    20:
      id: unity
      doc: Unity OS
    21:
      id: integrity
      doc: INTEGRITY
    22:
      id: ose
      doc: OSE
    23:
      id: plan9
      doc: Plan 9
    24:
      id: openrtos
      doc: OpenRTOS
    25:
      id: arm_trusted_firmware
      doc: ARM Trusted Firmware
    26:
      id: tee
      doc: Trusted Execution Environment
    27:
      id: opensbi
      doc: RISC-V OpenSBI
    28:
      id: efi
      doc: EFI Firmware (e.g. GRUB2)
    29:
      id: elf
      doc: ELF Image (e.g. seL4)
  uimage_arch:
    0:
      id: invalid
      doc: Invalid CPU
    1:
      id: alpha
      doc: Alpha
    2:
      id: arm
      doc: ARM
    3:
      id: i386
      doc: Intel x86
    4:
      id: ia64
      doc: IA64
    5:
      id: mips
      doc: MIPS
    6:
      id: mips64
      doc: MIPS 64 Bit
    7:
      id: ppc
      doc: PowerPC
    8:
      id: s390
      doc: IBM S390
    9:
      id: sh
      doc: SuperH
    10:
      id: sparc
      doc: Sparc
    11:
      id: sparc64
      doc: Sparc 64 Bit
    12:
      id: m68k
      doc: M68K
    13:
      id: nios
      doc: Nios-32
    14:
      id: microblaze
      doc: MicroBlaze
    15:
      id: nios2
      doc: Nios-II
    16:
      id: blackfin
      doc: Blackfin
    17:
      id: avr32
      doc: AVR32
    18:
      id: st200
      doc: STMicroelectronics ST200
    19:
      id: sandbox
      doc: Sandbox architecture (test only)
    20:
      id: nds32
      doc: ANDES Technology - NDS32
    21:
      id: openrisc
      doc: OpenRISC 1000
    22:
      id: arm64
      doc: ARM64
    23:
      id: arc
      doc: Synopsys DesignWare ARC
    24:
      id: x86_64
      doc: AMD x86_64, Intel and Via
    25:
      id: xtensa
      doc: Xtensa
    26:
      id: riscv
      doc: RISC-V
  uimage_comp:
    0:
      id: none
      doc: No Compression Used
    1: gzip
    2: bzip2
    3: lzma
    4: lzo
    5: lz4
    6: zstd
  uimage_type:
    0:
      id: invalid
      doc: Invalid Image
    1:
      id: standalone
      doc: Standalone Program
    2:
      id: kernel
      doc: OS Kernel Image
    3:
      id: ramdisk
      doc: RAMDisk Image
    4:
      id: multi
      doc: Multi-File Image
    5:
      id: firmware
      doc: Firmware Image
    6:
      id: script
      doc: Script file
    7:
      id: filesystem
      doc: Filesystem Image (any type)
    8:
      id: flatdt
      doc: Binary Flat Device Tree Blob
    9:
      id: kwbimage
      doc: Kirkwood Boot Image
    10:
      id: imximage
      doc: Freescale IMXBoot Image
    11:
      id: ublimage
      doc: Davinci UBL Image
    12:
      id: omapimage
      doc: TI OMAP Config Header Image
    13:
      id: aisimage
      doc: TI Davinci AIS Image
    14:
      id: kernel_noload
      doc: OS Kernel Image, can run from any load address
    15:
      id: pblimage
      doc: Freescale PBL Boot Image
    16:
      id: mxsimage
      doc: Freescale MXSBoot Image
    17:
      id: gpimage
      doc: TI Keystone GPHeader Image
    18:
      id: atmelimage
      doc: ATMEL ROM bootable Image
    19:
      id: socfpgaimage
      doc: Altera SOCFPGA CV/AV Preloader
    20:
      id: x86_setup
      doc: x86 setup.bin Image
    21:
      id: lpc32xximage
      doc: x86 setup.bin Image
    22:
      id: loadable
      doc: A list of typeless images
    23:
      id: rkimage
      doc: Rockchip Boot Image
    24:
      id: rksd
      doc: Rockchip SD card
    25:
      id: rkspi
      doc: Rockchip SPI image
    26:
      id: zynqimage
      doc: Xilinx Zynq Boot Image
    27:
      id: zynqmpimage
      doc: Xilinx ZynqMP Boot Image
    28:
      id: zynqmpbif
      doc: Xilinx ZynqMP Boot Image (bif)
    29:
      id: fpga
      doc: FPGA Image
    30:
      id: vybridimage
      doc: VYBRID .vyb Image
    31:
      id: tee
      doc: Trusted Execution Environment OS Image
    32:
      id: firmware_ivt
      doc: Firmware Image with HABv4 IVT
    33:
      id: pmmc
      doc: TI Power Management Micro-Controller Firmware
    34:
      id: stm32image
      doc: STMicroelectronics STM32 Image
    35:
      id: socfpgaimage_v1
      doc: Altera SOCFPGA A10 Preloader
    36:
      id: mtkimage
      doc: MediaTek BootROM loadable Image
    37:
      id: imx8mimage
      doc: Freescale IMX8MBoot Image
    38:
      id: imx8image
      doc: Freescale IMX8Boot Image
    39:
      id: copro
      doc: Coprocessor Image for remoteproc
    40:
      id: sunxi_egon
      doc: Allwinner eGON Boot Image
    41:
      id: sunxi_toc0
      doc: Allwinner TOC0 Boot Image
    42:
      id: fdt_legacy
      doc: Binary Flat Device Tree Blob in a Legacy Image
    43:
      id: renesas_spkg
      doc: Renesas SPKG image
    44:
      id: starfive_spl
      doc: StarFive SPL image
    45:
      id: tfa_bl31
      doc: TFA BL31 image
    46:
      id: stm32image_v2
      doc: STMicroelectronics STM32 Image V2.0
    47:
      id: amlimage
      doc: Amlogic Boot Image
  magic_types:
    0x27051956:
      id: uimage
      doc: The standard U-Boot header magic.
    0x83800000:
      id: bix
      doc: An adapted magic used by ZyXEL and Cisco
      doc-ref: https://github.com/ReFirmLabs/binwalk/pull/482/commits/f21282bce5b699fe627102a0b647416acd54933b
    0x80800002:
      id: bix2
      doc: A variant of the .bix header found in the EnGenius ECS1112FP
    0x93000000:
      id: bix3
      doc: A variant of the .bix header found in the EnGenius ECS1528FP
