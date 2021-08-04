meta:
  id: uimage
  title: U-Boot Image wrapper
  license: CC0-1.0
  endian: be
doc: |
  The new uImage format allows more flexibility in handling images of various
  types (kernel, ramdisk, etc.), it also enhances integrity protection of images
  with sha1 and md5 checksums.
doc-ref: https://source.denx.de/u-boot/u-boot/-/raw/e4dba4b/include/image.h
seq:
  - id: header
    type: uheader
  - id: data
    size: header.len_image
types:
  uheader:
    seq:
      - id: magic
        contents: [0x27, 0x05, 0x19, 0x56]
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
      - id: architecture
        type: u1
        enum: uimage_arch
      - id: image_type
        type: u1
        enum: uimage_type
      - id: compression_type
        type: u1
        enum: uimage_comp
      - id: name
        size: 32
        encoding: UTF-8
        type: strz
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
