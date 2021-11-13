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
doc-ref: https://docs.microsoft.com/en-us/windows/win32/debug/pe-format
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
      machine_type:
        # 3.3.1. Machine Types
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
    instances:
      body:
        pos: pointer_to_raw_data
        size: size_of_raw_data
  certificate_table:
    seq:
      - id: items
        type: certificate_entry
        repeat: eos
  certificate_entry:
    doc-ref: 'https://docs.microsoft.com/en-us/windows/desktop/debug/pe-format#the-attribute-certificate-table-image-only'
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
