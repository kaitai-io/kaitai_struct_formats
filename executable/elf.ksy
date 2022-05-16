meta:
  id: elf
  title: Executable and Linkable Format
  application: SVR4 ABI and up, many *nix systems
  xref:
    justsolve: Executable_and_Linkable_Format
    mime:
      - application/x-elf
      - application/x-coredump
      - application/x-executable
      - application/x-object
      - application/x-sharedlib
    pronom:
      - fmt/688 # 32bit Little Endian
      - fmt/689 # 32bit Big Endian
      - fmt/690 # 64bit Little Endian
      - fmt/691 # 64bit Big Endian
    wikidata: Q1343830
  tags:
    - executable
    - linux
  license: CC0-1.0
  ks-version: 0.9
doc-ref:
  - https://sourceware.org/git/?p=glibc.git;a=blob;f=elf/elf.h;hb=0f62fe0532
  - https://refspecs.linuxfoundation.org/elf/gabi4+/contents.html
  - https://docs.oracle.com/cd/E37838_01/html/E36783/glcfv.html
seq:
  - id: magic
    -orig-id: e_ident[EI_MAG0]..e_ident[EI_MAG3]
    size: 4
    contents: [0x7f, "ELF"]
    doc: File identification, must be 0x7f + "ELF".
  - id: bits
    -orig-id: e_ident[EI_CLASS]
    type: u1
    enum: bits
    doc: |
      File class: designates target machine word size (32 or 64
      bits). The size of many integer fields in this format will
      depend on this setting.
  - id: endian
    -orig-id: e_ident[EI_DATA]
    type: u1
    enum: endian
    doc: Endianness used for all integers.
  - id: ei_version
    -orig-id: e_ident[EI_VERSION]
    type: u1
    valid: 1
    doc: ELF header version.
  - id: abi
    -orig-id: e_ident[EI_OSABI]
    type: u1
    enum: os_abi
    doc: |
      Specifies which OS- and ABI-related extensions will be used
      in this ELF file.
  - id: abi_version
    -orig-id: e_ident[EI_ABIVERSION]
    type: u1
    doc: |
      Version of ABI targeted by this ELF file. Interpretation
      depends on `abi` attribute.
  - id: pad
    -orig-id: e_ident[EI_PAD]..e_ident[EI_NIDENT - 1]
    contents: [0, 0, 0, 0, 0, 0, 0]
  - id: header
    type: endian_elf
instances:
  sh_idx_lo_reserved:
    -orig-id: SHN_LORESERVE
    value: 0xff00
  sh_idx_lo_proc:
    -orig-id: SHN_LOPROC
    value: 0xff00
  sh_idx_hi_proc:
    -orig-id: SHN_HIPROC
    value: 0xff1f
  sh_idx_lo_os:
    -orig-id: SHN_LOOS
    value: 0xff20
  sh_idx_hi_os:
    -orig-id: SHN_HIOS
    value: 0xff3f
  sh_idx_hi_reserved:
    -orig-id: SHN_HIRESERVE
    value: 0xffff
