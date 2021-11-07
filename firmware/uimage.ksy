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
        type: u4
        enum: magic_types
        valid:
          any-of:
            - magic_types::uimage
            - magic_types::bix
            - magic_types::bix2
            - magic_types::bix3
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
          any-of:
            - uimage_os::invalid
            - uimage_os::openbsd
            - uimage_os::netbsd
            - uimage_os::freebsd
            - uimage_os::bsd4_4
            - uimage_os::linux
            - uimage_os::svr4
            - uimage_os::esix
            - uimage_os::solaris
            - uimage_os::irix
            - uimage_os::sco
            - uimage_os::dell
            - uimage_os::ncr
            - uimage_os::lynxos
            - uimage_os::vxworks
            - uimage_os::psos
            - uimage_os::qnx
            - uimage_os::u_boot
            - uimage_os::rtems
            - uimage_os::artos
            - uimage_os::unity
            - uimage_os::integrity
            - uimage_os::ose
            - uimage_os::plan9
            - uimage_os::openrtos
            - uimage_os::arm_trusted_firmware
            - uimage_os::tee
            - uimage_os::opensbi
            - uimage_os::efi
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
          any-of:
            - uimage_comp::none
            - uimage_comp::gzip
            - uimage_comp::bzip2
            - uimage_comp::lzma
            - uimage_comp::lzo
            - uimage_comp::lz4
            - uimage_comp::lzstd
      - id: name_or_asus_info
        size: 32
        type: name_or_asus_info
    instances:
      name:
        value: name_or_asus_info.name
      asus_info:
        value: name_or_asus_info.asus_info
  name_or_asus_info:
    seq:
      - id: name
        encoding: UTF-8
        type: strz
    instances:
      asus_info:
        pos: 0
        type: asus_firmware_information
  asus_firmware_information:
    seq:
      - id: kernel_version
        type: version
      - id: fs_version
        type: version
      - id: product_id
        type: strz
        encoding: UTF-8
        size: 12
      - id: hardware_versions
        type: version
        repeat: expr
        repeat-expr: 8
    doc: |
      ASUS has overloaded the name field and stores information about the
      firmware here, including version information and the product ID.
      This is documented in for example the GPL source code of the RT-AC55UHP
      device, in the directory `release/src/asustools/mkimage.src/include/image.h`
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
