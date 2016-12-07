meta:
  id: mach_o
  endian: le
seq:
  - id: header
    type: header
  - id: load_commands
    type: load_command
    repeat: expr
    repeat-expr: header.ncmds
types:
  header:
    seq:
      - id: magic
        type: u4
      - id: cputype
        type: u4
        enum: cputype
      - id: cpusubtype
        type: u4
      - id: filetype
        type: u4
        enum: filetype
      - id: ncmds
        type: u4
      - id: sizeofcmds
        type: u4
      - id: flags
        type: u4
    enums:
      cputype:
        0x7: i386
        0x8: mips
        0xc: arm
        0xe: sparc
        0x12: powerpc
        0x1000007: x86_64
        0x1000012: powerpc64
      filetype:
        # http://opensource.apple.com//source/xnu/xnu-1456.1.26/EXTERNAL_HEADERS/mach-o/loader.h
        0x1: object # relocatable object file
        0x2: execute # demand paged executable file
        0x3: fvmlib # fixed VM shared library file
        0x4: core # core file
        0x5: preload # preloaded executable file
        0x6: dylib # dynamically bound shared library
        0x7: dylinker # dynamic link editor
        0x8: bundle # dynamically bound bundle file
        0x9: dylib_stub # shared library stub for static linking only, no section contents
        0xa: dsym # companion file with only debug sections
        0xb: kext_bundle # x86_64 kexts
  load_command:
    seq:
      - id: cmd
        type: u4
        enum: lc
      - id: cmdsize
        type: u4
      - id: body
        size: cmdsize - 8
    enums:
      lc:
        # http://opensource.apple.com//source/xnu/xnu-1456.1.26/EXTERNAL_HEADERS/mach-o/loader.h
        0x80000000: req_dyld
        0x1: segment # segment of this file to be mapped
        0x2: symtab # link-edit stab symbol table info
        0x3: symseg # link-edit gdb symbol table info (obsolete)
        0x4: thread # thread
        0x5: unixthread # unix thread (includes a stack)
        0x6: loadfvmlib # load a specified fixed VM shared library
        0x7: idfvmlib # fixed VM shared library identification
        0x8: ident # object identification info (obsolete)
        0x9: fvmfile # fixed VM file inclusion (internal use)
        0xa: prepage # prepage command (internal use)
        0xb: dysymtab # dynamic link-edit symbol table info
        0xc: load_dylib # load a dynamically linked shared library
        0xd: id_dylib # dynamically linked shared lib ident
        0xe: load_dylinker # load a dynamic linker
        0xf: id_dylinker # dynamic linker identification
        0x10: prebound_dylib # modules prebound for a dynamically
        # linked shared library
        0x11: routines # image routines
        0x12: sub_framework # sub framework
        0x13: sub_umbrella # sub umbrella
        0x14: sub_client # sub client
        0x15: sub_library # sub library
        0x16: twolevel_hints # two-level namespace lookup hints
        0x17: prebind_cksum # prebind checksum
        0x80000018: load_weak_dylib # load a dynamically linked shared library that is allowed to be missing (all symbols are weak imported)
        0x19: segment_64 # 64-bit segment of this file to be mapped
        0x1a: routines_64 # 64-bit image routines
        0x1b: uuid # the uuid
        0x8000001c: rpath # runpath additions
        0x1d: code_signature # local of code signature
        0x1e: segment_split_info # local of info to split segments
        0x8000001f: reexport_dylib # load and re-export dylib
        0x20: lazy_load_dylib # delay load of dylib until first use
        0x21: encryption_info # encrypted segment information
        0x22: dyld_info # compressed dyld information
        0x80000022: dyld_info_only # compressed dyld information only
