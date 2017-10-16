meta:
  id: elf
  title: Executable and Linkable Format
  application: SVR4 ABI and up, many *nix systems
  license: CC0-1.0
  ks-version: 0.8
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
      # Elf(32|64)_Shdr
      section_header:
        seq:
          # sh_name
          - id: name_offset
            type: u4
          # sh_type
          - id: type
            type: u4
            enum: sh_type
          # sh_flags
          - id: flags
            type:
              switch-on: _root.bits
              cases:
                'bits::b32': u4
                'bits::b64': u8
          # sh_addr
          - id: addr
            type:
              switch-on: _root.bits
              cases:
                'bits::b32': u4
                'bits::b64': u8
          # sh_offset
          - id: offset
            type:
              switch-on: _root.bits
              cases:
                'bits::b32': u4
                'bits::b64': u8
          # sh_size
          - id: size
            type:
              switch-on: _root.bits
              cases:
                'bits::b32': u4
                'bits::b64': u8
          # sh_link
          - id: linked_section_idx
            type: u4
          # sh_info
          - id: info
            size: 4
          # sh_addralign
          - id: align
            type:
              switch-on: _root.bits
              cases:
                'bits::b32': u4
                'bits::b64': u8
          # sh_entsize
          - id: entry_size
            type:
              switch-on: _root.bits
              cases:
                'bits::b32': u4
                'bits::b64': u8
        instances:
          body:
            io: _root._io
            pos: offset
            size: size
          name:
            io: _root.header.strings._io
            pos: name_offset
            type: strz
            encoding: ASCII
      strings_struct:
        seq:
          - id: entries
            type: strz
            repeat: eos
            encoding: ASCII
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
        pos: section_headers[section_names_idx].offset
        size: section_headers[section_names_idx].size
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
#    0x7fffffff: hiproc
#    0x80000000: louser
#    0xffffffff: hiuser
