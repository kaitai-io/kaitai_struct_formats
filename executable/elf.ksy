meta:
  id: elf
  title: Executable and Linkable Format
  application: SVR4 ABI and up, many *nix systems
  license: CC0-1.0
  ks-version: 0.8
doc-ref: https://sourceware.org/git/?p=glibc.git;a=blob;f=elf/elf.h;hb=HEAD
seq:
  # e_ident[EI_MAG0]..e[EI_MAG3]
  - id: magic
    size: 4
    contents: [0x7f, "ELF"]
    doc: File identification, must be 0x7f + "ELF".
  # e_ident[EI_CLASS]
  - id: bits
    type: u1
    enum: bits
    doc: |
      File class: designates target machine word size (32 or 64
      bits). The size of many integer fields in this format will
      depend on this setting.
  # e_ident[EI_DATA]
  - id: endian
    type: u1
    enum: endian
    doc: Endianness used for all integers.
  # e_ident[EI_VERSION]
  - id: ei_version
    type: u1
    doc: ELF header version.
  # e_ident[EI_OSABI]
  - id: abi
    type: u1
    enum: os_abi
    doc: |
      Specifies which OS- and ABI-related extensions will be used
      in this ELF file.
  - id: abi_version
    type: u1
    doc: |
      Version of ABI targeted by this ELF file. Interpretation
      depends on `abi` attribute.
  - id: pad
    size: 7
  - id: header
    type: endian_elf
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
          dynamic:
            io: _root._io
            pos: offset
            type: dynamic_section
            size: filesz
            if: type == ph_type::dynamic
          flags_obj:
            type: phdr_type_flags(flags64|flags32)
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
                'sh_type::dynstr': strings_struct
          name:
            io: _root.header.strings._io
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
            encoding: ASCII
      dynamic_section:
        seq:
          - id: entries
            type: dynamic_section_entry
            repeat: eos
      dynamic_section_entry:
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
          flag_1_values:
            type: dt_flag_1_values(value_or_ptr)
            if: "tag_enum == dynamic_array_tags::flags_1"
            -webide-parse-mode: eager
        -webide-representation: "{tag_enum}: {value_or_ptr} {flag_1_values:flags}"
      dynsym_section:
        seq:
          - id: entries
            type:
              switch-on: _root.bits
              cases:
                'bits::b32': dynsym_section_entry32
                'bits::b64': dynsym_section_entry64
            repeat: eos
      dynsym_section_entry32:
        seq:
          - id: name_offset
            type: u4
          - id: value
            type: u4
          - id: size
            type: u4
          - id: info
            type: u1
          - id: other
            type: u1
          - id: shndx
            type: u2
      dynsym_section_entry64:
        seq:
          - id: name_offset
            type: u4
          - id: info
            type: u1
          - id: other
            type: u1
          - id: shndx
            type: u2
          - id: value
            type: u8
          - id: size
            type: u8
    instances:
      program_headers:
        pos: program_header_offset
        repeat: expr
        repeat-expr: qty_program_header
        size: program_header_entry_size
        type: program_header
      section_headers:
        pos: section_header_offset
        repeat: expr
        repeat-expr: qty_section_header
        size: section_header_entry_size
        type: section_header
      strings:
        pos: section_headers[section_names_idx].ofs_body
        size: section_headers[section_names_idx].len_body
        type: strings_struct
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
    # ET_REL
    1: relocatable
    # ET_EXEC
    2: executable
    # ET_DYN
    3: shared
    # ET_CORE
    4: core
  machine:
    0x00: not_set
    # EM_SPARC
    0x02: sparc
    # EM_386
    0x03: x86
    0x08: mips
    0x14: powerpc
    # EM_ARM
    0x28: arm
    # EM_SH
    0x2A: superh
    0x32: ia_64
    # EM_X86_64
    0x3E: x86_64
    0xB7: aarch64
    0xF3: riscv
    0xF7: bpf
  ph_type:
    0: null_type
    1: load
    2: dynamic
    3: interp
    4: note
    5: shlib
    6: phdr
    7: tls
#    0x60000000: loos
    0x65041580: pax_flags
    0x6fffffff: hios
#    0x70000000: loproc
    0x70000001: arm_exidx
#    0x7fffffff: hiproc
    0x6474e550: gnu_eh_frame
    0x6474e551: gnu_stack
    0x6474e552: gnu_relro
  # http://docs.oracle.com/cd/E23824_01/html/819-0690/chapter6-94076.html#chapter6-73445
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
#    0x60000000: loos
#    0x6fffffef: losunw
    0x6fffffef: sunw_capchain
    0x6ffffff0: sunw_capinfo
    0x6ffffff1: sunw_symsort
    0x6ffffff2: sunw_tlssort
    0x6ffffff3: sunw_ldynsym
    0x6ffffff4: sunw_dof
    0x6ffffff5: sunw_cap
    0x6ffffff6: sunw_signature
    0x6ffffff7: sunw_annotate
    0x6ffffff8: sunw_debugstr
    0x6ffffff9: sunw_debug
    0x6ffffffa: sunw_move
    0x6ffffffb: sunw_comdat
    0x6ffffffc: sunw_syminfo
    0x6ffffffd: sunw_verdef
    0x6ffffffe: sunw_verneed
    0x6fffffff: sunw_versym
#    0x6fffffff: HISUNW
#    0x6fffffff: hios
#    0x70000000: loproc
    0x70000000: sparc_gotdata
    0x70000001: amd64_unwind
    0x70000001: arm_exidx
    0x70000002: arm_preemptmap
    0x70000003: arm_attributes
#    0x7fffffff: hiproc
#    0x80000000: louser
#    0xffffffff: hiuser
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
    32: encoding         # Start of encoded range
    32: preinit_array    # Array with addresses of preinit fct
    33: preinit_arraysz  # Size in bytes of DT_PREINIT_ARRAY
    34: maxpostags       # Number used
    0x6000000d: loos
    0x6000000d: sunw_auxiliary
    0x6000000e: sunw_rtldinf
    0x6000000e: sunw_filter
    0x60000010: sunw_cap
    0x60000011: sunw_symtab
    0x60000012: sunw_symsz
    0x60000013: sunw_encoding
    0x60000013: sunw_sortent
    0x60000014: sunw_symsort
    0x60000015: sunw_symsortsz
    0x60000016: sunw_tlssort
    0x60000017: sunw_tlssortsz
    0x60000018: sunw_capinfo
    0x60000019: sunw_strpad
    0x6000001a: sunw_capchain
    0x6000001b: sunw_ldmach
    0x6000001d: sunw_capchainent
    0x6000001f: sunw_capchainsz
    0x6ffff000: hios
    0x6ffffd00: valrnglo
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
    0x6ffffdff: valrnghi
    0x6ffffe00: addrrnglo
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
    0x6ffffeff: addrrnghi
    0x6ffffff0: versym
    0x6ffffff9: relacount
    0x6ffffffa: relcount
    0x6ffffffb: flags_1
    0x6ffffffc: verdef
    0x6ffffffd: verdefnum
    0x6ffffffe: verneed
    0x6fffffff: verneednum
    0x70000000: loproc
    0x70000001: sparc_register
    0x7ffffffd: auxiliary
    0x7ffffffe: used
    0x7fffffff: filter
    0x7fffffff: hiproc