types:
  phdr_type_flags:
    params:
      - id: value
        type: u4
    instances:
      read:
        value: value & 0x04 != 0
      write:
        value: value & 0x02 != 0
      execute:
        value: value & 0x01 != 0
      mask_proc:
        value: value & 0xf0000000 != 0
  section_header_flags:
    params:
      - id: value
        type: u4
    instances:
      write:
        value: value & 0x01 != 0
        doc: "writable"
      alloc:
        value: value & 0x02 != 0
        doc: "occupies memory during execution"
      exec_instr:
        value: value & 0x04 != 0
        doc: "executable"
      merge:
        value: value & 0x10 != 0
        doc: "might be merged"
      strings:
        value: value & 0x20 != 0
        doc: "contains nul-terminated strings"
      info_link:
        value: value & 0x40 != 0
        doc: "'sh_info' contains SHT index"
      link_order:
        value: value & 0x80 != 0
        doc: "preserve order after combining"
      os_non_conforming:
        value: value & 0x100 != 0
        doc: "non-standard OS specific handling required"
      group:
        value: value & 0x200 != 0
        doc: "section is member of a group"
      tls:
        value: value & 0x400 != 0
        doc: "section hold thread-local data"
      ordered:
        value: value & 0x04000000 != 0
        doc: "special ordering requirement (Solaris)"
      exclude:
        value: value & 0x08000000 != 0
        doc: "section is excluded unless referenced or allocated (Solaris)"
      mask_os:
        value: value & 0x0ff00000 != 0
        doc: "OS-specific"
      mask_proc:
        value: value & 0xf0000000 != 0
        doc: "Processor-specific"
  dt_flag_values:
    doc-ref:
      - 'https://refspecs.linuxbase.org/elf/gabi4+/ch5.dynamic.html Figure 5-11: DT_FLAGS values'
      - https://github.com/golang/go/blob/48dfddbab3/src/debug/elf/elf.go#L1079-L1095
      - https://docs.oracle.com/cd/E37838_01/html/E36783/chapter6-42444.html#OSLLGchapter7-tbl-5
    params:
      - id: value
        type: u4
    instances:
      origin:
        value: value & 0x00000001 != 0
        doc: object may reference the $ORIGIN substitution string
      symbolic:
        value: value & 0x00000002 != 0
        doc: symbolic linking
      textrel:
        value: value & 0x00000004 != 0
        doc: relocation entries might request modifications to a non-writable segment
      bind_now:
        value: value & 0x00000008 != 0
        doc: |
          all relocations for this object must be processed before returning
          control to the program
      static_tls:
        value: value & 0x00000010 != 0
        doc: object uses static thread-local storage scheme
  dt_flag_1_values:
    params:
      - id: value
        type: u4
    instances:
      now:
        value: value & 0x00000001 != 0
        doc: "Set RTLD_NOW for this object."
      rtld_global:
        value: value & 0x00000002 != 0
        doc: "Set RTLD_GLOBAL for this object."
      group:
        value: value & 0x00000004 != 0
        doc: "Set RTLD_GROUP for this object."
      nodelete:
        value: value & 0x00000008 != 0
        doc: "Set RTLD_NODELETE for this object."
      loadfltr:
        value: value & 0x00000010 != 0
        doc: "Trigger filtee loading at runtime."
      initfirst:
        value: value & 0x00000020 != 0
        doc: "Set RTLD_INITFIRST for this object"
      noopen:
        value: value & 0x00000040 != 0
        doc: "Set RTLD_NOOPEN for this object."
      origin:
        value: value & 0x00000080 != 0
        doc: "$ORIGIN must be handled."
      direct:
        value: value & 0x00000100 != 0
        doc: "Direct binding enabled."
      trans:
        value: value & 0x00000200 != 0
      interpose:
        value: value & 0x00000400 != 0
        doc: "Object is used to interpose."
      nodeflib:
        value: value & 0x00000800 != 0
        doc: "Ignore default lib search path."
      nodump:
        value: value & 0x00001000 != 0
        doc: "Object can't be dldump'ed."
      confalt:
        value: value & 0x00002000 != 0
        doc: "Configuration alternative created."
      endfiltee:
        value: value & 0x00004000 != 0
        doc: "Filtee terminates filters search."
      dispreldne:
        value: value & 0x00008000 != 0
        doc: "Disp reloc applied at build time."
      disprelpnd:
        value: value & 0x00010000 != 0
        doc: "Disp reloc applied at run-time."
      nodirect:
        value: value & 0x00020000 != 0
        doc: "Object has no-direct binding."
      ignmuldef:
        value: value & 0x00040000 != 0
      noksyms:
        value: value & 0x00080000 != 0
      nohdr:
        value: value & 0x00100000 != 0
      edited:
        value: value & 0x00200000 != 0
        doc: "Object is modified after built."
      noreloc:
        value: value & 0x00400000 != 0
      symintpose:
        value: value & 0x00800000 != 0
        doc: "Object has individual interposers."
      globaudit:
        value: value & 0x01000000 != 0
        doc: "Global auditing required."
      singleton:
        value: value & 0x02000000 != 0
        doc: "Singleton symbols are used."
      stub:
        value: value & 0x04000000 != 0
      pie:
        value: value & 0x08000000 != 0
  endian_elf:
    meta:
      endian:
        switch-on: _root.endian
        cases:
          'endian::le': le
          'endian::be': be
    seq:
      - id: e_type
        type: u2
        enum: obj_type
      - id: machine
        type: u2
        enum: machine
      - id: e_version
        type: u4
      # e_entry
      - id: entry_point
        type:
          switch-on: _root.bits
          cases:
            'bits::b32': u4
            'bits::b64': u8
      # e_phoff
      - id: program_header_offset
        type:
          switch-on: _root.bits
          cases:
            'bits::b32': u4
            'bits::b64': u8
      # e_shoff
      - id: section_header_offset
        type:
          switch-on: _root.bits
          cases:
            'bits::b32': u4
            'bits::b64': u8
      # e_flags
      - id: flags
        size: 4
      # e_ehsize
      - id: e_ehsize
        type: u2
      # e_phentsize
      - id: program_header_entry_size
        type: u2
      # e_phnum
      - id: qty_program_header
        type: u2
      # e_shentsize
      - id: section_header_entry_size
        type: u2
      # e_shnum
      - id: qty_section_header
        type: u2
      # e_shstrndx
      - id: section_names_idx
        type: u2
    types:
      # Elf(32|64)_Phdr
      program_header:
        seq:
          # p_type
          - id: type
            type: u4
            enum: ph_type
          # p_flags
          - id: flags64
            type: u4
            if: _root.bits == bits::b64
          # p_offset
          - id: offset
            type:
              switch-on: _root.bits
              cases:
                'bits::b32': u4
                'bits::b64': u8
          # p_vaddr
          - id: vaddr
            type:
              switch-on: _root.bits
              cases:
                'bits::b32': u4
                'bits::b64': u8
          # p_paddr
          - id: paddr
            type:
              switch-on: _root.bits
              cases:
                'bits::b32': u4
                'bits::b64': u8
          # p_filesz
          - id: filesz
            type:
              switch-on: _root.bits
              cases:
                'bits::b32': u4
                'bits::b64': u8
          # p_memsz
          - id: memsz
            type:
              switch-on: _root.bits
              cases:
                'bits::b32': u4
                'bits::b64': u8
          # p_flags
          - id: flags32
            type: u4
            if: _root.bits == bits::b32
          # p_align
          - id: align
            type:
              switch-on: _root.bits
              cases:
                'bits::b32': u4
                'bits::b64': u8
        instances:
          flags_obj:
            type:
              switch-on: _root.bits
              cases:
                'bits::b32': phdr_type_flags(flags32)
                'bits::b64': phdr_type_flags(flags64)
            -webide-parse-mode: eager
        -webide-representation: "{type} - f:{flags_obj:flags} (o:{offset}, s:{filesz:dec})"
      section_header:
        -orig-id: Elf(32|64)_Shdr
        seq:
          - id: ofs_name
            -orig-id: sh_name
            type: u4
          - id: type
            -orig-id: sh_type
            type: u4
            enum: sh_type
          - id: flags
            -orig-id: sh_flags
            type:
              switch-on: _root.bits
              cases:
                'bits::b32': u4
                'bits::b64': u8
          - id: addr
            -orig-id: sh_addr
            type:
              switch-on: _root.bits
              cases:
                'bits::b32': u4
                'bits::b64': u8
          - id: ofs_body
            -orig-id: sh_offset
            type:
              switch-on: _root.bits
              cases:
                'bits::b32': u4
                'bits::b64': u8
          - id: len_body
            -orig-id: sh_size
            type:
              switch-on: _root.bits
              cases:
                'bits::b32': u4
                'bits::b64': u8
          - id: linked_section_idx
            -orig-id: sh_link
            type: u4
          - id: info
            -orig-id: sh_info
            size: 4
          - id: align
            -orig-id: sh_addralign
            type:
              switch-on: _root.bits
              cases:
                'bits::b32': u4
                'bits::b64': u8
          - id: entry_size
            -orig-id: sh_entsize
            type:
              switch-on: _root.bits
              cases:
                'bits::b32': u4
                'bits::b64': u8
        instances:
          body:
            io: _root._io
            pos: ofs_body
            size: len_body
            type:
              switch-on: type
              cases:
                'sh_type::dynamic': dynamic_section
                'sh_type::strtab': strings_struct
                'sh_type::dynsym': dynsym_section
                'sh_type::symtab': dynsym_section
                'sh_type::note': note_section
                'sh_type::rel': relocation_section(false)
                'sh_type::rela': relocation_section(true)
            if: type != sh_type::nobits
          linked_section:
            value: _root.header.section_headers[linked_section_idx]
            if: |
              linked_section_idx != section_header_idx_special::undefined.to_i
              and linked_section_idx < _root.header.qty_section_header
            doc: may reference a later section header, so don't try to access too early (use only lazy `instances`)
            doc-ref: https://refspecs.linuxfoundation.org/elf/gabi4+/ch4.sheader.html#sh_link
          name:
            io: _root.header.section_names._io
            pos: ofs_name
            type: strz
            encoding: ASCII
            -webide-parse-mode: eager
          flags_obj:
            type: section_header_flags(flags)
            -webide-parse-mode: eager
        -webide-representation: "{name} ({type}) - f:{flags_obj:flags} (o:{offset}, s:{size:dec})"
      strings_struct:
        seq:
          - id: entries
            type: strz
            repeat: eos
            # For an explanation of why UTF-8 instead of ASCII, see the comment
            # on the `name` attribute in the `dynsym_section_entry` type.
            encoding: UTF-8
      dynamic_section:
        seq:
          - id: entries
            type: dynamic_section_entry
            repeat: eos
        instances:
          is_string_table_linked:
            value: _parent.linked_section.type == sh_type::strtab
      dynamic_section_entry:
        doc-ref:
          - https://docs.oracle.com/cd/E37838_01/html/E36783/chapter6-42444.html
          - https://refspecs.linuxfoundation.org/elf/gabi4+/ch5.dynamic.html#dynamic_section
        -webide-representation: "{tag_enum}: {value_or_ptr} {value_str} {flag_1_values:flags}"
        seq:
          - id: tag
            type:
              switch-on: _root.bits
              cases:
                'bits::b32': u4
                'bits::b64': u8
          - id: value_or_ptr
            type:
              switch-on: _root.bits
              cases:
                'bits::b32': u4
                'bits::b64': u8
        instances:
          tag_enum:
            value: tag
            enum: dynamic_array_tags
          flag_values:
            type: dt_flag_values(value_or_ptr)
            if: "tag_enum == dynamic_array_tags::flags"
            -webide-parse-mode: eager
          flag_1_values:
            type: dt_flag_1_values(value_or_ptr)
            if: "tag_enum == dynamic_array_tags::flags_1"
            -webide-parse-mode: eager
          value_str:
            io: _parent._parent.linked_section.body.as<strings_struct>._io
            pos: value_or_ptr
            type: strz
            encoding: ASCII
            if: is_value_str and _parent.is_string_table_linked
            -webide-parse-mode: eager
          is_value_str:
            value: |
              value_or_ptr != 0 and (
                tag_enum == dynamic_array_tags::needed or
                tag_enum == dynamic_array_tags::soname or
                tag_enum == dynamic_array_tags::rpath or
                tag_enum == dynamic_array_tags::runpath or
                tag_enum == dynamic_array_tags::sunw_auxiliary or
                tag_enum == dynamic_array_tags::sunw_filter or
                tag_enum == dynamic_array_tags::auxiliary or
                tag_enum == dynamic_array_tags::filter or
                tag_enum == dynamic_array_tags::config or
                tag_enum == dynamic_array_tags::depaudit or
                tag_enum == dynamic_array_tags::audit
              )
      dynsym_section:
        seq:
          - id: entries
            type: dynsym_section_entry
            repeat: eos
        instances:
          is_string_table_linked:
            value: _parent.linked_section.type == sh_type::strtab
      dynsym_section_entry:
        -orig-id:
          - Elf32_Sym
          - Elf64_Sym
        doc-ref:
          - https://docs.oracle.com/cd/E37838_01/html/E36783/man-sts.html
          - https://refspecs.linuxfoundation.org/elf/gabi4+/ch4.symtab.html
        -webide-representation: 'v:{value} s:{size:dec} t:{type} b:{bind} vis:{visibility} i:{sh_idx:dec}[={sh_idx_special}] n:{name}'
        seq:
          - id: ofs_name
            -orig-id: st_name
            type: u4

          - id: value_b32
            type: u4
            if: _root.bits == bits::b32
          - id: size_b32
            type: u4
            if: _root.bits == bits::b32

          - id: bind
            -orig-id: ELF32_ST_BIND(st_info)
            type: b4
            enum: symbol_binding
          - id: type
            -orig-id: ELF32_ST_TYPE(st_info)
            type: b4
            enum: symbol_type
          - id: other
            type: u1
            doc: don't read this field, access `visibility` instead
          - id: sh_idx
            -orig-id: st_shndx
            type: u2
            doc: section header index

          - id: value_b64
            type: u8
            if: _root.bits == bits::b64
          - id: size_b64
            type: u8
            if: _root.bits == bits::b64
        instances:
          value:
            value: |
              _root.bits == bits::b32 ? value_b32 :
              _root.bits == bits::b64 ? value_b64 :
              0
          size:
            value: |
              _root.bits == bits::b32 ? size_b32 :
              _root.bits == bits::b64 ? size_b64 :
              0
          name:
            io: _parent._parent.linked_section.body.as<strings_struct>._io
            pos: ofs_name
            type: strz
            # UTF-8 is used (instead of ASCII) because Golang binaries may
            # contain specific Unicode code points in symbol identifiers.
            #
            # See
            # * <https://golang.org/doc/asm#symbols>: "the assembler allows the
            #   middle dot character U+00B7 and the division slash U+2215 in
            #   identifiers"
            # * <https://github.com/kaitai-io/kaitai_struct_formats/issues/520>
            encoding: UTF-8
            if: ofs_name != 0 and _parent.is_string_table_linked
            -webide-parse-mode: eager
          visibility:
            value: other & 0x03
            enum: symbol_visibility
          sh_idx_special:
            value: sh_idx
            enum: section_header_idx_special
          is_sh_idx_reserved:
            value: |
              sh_idx >= _root.sh_idx_lo_reserved and
              sh_idx <= _root.sh_idx_hi_reserved
          is_sh_idx_proc:
            value: |
              sh_idx >= _root.sh_idx_lo_proc and
              sh_idx <= _root.sh_idx_hi_proc
          is_sh_idx_os:
            value: |
              sh_idx >= _root.sh_idx_lo_os and
              sh_idx <= _root.sh_idx_hi_os
      note_section:
        seq:
          - id: entries
            type: note_section_entry
            repeat: eos
      note_section_entry:
        doc-ref:
          - https://docs.oracle.com/cd/E37838_01/html/E36783/chapter6-18048.html
          # The following source claims that note's `name` and `descriptor` should be padded
          # to 8 bytes in 64-bit ELFs, not always to 4 - although this seems to be an idea of
          # the original spec, it did not catch on in the real world and most implementations
          # always use 4-byte alignment - see
          # <https://fa.linux.kernel.narkive.com/2Za5xb58/patch-01-02-elf-always-define-elf-addr-t-in-linux-elf-h#post13>
          - https://refspecs.linuxfoundation.org/elf/gabi4+/ch5.pheader.html#note_section
        seq:
          - id: len_name
            type: u4
          - id: len_descriptor
            type: u4
          - id: type
            type: u4
          - id: name
            size: len_name
            terminator: 0
            doc: |
              Although the ELF specification seems to hint that the `note_name` field
              is ASCII this isn't the case for Linux binaries that have a
              `.gnu.build.attributes` section.
            doc-ref: https://fedoraproject.org/wiki/Toolchain/Watermark#Proposed_Specification_for_non-loaded_notes
          - id: name_padding
            size: -len_name % 4
          - id: descriptor
            size: len_descriptor
          - id: descriptor_padding
            size: -len_descriptor % 4
      relocation_section:
        doc-ref:
          - https://docs.oracle.com/cd/E37838_01/html/E36783/chapter6-54839.html
          - https://refspecs.linuxfoundation.org/elf/gabi4+/ch4.reloc.html
        params:
          - id: has_addend
            type: bool
        seq:
          - id: entries
            type: relocation_section_entry
            repeat: eos
      relocation_section_entry:
        seq:
          - id: offset
            type:
              switch-on: _root.bits
              cases:
                'bits::b32': u4
                'bits::b64': u8
          - id: info
            type:
              switch-on: _root.bits
              cases:
                'bits::b32': u4
                'bits::b64': u8
          - id: addend
            type:
              switch-on: _root.bits
              cases:
                'bits::b32': s4
                'bits::b64': s8
            if: _parent.has_addend
    instances:
      program_headers:
        pos: program_header_offset
        size: program_header_entry_size
        type: program_header
        repeat: expr
        repeat-expr: qty_program_header
      section_headers:
        pos: section_header_offset
        size: section_header_entry_size
        type: section_header
        repeat: expr
        repeat-expr: qty_section_header
      section_names:
        pos: section_headers[section_names_idx].ofs_body
        size: section_headers[section_names_idx].len_body
        type: strings_struct
        if: |
          section_names_idx != section_header_idx_special::undefined.to_i
          and section_names_idx < _root.header.qty_section_header
