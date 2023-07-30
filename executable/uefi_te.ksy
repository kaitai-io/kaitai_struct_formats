meta:
  id: uefi_te
  title: TE (Terse Executable) file
  application: UEFI
  file-extension:
    - efi
    - te
  xref:
    wikidata: Q83443959
  tags:
    - executable
    - firmware
  license: CC0-1.0
  ks-version: 0.7
  endian: le
doc: |
  This type of executables could be found inside the UEFI firmware. The UEFI
  firmware is stored in SPI flash memory, which is a chip soldered on a
  system's motherboard. UEFI firmware is very modular: it usually contains
  dozens, if not hundreds, of executables. To store all these separates files,
  the firmware is laid out in volumes using the Firmware File System (FFS), a
  file system specifically designed to store firmware images. The volumes
  contain files that are identified by GUIDs and each of these files contain
  one or more sections holding the data. One of these sections contains the
  actual executable image. Most of the executable images follow the PE format.
  However, some of them follow the TE format.

  The Terse Executable (TE) image format was created as a mechanism to reduce
  the overhead of the PE/COFF headers in PE32/PE32+ images, resulting in a
  corresponding reduction of image sizes for executables running in the PI
  (Platform Initialization) Architecture environment. Reducing image size
  provides an opportunity for use of a smaller system flash part.

  So the TE format is basically a stripped version of PE.

doc-ref: https://uefi.org/sites/default/files/resources/PI_Spec_1_6.pdf
seq:
  - id: te_hdr
    size: 0x28
    type: te_header
  - id: sections
    type: section
    repeat: expr
    repeat-expr: te_hdr.num_sections
types:
  te_header:
    seq:
      - id: magic
        contents: "VZ"
      - id: machine
        type: u2
        enum: machine_type
      - id: num_sections
        type: u1
      - id: subsystem
        type: u1
        enum: subsystem_enum
      - id: stripped_size
        type: u2
      - id: entry_point_addr
        type: u4
      - id: base_of_code
        type: u4
      - id: image_base
        type: u8
      - id: data_dirs
        type: header_data_dirs
    enums:
      # Don't forget to update the `machine_type` enum in `executable/microsoft_pe.ksy` when
      # you modify this one.
      #
      # https://learn.microsoft.com/en-us/windows/win32/debug/pe-format#machine-types
      machine_type:
        0x0:
          id: unknown
          doc: The content of this field is assumed to be applicable to any machine type
        0x184:
          id: alpha
          doc: Alpha AXP, 32-bit address space
        0x284:
          id: alpha64_or_axp64
          -orig-id:
            - IMAGE_FILE_MACHINE_ALPHA64
            - IMAGE_FILE_MACHINE_AXP64
          doc: |
            > Alpha 64, 64-bit address space
            or
            > AXP 64 (Same as Alpha 64)
        0x1d3:
          id: am33
          doc: Matsushita AM33
        0x8664:
          id: amd64
          doc: x64
        0x1c0:
          id: arm
          doc: ARM little endian
        0xaa64:
          id: arm64
          doc: ARM64 little endian
        0x1c4:
          id: arm_nt
          -orig-id: IMAGE_FILE_MACHINE_ARMNT
          doc: ARM Thumb-2 little endian
        0xebc:
          id: ebc
          doc: EFI byte code
        0x14c:
          id: i386
          doc: Intel 386 or later processors and compatible processors
        0x200:
          id: ia64
          doc: Intel Itanium processor family
        0x6232:
          id: loongarch32
          doc: LoongArch 32-bit processor family
        0x6264:
          id: loongarch64
          doc: LoongArch 64-bit processor family
        0x9041:
          id: m32r
          doc: Mitsubishi M32R little endian
        0x266:
          id: mips16
          doc: MIPS16
        0x366:
          id: mips_fpu
          -orig-id: IMAGE_FILE_MACHINE_MIPSFPU
          doc: MIPS with FPU
        0x466:
          id: mips16_fpu
          -orig-id: IMAGE_FILE_MACHINE_MIPSFPU16
          doc: MIPS16 with FPU
        0x1f0:
          id: powerpc
          doc: Power PC little endian
        0x1f1:
          id: powerpc_fp
          -orig-id: IMAGE_FILE_MACHINE_POWERPCFP
          doc: Power PC with floating point support
        0x166:
          id: r4000
          doc: MIPS little endian
        0x5032:
          id: riscv32
          doc: RISC-V 32-bit address space
        0x5064:
          id: riscv64
          doc: RISC-V 64-bit address space
        0x5128:
          id: riscv128
          doc: RISC-V 128-bit address space
        0x1a2:
          id: sh3
          doc: Hitachi SH3
        0x1a3:
          id: sh3_dsp
          -orig-id: IMAGE_FILE_MACHINE_SH3DSP
          doc: Hitachi SH3 DSP
        0x1a6:
          id: sh4
          doc: Hitachi SH4
        0x1a8:
          id: sh5
          doc: Hitachi SH5
        0x1c2:
          id: thumb
          doc: Thumb
        0x169:
          id: wce_mips_v2
          -orig-id: IMAGE_FILE_MACHINE_WCEMIPSV2
          doc: MIPS little-endian WCE v2
      subsystem_enum:
        0: unknown
        1: native
        2: windows_gui
        3: windows_cui
        7: posix_cui
        9: windows_ce_gui
        10: efi_application
        11: efi_boot_service_driver
        12: efi_runtime_driver
        13: efi_rom
        14: xbox
        16: windows_boot_application
  header_data_dirs:
    seq:
      - id: base_relocation_table
        type: data_dir
      - id: debug
        type: data_dir
  data_dir:
    seq:
      - id: virtual_address
        type: u4
      - id: size
        type: u4
  section:
    seq:
      - id: name
        type: str
        encoding: UTF-8
        size: 8
        pad-right: 0
      - id: virtual_size
        type: u4
      - id: virtual_address
        type: u4
      - id: size_of_raw_data
        type: u4
      - id: pointer_to_raw_data
        type: u4
      - id: pointer_to_relocations
        type: u4
      - id: pointer_to_linenumbers
        type: u4
      - id: num_relocations
        type: u2
      - id: num_linenumbers
        type: u2
      - id: characteristics
        type: u4
    instances:
      body:
        pos: pointer_to_raw_data - _root.te_hdr.stripped_size + _root.te_hdr._io.size
        size: size_of_raw_data
