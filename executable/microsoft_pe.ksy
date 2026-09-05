meta:
  id: microsoft_pe
  title: Microsoft PE (Portable Executable) file format
  application: Microsoft Windows
  file-extension:
    - exe
    - dll
    - sys
  xref:
    justsolve: Portable_Executable
    pronom: x-fmt/411
    wikidata: Q1076355
  tags:
    - executable
    - windows
  license: CC0-1.0
  ks-version: 0.7
  endian: le
doc-ref: https://learn.microsoft.com/en-us/windows/win32/debug/pe-format
seq:
  - id: mz
    type: mz_placeholder
instances:
  pe:
    pos: mz.ofs_pe
    type: pe_header
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
      - id: ofs_pe
        type: u4
        doc: In PE file, an offset to PE header
  pe_header:
    seq:
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
    instances:
      certificate_table:
        pos: optional_hdr.data_dirs.certificate_table.virtual_address
        size: optional_hdr.data_dirs.certificate_table.size
        type: certificate_table
        if: optional_hdr.data_dirs.certificate_table.virtual_address != 0
  coff_header:
    doc-ref: 3.3. COFF File Header (Object and Image)
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
    instances:
      symbol_table_size:
        value: number_of_symbols * 18
      symbol_name_table_offset:
        value: pointer_to_symbol_table + symbol_table_size
      symbol_name_table_size:
        pos: symbol_name_table_offset
        type: u4
      symbol_table:
        pos: pointer_to_symbol_table
        type: coff_symbol
        repeat: expr
        repeat-expr: number_of_symbols
    enums:
      # Don't forget to update the `machine_type` enum in `executable/uefi_te.ksy` when
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
  coff_symbol:
    seq:
      - id: name_annoying
        type: annoyingstring
        size: 8
      #- id: name_zeroes
      #  type: u4
      #- id: name_offset
      #  type: u4
      - id: value
        type: u4
      - id: section_number
        type: u2
      - id: type
        type: u2
      - id: storage_class
        type: u1
      - id: number_of_aux_symbols
        type: u1
    instances:
      #effective_name:
      #  value: name_zeroes == 0 ? name_from_offset : '"fixme"'
      #name_from_offset:
      #  io: _root._io
      #  pos: name_zeroes == 0 ? _parent.symbol_name_table_offset + name_offset : 0
      #  type: str
      #  terminator: 0
      #  encoding: ascii
      section:
        value: _root.pe.sections[section_number - 1]
      data:
        pos: section.pointer_to_raw_data + value
        size: 1
  annoyingstring:
    -webide-representation: '{name}'
    instances:
      name_zeroes:
        pos: 0
        type: u4
      name_offset:
        pos: 4
        type: u4
      name_from_offset:
        io: _root._io
        pos: 'name_zeroes == 0 ? _parent._parent.symbol_name_table_offset + name_offset : 0'
        type: str
        terminator: 0
        eos-error: false
        encoding: ascii
        if: name_zeroes == 0
      name_from_short:
        pos: 0
        type: str
        terminator: 0
        eos-error: false
        encoding: ascii
        if: name_zeroes != 0
      name:
        value: 'name_zeroes == 0 ? name_from_offset : name_from_short'
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
        16: windows_boot_application
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
    -webide-representation: "{name}"
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
        enum: section_flags
    instances:
      body:
        pos: pointer_to_raw_data
        size: size_of_raw_data
    enums:
      section_flags:
        0x00000000:
          id: reserved1
          -orig-id: Reserved1
          doc: |
            Reserved for future use.
        0x00000001:
          id: reserved2
          -orig-id: Reserved2
          doc: |
            Reserved for future use.
        0x00000002:
          id: reserved3
          -orig-id: Reserved3
          doc: |
            Reserved for future use.
        0x00000004:
          id: reserved4
          -orig-id: Reserved4
          doc: |
            Reserved for future use.
        0x00000008:
          id: image_scn_type_no_pad
          -orig-id: IMAGE_SCN_TYPE_NO_PAD
          doc: |
            The section should not be padded to the next boundary. This flag
            is obsolete and is replaced by IMAGE_SCN_ALIGN_1BYTES. This is
            valid only for object files.
        0x00000010:
          id: reserved5
          -orig-id: Reserved5
          doc: |
            Reserved for future use.
        0x00000020:
          id: image_scn_cnt_code
          -orig-id: IMAGE_SCN_CNT_CODE
          doc: |
            The section contains executable code.
        0x00000040:
          id: image_scn_cnt_initialized_data
          -orig-id: IMAGE_SCN_CNT_INITIALIZED_DATA
          doc: |
            The section contains initialized data.
        0x00000080:
          id: image_scn_cnt_uninitialized_data
          -orig-id: IMAGE_SCN_CNT_UNINITIALIZED_DATA
          doc: |
            The section contains uninitialized data.
        0x00000100:
          id: image_scn_lnk_other
          -orig-id: IMAGE_SCN_LNK_OTHER
          doc: |
            Reserved for future use.
        0x00000200:
          id: image_scn_lnk_info
          -orig-id: IMAGE_SCN_LNK_INFO
          doc: |
            The section contains comments or other information. The .drectve
            section has this type. This is valid for object files only.
        0x00000400:
          id: reserved6
          -orig-id: Reserved6
          doc: |
            Reserved for future use.
        0x00000800:
          id: image_scn_lnk_remove
          -orig-id: IMAGE_SCN_LNK_REMOVE
          doc: |
            The section will not become part of the image. This is valid only
            for object files.
        0x00001000:
          id: image_scn_lnk_comdat
          -orig-id: IMAGE_SCN_LNK_COMDAT
          doc: |
            The section contains COMDAT data. For more information see COMDAT
            Sections (Object Only). This is valid only for object files.
        0x00008000:
          id: image_scn_gprel
          -orig-id: IMAGE_SCN_GPREL
          doc: |
            The section contains data referenced through the global pointer
            (GP).
        0x00020000:
          id: image_scn_mem_purgeable
          -orig-id: IMAGE_SCN_MEM_PURGEABLE
          doc: |
            Reserved for future use.
        0x00020000:
          id: image_scn_mem_16bit
          -orig-id: IMAGE_SCN_MEM_16BIT
          doc: |
            Reserved for future use.
        0x00040000:
          id: image_scn_mem_locked
          -orig-id: IMAGE_SCN_MEM_LOCKED
          doc: |
            Reserved for future use.
        0x00080000:
          id: image_scn_mem_preload
          -orig-id: IMAGE_SCN_MEM_PRELOAD
          doc: |
            Reserved for future use.
        0x00100000:
          id: image_scn_align_1bytes
          -orig-id: IMAGE_SCN_ALIGN_1BYTES
          doc: |
            Align data on a 1-byte boundary. Valid only for object files.
        0x00200000:
          id: image_scn_align_2bytes
          -orig-id: IMAGE_SCN_ALIGN_2BYTES
          doc: |
            Align data on a 2-byte boundary. Valid only for object files.
        0x00300000:
          id: image_scn_align_4bytes
          -orig-id: IMAGE_SCN_ALIGN_4BYTES
          doc: |
            Align data on a 4-byte boundary. Valid only for object files.
        0x00400000:
          id: image_scn_align_8bytes
          -orig-id: IMAGE_SCN_ALIGN_8BYTES
          doc: |
            Align data on an 8-byte boundary. Valid only for object files.
        0x00500000:
          id: image_scn_align_16bytes
          -orig-id: IMAGE_SCN_ALIGN_16BYTES
          doc: |
            Align data on a 16-byte boundary. Valid only for object files.
        0x00600000:
          id: image_scn_align_32bytes
          -orig-id: IMAGE_SCN_ALIGN_32BYTES
          doc: |
            Align data on a 32-byte boundary. Valid only for object files.
        0x00700000:
          id: image_scn_align_64bytes
          -orig-id: IMAGE_SCN_ALIGN_64BYTES
          doc: |
            Align data on a 64-byte boundary. Valid only for object files.
        0x00800000:
          id: image_scn_align_128bytes
          -orig-id: IMAGE_SCN_ALIGN_128BYTES
          doc: |
            Align data on a 128-byte boundary. Valid only for object files.
        0x00900000:
          id: image_scn_align_256bytes
          -orig-id: IMAGE_SCN_ALIGN_256BYTES
          doc: |
            Align data on a 256-byte boundary. Valid only for object files.
        0x00A00000:
          id: image_scn_align_512bytes
          -orig-id: IMAGE_SCN_ALIGN_512BYTES
          doc: |
            Align data on a 512-byte boundary. Valid only for object files.
        0x00B00000:
          id: image_scn_align_1024bytes
          -orig-id: IMAGE_SCN_ALIGN_1024BYTES
          doc: |
            Align data on a 1024-byte boundary. Valid only for object files.
        0x00C00000:
          id: image_scn_align_2048bytes
          -orig-id: IMAGE_SCN_ALIGN_2048BYTES
          doc: |
            Align data on a 2048-byte boundary. Valid only for object files.
        0x00D00000:
          id: image_scn_align_4096bytes
          -orig-id: IMAGE_SCN_ALIGN_4096BYTES
          doc: |
            Align data on a 4096-byte boundary. Valid only for object files.
        0x00E00000:
          id: image_scn_align_8192bytes
          -orig-id: IMAGE_SCN_ALIGN_8192BYTES
          doc: |
            Align data on an 8192-byte boundary. Valid only for object files.
        0x01000000:
          id: image_scn_lnk_nreloc_ovfl
          -orig-id: IMAGE_SCN_LNK_NRELOC_OVFL
          doc: |
            The section contains extended relocations.
        0x02000000:
          id: image_scn_mem_discardable
          -orig-id: IMAGE_SCN_MEM_DISCARDABLE
          doc: |
            The section can be discarded as needed.
        0x04000000:
          id: image_scn_mem_not_cached
          -orig-id: IMAGE_SCN_MEM_NOT_CACHED
          doc: |
            The section cannot be cached.
        0x08000000:
          id: image_scn_mem_not_paged
          -orig-id: IMAGE_SCN_MEM_NOT_PAGED
          doc: |
            The section is not pageable.
        0x10000000:
          id: image_scn_mem_shared
          -orig-id: IMAGE_SCN_MEM_SHARED
          doc: |
            The section can be shared in memory.
        0x20000000:
          id: image_scn_mem_execute
          -orig-id: IMAGE_SCN_MEM_EXECUTE
          doc: |
            The section can be executed as code.
        0x40000000:
          id: image_scn_mem_read
          -orig-id: IMAGE_SCN_MEM_READ
          doc: |
            The section can be read.
        0x80000000:
          id: image_scn_mem_write
          -orig-id: IMAGE_SCN_MEM_WRITE
          doc: |
            The section can be written to.
  certificate_table:
    seq:
      - id: items
        type: certificate_entry
        repeat: eos
  certificate_entry:
    doc-ref: 'https://learn.microsoft.com/en-us/windows/win32/debug/pe-format#the-attribute-certificate-table-image-only'
    enums:
      certificate_revision:
        0x0100:
          id: revision_1_0
          doc: |
            Version 1, legacy version of the Win_Certificate structure.
            It is supported only for purposes of verifying legacy Authenticode signatures
        0x0200:
          id: revision_2_0
          doc: Version 2 is the current version of the Win_Certificate structure.
      certificate_type_enum:
        0x0001:
          id: x509
          doc: |
            bCertificate contains an X.509 Certificate
            Not Supported
        0x0002:
          id: pkcs_signed_data
          doc: 'bCertificate contains a PKCS#7 SignedData structure'
        0x0003:
          id: reserved_1
          doc: 'Reserved'
        0x0004:
          id: ts_stack_signed
          doc: |
            Terminal Server Protocol Stack Certificate signing
            Not Supported
    seq:
      - id: length
        -orig-id: dwLength
        type: u4
        doc: Specifies the length of the attribute certificate entry.
      - id: revision
        -orig-id: wRevision
        type: u2
        enum: certificate_revision
        doc: Contains the certificate version number.
      - id: certificate_type
        -orig-id: wCertificateType
        type: u2
        enum: certificate_type_enum
        doc: Specifies the type of content in bCertificate
      - id: certificate_bytes
        -orig-id: bCertificate
        size: length - 8
        doc: Contains a certificate, such as an Authenticode signature.