enums:
  # EI_CLASS
  bits:
    # ELFCLASS32
    1: b32
    # ELFCLASS64
    2: b64
  # EI_DATA
  endian:
    # ELFDATA2LSB
    1: le
    # ELFDATA2MSB
    2: be
  os_abi:
    0: system_v
    1: hp_ux
    2: netbsd
    3: gnu
    6: solaris
    7: aix
    8: irix
    9: freebsd
    0xa: tru64 # Compaq TRU64 UNIX
    0xb: modesto # Novell Modesto
    0xc: openbsd
    0xd: openvms
    0xe: nsk # Hewlett-Packard Non-Stop Kernel
    0xf: aros # Amiga Research OS
    0x10: fenixos # The FenixOS highly scalable multi-core OS
    0x11: cloudabi # Nuxi CloudABI
    0x12: openvos # Stratus Technologies OpenVOS
  # e_type
  obj_type:
    # ET_NONE
    0: no_file_type
    # ET_REL
    1: relocatable
    # ET_EXEC
    2: executable
    # ET_DYN
    3: shared
    # ET_CORE
    4: core
  # http://www.sco.com/developers/gabi/latest/ch4.eheader.html
  # https://sourceware.org/git/?p=glibc.git;a=blob;f=elf/elf.h;hb=0f62fe0532
  # https://github.com/NationalSecurityAgency/ghidra/blob/f5615aa240/Ghidra/Features/Base/src/main/java/ghidra/app/util/bin/format/elf/ElfConstants.java#L158-L510
  # https://github.com/llvm/llvm-project/blob/f6928cf45516/llvm/include/llvm/BinaryFormat/ELF.h#L130
  machine:
    0:
      id: no_machine
      -orig-id: EM_NONE
      doc: No machine
    1:
      id: m32
      doc: AT&T WE 32100
    2:
      id: sparc
      doc: Sun SPARC
    3:
      id: x86
      -orig-id: EM_386
      doc: Intel 80386
    4:
      id: m68k
      -orig-id: EM_68K
      doc: Motorola m68k family
    5:
      id: m88k
      -orig-id: EM_88K
      doc: Motorola m88k family
    6:
      id: iamcu
      doc: |
        Intel MCU

        was assigned to `EM_486` (for Intel i486), but that value was deprecated
        and replaced with this one
      doc-ref:
        - https://sourceware.org/bugzilla/show_bug.cgi?id=18404
        - https://gcc.gnu.org/legacy-ml/gcc/2015-05/msg00090.html
        - https://github.com/gcc-mirror/gcc/blob/240f07805d/libgo/go/debug/elf/elf.go#L389
    7:
      id: i860
      -orig-id: EM_860
      doc: Intel 80860
    8:
      id: mips
      doc: MIPS R3000 big-endian
    9:
      id: s370
      doc: IBM System/370
    10:
      id: mips_rs3_le
      doc: MIPS R3000 little-endian
    15:
      id: parisc
      doc: Hewlett-Packard PA-RISC
    17:
      id: vpp500
      doc: Fujitsu VPP500
    18:
      id: sparc32plus
      doc: Sun's "v8plus"
    19:
      id: i960
      -orig-id: EM_960
      doc: Intel 80960
    20:
      id: powerpc
      -orig-id: EM_PPC
      doc: PowerPC
    21:
      id: powerpc64
      -orig-id: EM_PPC64
      doc: PowerPC 64-bit
    22:
      id: s390
      doc: IBM System/390
    23:
      id: spu
      doc: IBM SPU/SPC
    36:
      id: v800
      doc: NEC V800 series
    37:
      id: fr20
      doc: Fujitsu FR20
    38:
      id: rh32
      doc: TRW RH-32
    39:
      id: rce
      doc: Motorola RCE
    40:
      id: arm
      doc: ARM
    41:
      id: old_alpha
      -orig-id: EM_FAKE_ALPHA
      doc: DEC Alpha
    42:
      id: superh
      -orig-id: EM_SH
      doc: Hitachi SH
    43:
      id: sparc_v9
      -orig-id: EM_SPARCV9
      doc: SPARC v9 64-bit
    44:
      id: tricore
      doc: Siemens TriCore
    45:
      id: arc
      doc: Argonaut RISC Core
    46:
      id: h8_300
      doc: Hitachi H8/300
    47:
      id: h8_300h
      doc: Hitachi H8/300H
    48:
      id: h8s
      doc: Hitachi H8S
    49:
      id: h8_500
      doc: Hitachi H8/500
    50:
      id: ia_64
      doc: Intel IA-64 processor architecture
    51:
      id: mips_x
      doc: Stanford MIPS-X
    52:
      id: coldfire
      doc: Motorola ColdFire
    53:
      id: m68hc12
      -orig-id: EM_68HC12
      doc: Motorola M68HC12
    54:
      id: mma
      doc: Fujitsu MMA Multimedia Accelerator
    55:
      id: pcp
      doc: Siemens PCP
    56:
      id: ncpu
      doc: Sony nCPU embedded RISC processor
    57:
      id: ndr1
      doc: Denso NDR1 microprocessor
    58:
      id: starcore
      doc: Motorola Star*Core processor
    59:
      id: me16
      doc: Toyota ME16 processor
    60:
      id: st100
      doc: STMicroelectronics ST100 processor
    61:
      id: tinyj
      doc: Advanced Logic Corp. TinyJ embedded processor family
    62:
      id: x86_64
      doc: AMD x86-64 architecture
    63:
      id: pdsp
      doc: Sony DSP Processor
    64:
      id: pdp10
      doc: Digital Equipment Corp. PDP-10
    65:
      id: pdp11
      doc: Digital Equipment Corp. PDP-11
    66:
      id: fx66
      doc: Siemens FX66 microcontroller
    67:
      id: st9plus
      doc: STMicroelectronics ST9+ 8/16 bit microcontroller
    68:
      id: st7
      doc: STMicroelectronics ST7 8-bit microcontroller
    69:
      id: mc68hc16
      -orig-id: EM_68HC16
      doc: Motorola MC68HC16 microcontroller
    70:
      id: mc68hc11
      -orig-id: EM_68HC11
      doc: Motorola MC68HC11 microcontroller
    71:
      id: mc68hc08
      -orig-id: EM_68HC08
      doc: Motorola MC68HC08 microcontroller
    72:
      id: mc68hc05
      -orig-id: EM_68HC05
      doc: Motorola MC68HC05 microcontroller
    73:
      id: svx
      doc: Silicon Graphics SVx
    74:
      id: st19
      doc: STMicroelectronics ST19 8-bit microcontroller
    75:
      id: vax
      doc: Digital VAX
    76:
      id: cris
      doc: Axis Communications 32-bit embedded processor
    77:
      id: javelin
      doc: Infineon Technologies 32-bit embedded processor
    78:
      id: firepath
      doc: Element 14 64-bit DSP Processor
    79:
      id: zsp
      doc: LSI Logic 16-bit DSP Processor
    80:
      id: mmix
      doc: Donald Knuth's educational 64-bit processor
    81:
      id: huany
      doc: Harvard University machine-independent object files
    82:
      id: prism
      doc: SiTera Prism
    83:
      id: avr
      doc: Atmel AVR 8-bit microcontroller
    84:
      id: fr30
      doc: Fujitsu FR30
    85:
      id: d10v
      doc: Mitsubishi D10V
    86:
      id: d30v
      doc: Mitsubishi D30V
    87:
      id: v850
      doc: NEC v850
    88:
      id: m32r
      doc: Mitsubishi M32R
    89:
      id: mn10300
      doc: Matsushita MN10300
    90:
      id: mn10200
      doc: Matsushita MN10200
    91:
      id: picojava
      -orig-id: EM_PJ
      doc: picoJava
    92:
      id: openrisc
      doc: OpenRISC 32-bit embedded processor
    93:
      id: arc_compact
      doc: 'ARC International ARCompact processor (old spelling/synonym: EM_ARC_A5)'
    94:
      id: xtensa
      doc: Tensilica Xtensa Architecture
    95:
      id: videocore
      doc: Alphamosaic VideoCore processor
    96:
      id: tmm_gpp
      doc: Thompson Multimedia General Purpose Processor
    97:
      id: ns32k
      doc: National Semiconductor 32000 series
    98:
      id: tpc
      doc: Tenor Network TPC processor
    99:
      id: snp1k
      doc: Trebia SNP 1000 processor
    100:
      id: st200
      doc: STMicroelectronics ST200
    101:
      id: ip2k
      doc: Ubicom IP2xxx microcontroller family
    102:
      id: max
      doc: MAX processor
    103:
      id: compact_risc
      -orig-id: EM_CR
      doc: National Semiconductor CompactRISC microprocessor
    104:
      id: f2mc16
      doc: Fujitsu F2MC16
    105:
      id: msp430
      doc: Texas Instruments embedded microcontroller MSP430
    106:
      id: blackfin
      doc: Analog Devices Blackfin (DSP) processor
    107:
      id: se_c33
      doc: Seiko Epson S1C33 family
    108:
      id: sep
      doc: Sharp embedded microprocessor
    109:
      id: arca
      doc: Arca RISC microprocessor
    110:
      id: unicore
      doc: microprocessor series from PKU-Unity Ltd. and MPRC of Peking University
    111:
      id: excess
      doc: 'eXcess: 16/32/64-bit configurable embedded CPU'
    112:
      id: dxp
      doc: Icera Semiconductor Inc. Deep Execution Processor
    113:
      id: altera_nios2
      doc: Altera Nios II soft-core processor
    114:
      id: crx
      doc: National Semiconductor CompactRISC CRX microprocessor
    115:
      id: xgate
      doc: Motorola XGATE embedded processor
    116:
      id: c166
      doc: Infineon C16x/XC16x processor
    117:
      id: m16c
      doc: Renesas M16C series microprocessors
    118:
      id: dspic30f
      doc: Microchip Technology dsPIC30F Digital Signal Controller
    119:
      id: freescale_ce
      -orig-id: EM_CE
      doc: Freescale Communication Engine RISC core
    120:
      id: m32c
      doc: Renesas M32C series microprocessors
    131:
      id: tsk3000
      doc: Altium TSK3000 core
    132:
      id: rs08
      doc: Freescale RS08 embedded processor
    133:
      id: sharc
      doc: Analog Devices SHARC family of 32-bit DSP processors
    134:
      id: ecog2
      doc: Cyan Technology eCOG2 microprocessor
    135:
      id: score7
      doc: Sunplus S+core7 RISC processor
    136:
      id: dsp24
      doc: New Japan Radio (NJR) 24-bit DSP Processor
    137:
      id: videocore3
      doc: Broadcom VideoCore III processor
    138:
      id: latticemico32
      doc: RISC processor for Lattice FPGA architecture
    139:
      id: se_c17
      doc: Seiko Epson C17 family
    140:
      id: ti_c6000
      doc: Texas Instruments TMS320C6000 DSP family
    141:
      id: ti_c2000
      doc: Texas Instruments TMS320C2000 DSP family
    142:
      id: ti_c5500
      doc: Texas Instruments TMS320C55x DSP family
    143:
      id: ti_arp32
      doc: Texas Instruments Application Specific RISC Processor, 32bit fetch
    144:
      id: ti_pru
      doc: Texas Instruments Programmable Realtime Unit
    160:
      id: mmdsp_plus
      doc: STMicroelectronics 64bit VLIW Data Signal Processor
    161:
      id: cypress_m8c
      doc: Cypress M8C microprocessor
    162:
      id: r32c
      doc: Renesas R32C series microprocessors
    163:
      id: trimedia
      doc: NXP Semiconductors TriMedia architecture family
    164:
      id: qdsp6
      doc: Qualcomm Hexagon processor
    165:
      id: i8051
      -orig-id: EM_8051
      doc: Intel 8051 and variants
    166:
      id: stxp7x
      doc: STMicroelectronics STxP7x family of configurable and extensible RISC processors
    167:
      id: nds32
      doc: Andes Technology compact code size embedded RISC processor family
    168:
      id: ecog1x
      doc: Cyan Technology eCOG1X family
    169:
      id: maxq30
      doc: Dallas Semiconductor MAXQ30 Core Micro-controllers
    170:
      id: ximo16
      doc: New Japan Radio (NJR) 16-bit DSP Processor
    171:
      id: manik
      doc: M2000 Reconfigurable RISC Microprocessor
    172:
      id: craynv2
      doc: Cray Inc. NV2 vector architecture
    173:
      id: rx
      doc: Renesas RX family
    174:
      id: metag
      doc: Imagination Technologies META processor architecture
    175:
      id: mcst_elbrus
      doc: MCST Elbrus general purpose hardware architecture
    176:
      id: ecog16
      doc: Cyan Technology eCOG16 family
    177:
      id: cr16
      doc: National Semiconductor CompactRISC CR16 16-bit microprocessor
    178:
      id: etpu
      doc: Freescale Extended Time Processing Unit
    179:
      id: sle9x
      doc: Infineon Technologies SLE9X core
    180:
      id: l10m
      doc: Intel L10M
    181:
      id: k10m
      doc: Intel K10M
    183:
      id: aarch64
      doc: ARM AArch64
    185:
      id: avr32
      doc: Atmel Corporation 32-bit microprocessor family
    186:
      id: stm8
      doc: STMicroeletronics STM8 8-bit microcontroller
    187:
      id: tile64
      doc: Tilera TILE64 multicore architecture family
    188:
      id: tilepro
      doc: Tilera TILEPro multicore architecture family
    189:
      id: microblaze
      doc: Xilinx MicroBlaze 32-bit RISC soft processor core
    190:
      id: cuda
      doc: NVIDIA CUDA architecture
    191:
      id: tilegx
      doc: Tilera TILE-Gx multicore architecture family
    192:
      id: cloudshield
      doc: CloudShield architecture family
    193:
      id: corea_1st
      doc: KIPO-KAIST Core-A 1st generation processor family
    194:
      id: corea_2nd
      doc: KIPO-KAIST Core-A 2nd generation processor family
    195:
      id: arcv2
      doc: Synopsys ARCv2 ISA
    196:
      id: open8
      doc: Open8 8-bit RISC soft processor core
    197:
      id: rl78
      doc: Renesas RL78 family
    198:
      id: videocore5
      doc: Broadcom VideoCore V processor
    199:
      id: renesas_78kor
      -orig-id: EM_78KOR
      doc: Renesas 78KOR family
    200:
      id: freescale_56800ex
      -orig-id: EM_56800EX
      doc: Freescale 56800EX Digital Signal Controller (DSC)
    201:
      id: ba1
      doc: Beyond BA1 CPU architecture
    202:
      id: ba2
      doc: Beyond BA2 CPU architecture
    203:
      id: xcore
      doc: XMOS xCORE processor family
    204:
      id: mchp_pic
      doc: Microchip 8-bit PIC(r) family
    205:
      id: intelgt
      doc: Intel Graphics Technology
      doc-ref: https://sourceware.org/git/?p=glibc.git;a=blob;f=elf/elf.h;hb=0f62fe0532#l339
    206:
      id: intel206
      doc: Reserved by Intel
    207:
      id: intel207
      doc: Reserved by Intel
    208:
      id: intel208
      doc: Reserved by Intel
    209:
      id: intel209
      doc: Reserved by Intel
    210:
      id: km32
      doc: KM211 KM32 32-bit processor
    211:
      id: kmx32
      doc: KM211 KMX32 32-bit processor
    212:
      id: kmx16
      -orig-id: EM_EMX16
      doc: KM211 KMX16 16-bit processor
    213:
      id: kmx8
      -orig-id: EM_EMX8
      doc: KM211 KMX8 8-bit processor
    214:
      id: kvarc
      doc: KM211 KVARC processor
    215:
      id: cdp
      doc: Paneve CDP architecture family
    216:
      id: coge
      doc: Cognitive Smart Memory Processor
    217:
      id: cool
      doc: Bluechip Systems CoolEngine
    218:
      id: norc
      doc: Nanoradio Optimized RISC
    219:
      id: csr_kalimba
      doc: CSR Kalimba architecture family
    220:
      id: z80
      doc: Zilog Z80
    221:
      id: visium
      doc: Controls and Data Services VISIUMcore
    222:
      id: ft32
      doc: FTDI Chip FT32
    223:
      id: moxie
      doc: Moxie processor
    224:
      id: amd_gpu
      -orig-id: EM_AMDGPU
      doc: AMD GPU architecture
    243:
      id: riscv
      doc: RISC-V
    244:
      id: lanai
      doc: Lanai 32-bit processor
      doc-ref: https://github.com/llvm/llvm-project/blob/f6928cf45516/llvm/include/llvm/BinaryFormat/ELF.h#L319
    245:
      id: ceva
      doc: CEVA Processor Architecture Family
      doc-ref: https://groups.google.com/g/generic-abi/c/cmq1LFFpWqU
    246:
      id: ceva_x2
      doc: CEVA X2 Processor Family
      doc-ref: https://groups.google.com/g/generic-abi/c/cmq1LFFpWqU
    247:
      id: bpf
      doc: Linux BPF - in-kernel virtual machine
    248:
      id: graphcore_ipu
      doc: Graphcore Intelligent Processing Unit
      doc-ref: https://groups.google.com/g/generic-abi/c/cmq1LFFpWqU
    249:
      id: img1
      doc: Imagination Technologies
      doc-ref: https://groups.google.com/g/generic-abi/c/cmq1LFFpWqU
    250:
      id: nfp
      doc: Netronome Flow Processor (NFP)
      doc-ref: https://groups.google.com/g/generic-abi/c/cmq1LFFpWqU
    251:
      id: ve
      doc: NEC SX-Aurora Vector Engine (VE) processor
      doc-ref: https://github.com/llvm/llvm-project/blob/f6928cf45516/llvm/include/llvm/BinaryFormat/ELF.h#L321
    252:
      id: csky
      doc: C-SKY 32-bit processor
    253:
      id: arc_compact3_64
      -orig-id: EM_ARC_COMPACT3_64
      doc: Synopsys ARCv3 64-bit ISA/HS6x cores
      doc-ref:
        - https://gitlab.com/gnutools/binutils-gdb/-/blob/4ffb22ec40/include/elf/common.h#L350
        - https://github.com/file/file/blob/9b2538d/magic/Magdir/elf#L301
        - https://bugs.astron.com/view.php?id=251
    254:
      id: mcs6502
      doc: MOS Technology MCS 6502 processor
      doc-ref: https://gitlab.com/gnutools/binutils-gdb/-/blob/4ffb22ec40/include/elf/common.h#L351
    255:
      id: arc_compact3
      -orig-id: EM_ARC_COMPACT3
      doc: Synopsys ARCv3 32-bit
      doc-ref:
        - https://gitlab.com/gnutools/binutils-gdb/-/blob/4ffb22ec40/include/elf/common.h#L352
        - https://github.com/file/file/blob/9b2538d/magic/Magdir/elf#L303
        - https://bugs.astron.com/view.php?id=251
    256:
      id: kvx
      doc: Kalray VLIW core of the MPPA processor family
      doc-ref: https://gitlab.com/gnutools/binutils-gdb/-/blob/4ffb22ec40/include/elf/common.h#L353
    257:
      id: wdc65816
      -orig-id: EM_65816
      doc: WDC 65816/65C816
      doc-ref: https://gitlab.com/gnutools/binutils-gdb/-/blob/4ffb22ec40/include/elf/common.h#L354
    258:
      id: loongarch
      -orig-id: EM_LOONGARCH
      doc: LoongArch
      doc-ref: https://gitlab.com/gnutools/binutils-gdb/-/blob/4ffb22ec40/include/elf/common.h#L355
    259:
      id: kf32
      -orig-id: EM_KF32
      doc: ChipON KungFu32
      doc-ref:
        - https://gitlab.com/gnutools/binutils-gdb/-/blob/4ffb22ec40/include/elf/common.h#L356
        - https://groups.google.com/g/generic-abi/c/n8tLQxj02YY
    260:
      id: u16_u8core
      -orig-id: EM_U16_U8CORE
      doc: LAPIS nX-U16/U8
      doc-ref:
        - https://gitlab.com/gnutools/binutils-gdb/-/blob/dfbcbf85ea/include/elf/common.h#L357
    261:
      id: tachyum
      -orig-id: EM_TACHYUM
      doc: Tachyum
      doc-ref:
        - https://gitlab.com/gnutools/binutils-gdb/-/blob/dfbcbf85ea/include/elf/common.h#L358
    262:
      id: nxp_56800ef
      -orig-id: EM_56800EF
      doc: NXP 56800EF Digital Signal Controller (DSC)
      doc-ref:
        - https://gitlab.com/gnutools/binutils-gdb/-/blob/dfbcbf85ea/include/elf/common.h#L359
    # unofficial values
    # https://gitlab.com/gnutools/binutils-gdb/-/blob/4ffb22ec40/include/elf/common.h#L358
    0x1057:
      id: avr_old
      -orig-id: EM_AVR_OLD
    0x1059:
      id: msp430_old
      -orig-id: EM_MSP430_OLD
    0x1223:
      id: adapteva_epiphany
      -orig-id: EM_ADAPTEVA_EPIPHANY
      doc: Adapteva's Epiphany architecture.
    0x2530:
      id: mt
      -orig-id: EM_MT
      doc: Morpho MT
    0x3330:
      id: cygnus_fr30
      -orig-id: EM_CYGNUS_FR30
    0x4157:
      id: webassembly
      -orig-id: EM_WEBASSEMBLY
      doc: Unofficial value for Web Assembly binaries, as used by LLVM.
    0x4688:
      id: xc16x
      -orig-id: EM_XC16X
      doc: Infineon Technologies 16-bit microcontroller with C166-V2 core
    0x4def:
      id: s12z
      -orig-id: EM_S12Z
      doc: The Freescale toolchain generates elf files with this value.
    0x5441:
      id: cygnus_frv
      -orig-id: EM_CYGNUS_FRV
    0x5aa5:
      id: dlx
      -orig-id: EM_DLX
      doc: openDLX
    0x7650:
      id: cygnus_d10v
      -orig-id: EM_CYGNUS_D10V
    0x7676:
      id: cygnus_d30v
      -orig-id: EM_CYGNUS_D30V
    0x8217:
      id: ip2k_old
      -orig-id: EM_IP2K_OLD
    0x9025:
      id: cygnus_powerpc
      -orig-id: EM_CYGNUS_POWERPC
    0x9026:
      id: alpha
      -orig-id: EM_ALPHA
    0x9041:
      id: cygnus_m32r
      -orig-id: EM_CYGNUS_M32R
    0x9080:
      id: cygnus_v850
      -orig-id: EM_CYGNUS_V850
    0xa390:
      id: s390_old
      -orig-id: EM_S390_OLD
    0xabc7:
      id: xtensa_old
      -orig-id: EM_XTENSA_OLD
    0xad45:
      id: xstormy16
      -orig-id: EM_XSTORMY16
    0xbaab:
      id: microblaze_old
      -orig-id: EM_MICROBLAZE_OLD
    0xbeef:
      id: cygnus_mn10300
      -orig-id: EM_CYGNUS_MN10300
    0xdead:
      id: cygnus_mn10200
      -orig-id: EM_CYGNUS_MN10200
    0xfeb0:
      id: m32c_old
      -orig-id: EM_M32C_OLD
      doc: Renesas M32C and M16C
    0xfeba:
      id: iq2000
      -orig-id: EM_IQ2000
      doc: Vitesse IQ2000
    0xfebb:
      id: nios32
      -orig-id: EM_NIOS32
    0xf00d:
      id: cygnus_mep
      -orig-id: EM_CYGNUS_MEP
      doc: Toshiba MeP
    0xfeed:
      id: moxie_old
      -orig-id: EM_MOXIE_OLD
      doc: Old, unofficial value for Moxie
  ph_type:
    0: null_type
    1: load
    2: dynamic
    3: interp
    4: note
    5: shlib
    6: phdr
    7: tls
    # 0x60000000: lo_os
    0x65041580: pax_flags
    # 0x6fffffff: hi_os
    # 0x70000000: lo_proc
    0x70000001: arm_exidx
    # 0x7fffffff: hi_proc
    0x6474e550: gnu_eh_frame
    0x6474e551: gnu_stack
    0x6474e552: gnu_relro
    0x6474e553: gnu_property
  # https://docs.oracle.com/cd/E37838_01/html/E36783/man-s.html#OSLLGchapter6-73445
  # https://github.com/illumos/illumos-gate/blob/1d806c5f41/usr/src/boot/sys/sys/elf_common.h#L377-L462
  sh_type:
    0: null_type
    1: progbits
    2: symtab
    3: strtab
    4: rela
    5: hash
    6: dynamic
    7: note
    8: nobits
    9: rel
    10: shlib
    11: dynsym
    14: init_array
    15: fini_array
    16: preinit_array
    17: group
    18: symtab_shndx
    19: relr
    # 0x60000000: lo_os
    # 0x6fffffef: lo_sunw
    0x6fffffec:
      id: sunw_symnsort
      doc-ref: https://docs.oracle.com/cd/E37838_01/html/E36783/man-s.html#OSLLGchapter6-73445
    0x6fffffed:
      id: sunw_phname
      doc-ref: https://docs.oracle.com/cd/E37838_01/html/E36783/man-s.html#OSLLGchapter6-73445
    0x6fffffee:
      id: sunw_ancillary
      doc-ref: https://docs.oracle.com/cd/E37838_01/html/E36783/man-s.html#OSLLGchapter6-73445
    0x6fffffef: sunw_capchain
    0x6ffffff0: sunw_capinfo
    0x6ffffff1: sunw_symsort
    0x6ffffff2: sunw_tlssort
    0x6ffffff3: sunw_ldynsym
    0x6ffffff4: sunw_dof
    0x6ffffff5: sunw_cap
    # 0x6ffffff5: gnu_attributes
    0x6ffffff6: sunw_signature
    # 0x6ffffff6: gnu_hash
    # 0x6ffffff7: gnu_liblist
    0x6ffffff7: sunw_annotate
    0x6ffffff8: sunw_debugstr
    0x6ffffff9: sunw_debug
    0x6ffffffa: sunw_move
    0x6ffffffb: sunw_comdat
    0x6ffffffc: sunw_syminfo
    0x6ffffffd: sunw_verdef
    # 0x6ffffffd: gnu_verdef
    0x6ffffffe: sunw_verneed
    # 0x6ffffffe: gnu_verneed
    0x6fffffff: sunw_versym
    # 0x6fffffff: gnu_versym
    # 0x6fffffff: hi_sunw
    # 0x6fffffff: hi_os
    # 0x70000000: lo_proc
    0x70000000: sparc_gotdata
    0x70000001: amd64_unwind
    # 0x70000001: arm_exidx
    0x70000002: arm_preemptmap
    0x70000003: arm_attributes
    0x70000004:
      id: arm_debugoverlay
      doc-ref: https://github.com/illumos/illumos-gate/blob/1d806c5f41/usr/src/boot/sys/sys/elf_common.h#L425
    0x70000005:
      id: arm_overlaysection
      doc-ref: https://github.com/illumos/illumos-gate/blob/1d806c5f41/usr/src/boot/sys/sys/elf_common.h#L426
    # 0x7fffffff: hi_proc
    # 0x80000000: lo_user
    # 0xffffffff: hi_user
  # https://docs.oracle.com/cd/E37838_01/html/E36783/man-sts.html#OSLLGchapter7-27
  symbol_visibility:
    0: default
    1: internal
    2: hidden
    3: protected
    4: exported
    5: singleton
    6: eliminate
  # https://docs.oracle.com/cd/E37838_01/html/E36783/man-sts.html#OSLLGchapter6-tbl-21
  symbol_binding:
    0:
      id: local
      doc: not visible outside the object file containing their definition
    1:
      id: global_symbol
      -affected-by: 90
      doc: |
        visible to all object files being combined

        As of KSC 0.9, this enum key can't be called `global` because it would
        cause a syntax error in Python (it is a keyword).
    2:
      id: weak
      doc: like `symbol_binding::global_symbol`, but their definitions have lower precedence
    # 10: lo_os
    10:
      id: os10
      doc: reserved for operating system-specific semantics
    11:
      id: os11
      doc: reserved for operating system-specific semantics
    12:
      id: os12
      doc: reserved for operating system-specific semantics
    # 12: hi_os
    # 13: lo_proc
    13:
      id: proc13
      doc: reserved for processor-specific semantics
    14:
      id: proc14
      doc: reserved for processor-specific semantics
    15:
      id: proc15
      doc: reserved for processor-specific semantics
    # 15: hi_proc
  # https://docs.oracle.com/cd/E37838_01/html/E36783/man-sts.html#OSLLGchapter6-tbl-22
  symbol_type:
    0: no_type
    1:
      id: object
      doc: associated with a data object, such as a variable, an array, and so on
    2:
      id: func
      doc: associated with a function or other executable code
    3:
      id: section
      doc: associated with a section
    4:
      id: file
      doc: symbol's name gives the name of the source file associated with the object file
    5:
      id: common
      doc: labels an uninitialized common block
    6:
      id: tls
      doc: specifies a thread-local storage entity
    8:
      id: relc
      doc: complex relocation expression
      doc-ref: https://sourceware.org/git/?p=binutils-gdb.git;a=blob;f=include/elf/common.h;h=0d381f0d27;hb=HEAD#l1009
    9:
      id: srelc
      doc: signed complex relocation expression
      doc-ref: https://sourceware.org/git/?p=binutils-gdb.git;a=blob;f=include/elf/common.h;h=0d381f0d27;hb=HEAD#l1010
    # 10: lo_os
    10:
      id: gnu_ifunc
      doc: |
        reserved for OS-specific semantics

        `STT_GNU_IFUNC` is a GNU extension to ELF format that adds support for "indirect functions"
    11:
      id: os11
      doc: reserved for OS-specific semantics
    12:
      id: os12
      doc: reserved for OS-specific semantics
    # 12: hi_os
    # 13: lo_proc
    13:
      id: proc13
      doc: reserved for processor-specific semantics
    14:
      id: proc14
      doc: reserved for processor-specific semantics
    15:
      id: proc15
      doc: reserved for processor-specific semantics
    # 15: hi_proc
  # https://docs.oracle.com/cd/E23824_01/html/819-0690/chapter6-94076.html#chapter6-tbl-16
  # see also `_root.sh_idx_*` instances
  section_header_idx_special:
    0:
      id: undefined
      -orig-id: SHN_UNDEF
    # 0xff00: lo_reserve
    # 0xff00: lo_proc
    0xff00: before
    0xff01: after
    0xff02: amd64_lcommon
    # 0xff1f: hi_proc
    # 0xff20: lo_os
    # 0xff3f: lo_sunw
    0xff3f: sunw_ignore
    # 0xff3f: hi_sunw
    # 0xff3f: hi_os
    0xfff1: abs
    0xfff2: common
    0xffff: xindex
    # 0xffff: hi_reserve
  # https://docs.oracle.com/cd/E37838_01/html/E36783/chapter6-42444.html#OSLLGchapter6-tbl-52
  # https://sourceware.org/git/?p=glibc.git;a=blob;f=elf/elf.h;hb=0f62fe0532#l853
  dynamic_array_tags:
    0: "null"            # Marks end of dynamic section
    1: needed            # Name of needed library
    2: pltrelsz          # Size in bytes of PLT relocs
    3: pltgot            # Processor defined value
    4: hash              # Address of symbol hash table
    5: strtab            # Address of string table
    6: symtab            # Address of symbol table
    7: rela              # Address of Rela relocs
    8: relasz            # Total size of Rela relocs
    9: relaent           # Size of one Rela reloc
    10: strsz            # Size of string table
    11: syment           # Size of one symbol table entry
    12: init             # Address of init function
    13: fini             # Address of termination function
    14: soname           # Name of shared object
    15: rpath            # Library search path (deprecated)
    16: symbolic         # Start symbol search here
    17: rel              # Address of Rel relocs
    18: relsz            # Total size of Rel relocs
    19: relent           # Size of one Rel reloc
    20: pltrel           # Type of reloc in PLT
    21: debug            # For debugging; unspecified
    22: textrel          # Reloc might modify .text
    23: jmprel           # Address of PLT relocs
    24: bind_now         # Process relocations of object
    25: init_array       # Array with addresses of init fct
    26: fini_array       # Array with addresses of fini fct
    27: init_arraysz     # Size in bytes of DT_INIT_ARRAY
    28: fini_arraysz     # Size in bytes of DT_FINI_ARRAY
    29: runpath          # Library search path
    30: flags            # Flags for the object being loaded
    32: preinit_array    # Array with addresses of preinit fct
    33: preinit_arraysz  # Size in bytes of DT_PREINIT_ARRAY
    34: symtab_shndx     # Address of SYMTAB_SHNDX section
    35: relrsz
    36: relr
    37: relrent
    # 38: encoding  # special value (marker):
                    # Values `v >= ::encoding and v < ::lo_os` follow the rules
                    # for the interpretation of the d_un union as follows:
                    # even number == 'd_ptr', odd number == 'd_val' or none
                    # <https://github.com/tianocore/edk2-archive/blob/072289f45c/ArmPlatformPkg/Library/ArmShellCmdRunAxf/elf_common.h#L336-L340>
    # 0x6000000d: lo_os
    0x6000000d: sunw_auxiliary
    0x6000000e:
      id: sunw_rtldinf
      doc-ref:
        - https://github.com/gcc-mirror/gcc/blob/240f07805d/libphobos/libdruntime/core/sys/solaris/sys/link.d#L76
        - https://github.com/illumos/illumos-gate/blob/1d806c5f41/usr/src/uts/common/sys/link.h#L135
    0x6000000f:
      id: sunw_filter
      doc: |
        Note: <https://docs.oracle.com/cd/E37838_01/html/E36783/chapter6-42444.html#OSLLGchapter6-tbl-52>
        states that `DT_SUNW_FILTER` has the value `0x6000000e`, but this is
        apparently only a human error - that would make the value collide with
        the previous one (`DT_SUNW_RTLDINF`) and there is not even a single
        source supporting this other than verbatim copies of the same table.
      doc-ref:
        - https://github.com/gcc-mirror/gcc/blob/240f07805d/libphobos/libdruntime/core/sys/solaris/sys/link.d#L77
        - https://github.com/illumos/illumos-gate/blob/1d806c5f41/usr/src/uts/common/sys/link.h#L136
    0x60000010: sunw_cap
    0x60000011: sunw_symtab
    0x60000012: sunw_symsz
    # 0x60000013: sunw_encoding  # DT_* encoding rules apply again for values
                                 # `v >= ::sunw_encoding and v <= ::hi_os` (see
                                 # `::encoding` description)
    0x60000013: sunw_sortent
    0x60000014: sunw_symsort
    0x60000015: sunw_symsortsz
    0x60000016: sunw_tlssort
    0x60000017: sunw_tlssortsz
    0x60000018: sunw_capinfo
    0x60000019: sunw_strpad
    0x6000001a: sunw_capchain
    0x6000001b: sunw_ldmach
    0x6000001c: sunw_symtab_shndx
    0x6000001d: sunw_capchainent
    0x6000001e: sunw_deferred
    0x6000001f: sunw_capchainsz
    0x60000020: sunw_phname
    0x60000021: sunw_parent
    0x60000023: sunw_sx_aslr
    0x60000025: sunw_relax
    0x60000027: sunw_kmod
    0x60000029: sunw_sx_nxheap
    0x6000002b: sunw_sx_nxstack
    0x6000002d: sunw_sx_adiheap
    0x6000002f: sunw_sx_adistack
    0x60000031: sunw_sx_ssbd
    0x60000032: sunw_symnsort
    0x60000033: sunw_symnsortsz
    # 0x6ffff000: hi_os
    # 0x6ffffd00: val_rng_lo  # Values `v >= ::val_rng_lo and v <= ::val_rng_hi`
                              # use the 'd_val' field of the dynamic structure
    0x6ffffdf4:
      id: gnu_flags_1
      doc-ref: https://sourceware.org/git/?p=binutils-gdb.git;a=blob;f=include/elf/common.h;h=0d381f0d27;hb=HEAD#l1091
    0x6ffffdf5: gnu_prelinked   # Prelinking timestamp
    0x6ffffdf6: gnu_conflictsz  # Size of conflict section
    0x6ffffdf7: gnu_liblistsz   # Size of library list
    0x6ffffdf8: checksum
    0x6ffffdf9: pltpadsz
    0x6ffffdfa: moveent
    0x6ffffdfb: movesz
    0x6ffffdfc: feature_1       # Feature selection (DTF_*).
    0x6ffffdfd: posflag_1       # Flags for DT_* entries, effecting the following DT_* entry.
    0x6ffffdfe: syminsz         # Size of syminfo table (in bytes)
    0x6ffffdff: syminent        # Entry size of syminfo
    # 0x6ffffdff: val_rng_hi
    # 0x6ffffe00: addr_rng_lo  # Values `v >= ::addr_rng_lo and v <= ::addr_rng_hi`
                               # use the 'd_ptr' field of the dynamic structure
    0x6ffffef5: gnu_hash
    0x6ffffef6: tlsdesc_plt
    0x6ffffef7: tlsdesc_got
    0x6ffffef8: gnu_conflict
    0x6ffffef9: gnu_liblist
    0x6ffffefa: config
    0x6ffffefb: depaudit
    0x6ffffefc: audit
    0x6ffffefd: pltpad
    0x6ffffefe: movetab
    0x6ffffeff: syminfo
    # 0x6ffffeff: addr_rng_hi
    0x6ffffff0: versym
    0x6ffffff9: relacount
    0x6ffffffa: relcount
    0x6ffffffb: flags_1
    0x6ffffffc: verdef
    0x6ffffffd: verdefnum
    0x6ffffffe: verneed
    0x6fffffff: verneednum
    # 0x70000000: lo_proc
    0x70000001:
      id: sparc_register
      doc-ref: https://github.com/illumos/illumos-gate/blob/1d806c5f41/usr/src/boot/sys/sys/elf_common.h#L634-L635
    0x07000001:
      id: deprecated_sparc_register
      doc: |
        DT_SPARC_REGISTER was originally assigned 0x7000001. It is processor
        specific, and should have been in the range DT_LOPROC-DT_HIPROC
        instead of here. When the error was fixed,
        DT_DEPRECATED_SPARC_REGISTER was created to maintain backward
        compatability.
      doc-ref:
        - https://github.com/illumos/illumos-gate/blob/1d806c5f41/usr/src/cmd/sgs/libconv/common/dynamic.c#L522-L528
        - https://github.com/illumos/illumos-gate/blob/1d806c5f41/usr/src/boot/sys/sys/elf_common.h#L634-L635
    0x7ffffffd: auxiliary
    0x7ffffffe: used
    0x7fffffff: filter
    # 0x7fffffff: hi_proc
