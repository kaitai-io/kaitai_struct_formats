# http://www.microsoft.com/whdc/system/platform/firmware/PECOFF.mspx
meta:
  id: microsoft_pe
  title: Microsoft PE (Portable Executable) file format
  application: Microsoft Windows
  endian: le
  ks-version: 0.7
seq:
  - id: mz1
    type: mz_placeholder
  - id: mz2
    size: mz1.header_size - 0x40
  - id: pe_signature
    contents: ["PE", 0, 0]
  - id: coff_hdr
    type: coff_header
  - id: optional_hdr
    type: optional_header
    size: coff_hdr.size_of_optional_header
  - id: sections
    repeat: expr
    repeat-expr: coff_hdr.number_of_sections
    type: section
enums:
  pe_format:
    0x107: rom_image
    0x10b: pe32
    0x20b: pe32_plus
types:
  mz_placeholder:
    seq:
      - id: magic
        contents: "MZ"
      - id: data1
        size: 0x3a
      - id: header_size
        type: u4
  coff_header:
    # 3.3. COFF File Header (Object and Image)
    seq:
      - id: machine
        type: u2
        enum: machine_type
      - id: number_of_sections
        type: u2
      - id: time_date_stamp
        type: u4
      - id: pointer_to_symbol_table
        type: u4
      - id: number_of_symbols
        type: u4
      - id: size_of_optional_header
        type: u2
      - id: characteristics
        type: u2
    enums:
      machine_type:
        # 3.3.1. Machine Types
        0x0: unknown
        0x1d3: am33
        0x8664: amd64
        0x1c0: arm
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
  optional_header:
    seq:
      - id: std
        type: optional_header_std
      - id: windows
        type: optional_header_windows
      - id: data_dirs
        type: optional_header_data_dirs
  optional_header_std:
    seq:
      - id: format
        type: u2
        enum: pe_format
      - id: major_linker_version
        type: u1
      - id: minor_linker_version
        type: u1
      - id: size_of_code
        type: u4
      - id: size_of_initialized_data
        type: u4
      - id: size_of_uninitialized_data
        type: u4
      - id: address_of_entry_point
        type: u4
      - id: base_of_code
        type: u4
      - id: base_of_data
        type: u4
        if: format == pe_format::pe32
  optional_header_windows:
    seq:
      - id: image_base_32
        type: u4
        if: _parent.std.format == pe_format::pe32
      - id: image_base_64
        type: u8
        if: _parent.std.format == pe_format::pe32_plus
      - id: section_alignment
        type: u4
      - id: file_alignment
        type: u4
      - id: major_operating_system_version
        type: u2
      - id: minor_operating_system_version
        type: u2
      - id: major_image_version
        type: u2
      - id: minor_image_version
        type: u2
      - id: major_subsystem_version
        type: u2
      - id: minor_subsystem_version
        type: u2
      - id: win32_version_value
        type: u4
      - id: size_of_image
        type: u4
      - id: size_of_headers
        type: u4
      - id: check_sum
        type: u4
      - id: subsystem
        type: u2
        enum: subsystem_enum
      - id: dll_characteristics
        type: u2
      - id: size_of_stack_reserve_32
        type: u4
        if: _parent.std.format == pe_format::pe32
      - id: size_of_stack_reserve_64
        type: u8
        if: _parent.std.format == pe_format::pe32_plus
      - id: size_of_stack_commit_32
        type: u4
        if: _parent.std.format == pe_format::pe32
      - id: size_of_stack_commit_64
        type: u8
        if: _parent.std.format == pe_format::pe32_plus
      - id: size_of_heap_reserve_32
        type: u4
        if: _parent.std.format == pe_format::pe32
      - id: size_of_heap_reserve_64
        type: u8
        if: _parent.std.format == pe_format::pe32_plus
      - id: size_of_heap_commit_32
        type: u4
        if: _parent.std.format == pe_format::pe32
      - id: size_of_heap_commit_64
        type: u8
        if: _parent.std.format == pe_format::pe32_plus
      - id: loader_flags
        type: u4
      - id: number_of_rva_and_sizes
        type: u4
    enums:
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
  optional_header_data_dirs:
    seq:
      - id: export_table
        type: data_dir
      - id: import_table
        type: data_dir
      - id: resource_table
        type: data_dir
      - id: exception_table
        type: data_dir
      - id: certificate_table
        type: data_dir
      - id: base_relocation_table
        type: data_dir
      - id: debug
        type: data_dir
      - id: architecture
        type: data_dir
      - id: global_ptr
        type: data_dir
      - id: tls_table
        type: data_dir
      - id: load_config_table
        type: data_dir
      - id: bound_import
        type: data_dir
      - id: iat
        type: data_dir
      - id: delay_import_descriptor
        type: data_dir
      - id: clr_runtime_header
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
      - id: number_of_relocations
        type: u2
      - id: number_of_linenumbers
        type: u2
      - id: characteristics
        type: u4
    instances:
      body:
        pos: pointer_to_raw_data
        size: size_of_raw_data
