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
      machine_type:
        0x0: unknown
        0x1d3: am33
        0x8664: amd64
        0x1c0: arm
        0xaa64: arm64
        0x1c4: armnt
        0xebc: ebc
        0x14c: i386
        0x200: ia64
        0x9041: m32r
        0x266: mips16
        0x366: mipsfpu
        0x466: mipsfpu16
        0x1f0: powerpc
        0x1f1: powerpcfp
        0x166: r4000
        0x5032: riscv32
        0x5064: riscv64
        0x5128: riscv128
        0x1a2: sh3
        0x1a3: sh3dsp
        0x1a6: sh4
        0x1a8: sh5
        0x1c2: thumb
        0x169: wcemipsv2
        # Not mentioned in Microsoft documentation, but widely regarded
        0x184: alpha
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
