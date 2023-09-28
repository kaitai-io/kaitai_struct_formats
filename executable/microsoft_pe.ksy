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
      resources_table:
        pos: optional_hdr.data_dirs.resource_table.pointer_to_raw_data
        size: optional_hdr.data_dirs.resource_table.size
        type: resource_directory_table
        if: optional_hdr.data_dirs.resource_table.size > 0
      dotnet_header:
        pos: optional_hdr.data_dirs.clr_runtime_header.pointer_to_raw_data
        size: optional_hdr.data_dirs.clr_runtime_header.size
        type: dotnet_header
        if: optional_hdr.data_dirs.clr_runtime_header.virtual_address != 0
      dotnet_metadata_header:
        pos: dotnet_header.meta_data.pointer_to_raw_data
        size: dotnet_header.meta_data.size
        type: dotnet_metadata_header
        if: optional_hdr.data_dirs.clr_runtime_header.virtual_address != 0 and dotnet_header.meta_data.size != 0
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
    to-string: |
      'Data Directory <VirtualAddr: ' + virtual_address.to_s + ', Size: ' + size.to_s + ', PointerToRawData: ' + pointer_to_raw_data.to_s + '>'
    seq:
      - id: virtual_address
        type: u4
      - id: size
        type: u4
    instances:
      sections_lookup:
        type: sections_lookup(virtual_address)
      pointer_to_raw_data:
        value: >
          (sections_lookup.has_section ?
          (sections_lookup.section.pointer_to_raw_data + (virtual_address - sections_lookup.section.virtual_address)) :
          0)
  section:
    -webide-representation: "{name}"
    to-string: |
      'Section <Name: ' + name + ', VirtualSize: ' + virtual_size.to_s + ', VirtualAddr: ' + virtual_address.to_s + ', PointerToRawData: ' + pointer_to_raw_data.to_s + '>'
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

  # Recursive lookup inside of sections to return pointer_to_raw data of dat_dir
  lookup_iteration:
    params:
      - id: idx
        type: u4
      - id: virtual_address
        type: u4
    instances:
      section:
        value: _root.pe.sections[idx]
      found:
        value: "virtual_address >= section.virtual_address and virtual_address <= section.virtual_address + section.size_of_raw_data"
      next_idx:
        value: "idx + (idx < _root.pe.coff_hdr.number_of_sections ? 1 : 0)"
      has_next:
        value: next_idx > idx
  sections_lookup:
    to-string: |
      'Session lockup <VirtualAddr: ' + virtual_address.to_s + ', Sections: ' + tmp_sections.size.to_s + '>'
    params:
      - id: virtual_address
        type: u4
    seq:
      - id: tmp_sections
        type: "lookup_iteration(_index, virtual_address)"
        repeat: until
        repeat-until: _.found or not _.has_next
    instances:
      section:
        value: tmp_sections.last.section
        if: tmp_sections.size > 0
      has_section:
        value: tmp_sections.size > 0 and tmp_sections.last.found

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

  resource_directory_table:
    to-string: |
      'Res dir table <Named entries: ' + number_of_named_entries.to_s + ', ID entries: ' + number_of_id_entries.to_s + '>'
    seq:
      - id: characteristics
        type: u4
      - id: time_date_stamp
        type: u4
      - id: major_version
        type: u2
      - id: minor_version
        type: u2
      - id: number_of_named_entries
        type: u2
      - id: number_of_id_entries
        type: u2
      - id: items
        repeat: expr
        repeat-expr: number_of_named_entries + number_of_id_entries
        type: resource_directory_entry

  resource_directory_entry:
    to-string: |
      'Res entry <Type: ' + name_type.to_i.to_s + ', Name Addr: ' + name_address.to_s + ', Dir Addr: ' + directory_address.to_s + ', PointerToRawData: ' + pointer_to_raw_data.to_s + ', Data Size: ' + data_size.to_s + '>'
    seq:
      - id: name_offset
        type: u4
      - id: offset_to_data
        type: u4

    instances:
      is_name_string:
        value: (name_offset & 0x80000000) > 0
      is_directory:
        value: (offset_to_data & 0x80000000) > 0
      is_data_entry:
        value: not is_name_string and not is_directory
      name_address:
        value: (name_offset & 0x7FFFFFFF)
      directory_address:
        value: (offset_to_data & 0x7FFFFFFF)
      name_type:
        enum: directory_entry_type
        value: >
           is_name_string ? directory_entry_type::undefined : name_address
      pointer_to_raw_data:
        value: >
          is_data_entry ?
          _root.pe.optional_hdr.data_dirs.resource_table.sections_lookup.section.pointer_to_raw_data + offset_to_data :
          _root.pe.optional_hdr.data_dirs.resource_table.sections_lookup.section.pointer_to_raw_data + directory_address
      directory_table:
        pos: directory_address
        type: resource_directory_table
        if: is_directory
      data_size:
        pos: directory_address
        type: u4
        if: is_data_entry

    enums:
      directory_entry_type:
        0x00: undefined
        0x01: cursor
        0x02: bitmap
        0x03: icon
        0x04: menu
        0x05: dialog
        0x06: string
        0x07: fontdir
        0x08: font
        0x09: accelerator
        0x0a: rcdata
        0x0b: messagetable
        0x0c: group_cursor2
        0x0e: group_cursor4
        0x10: version
        0x11: dlginclude
        0x13: plugplay
        0x14: vxd
        0x15: anicursor
        0x16: aniicon
        0x17: html
        0x18: manifest
        0xfc: dlginit
        0xf1: toolbar

  dotnet_header:
    to-string: |
      '.NET Header'
    seq:
      - id: cb
        type: u4
      - id: major_runtime_version
        type: u2
      - id: minor_runtime_version
        type: u2
      - id: meta_data
        type: data_dir
      - id: flags
        type: u4
        enum: flag_enum
      - id: entry_point_token
        type: u4
      - id: entry_point_virtual_address
        type: u4
      - id: resources
        type: data_dir
      - id: strong_name_signature
        type: data_dir
      - id: code_manager_table
        type: data_dir
      - id: export_address_table_jumps
        type: data_dir
      - id: managed_native_header
        type: data_dir
    enums:
      flag_enum:
        0: unknown
        0x00000001: il_only
        0x00000002: required_32bit
        0x00000004: il_library
        0x00000008: strongnamesigned
        0x00000010: native_entrypoint
        0x00010000: trackdebugdata

  dotnet_metadata_header:
    doc-ref: https://www.ntcore.com/files/dotnetformat.htm
    to-string: |
      'Metadata Header <.NET Version ' + version_string + ', NumberOfStreams: ' + number_of_streams.to_s + '>'
    seq:
      - id: signature
        type: u4
      - id: major_version
        type: u2
      - id: minor_version
        type: u2
      - id: reserved
        type: u4
      - id: version_length
        type: u4
      - id: version_string
        type: str
        encoding: UTF-8
        size: version_length
        pad-right: 0
      - id: flags
        type: u2
      - id: number_of_streams
        type: u2
      - id: streams
        repeat: expr
        repeat-expr: number_of_streams
        type: dotnet_stream
  dotnet_stream:
    -webide-representation: '{name}'
    to-string: |
      'Stream <Name: ' + name + ', Offset: ' + offset.to_s + ', Size: ' + size.to_s + ', PointerToRawData: ' + pointer_to_raw_data.to_s + '>'
    seq:
      - id: offset
        type: u4
      - id: size
        type: u4
      - id: name
        type: strz
        terminator: 0
        eos-error: false
        encoding: ascii
      - id: padding
        size: (4 - _io.pos) % 4
    instances:
      pointer_to_raw_data:
        value: _root.pe.dotnet_header.meta_data.pointer_to_raw_data + offset
