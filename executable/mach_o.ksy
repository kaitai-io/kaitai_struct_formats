# http://www.stonedcoder.org/~kd/lib/MachORuntime.pdf
# https://opensource.apple.com/source/python_modules/python_modules-43/Modules/macholib-1.5.1/macholib-1.5.1.tar.gz
# https://github.com/comex/cs/blob/master/macho_cs.py
# https://opensource.apple.com/source/Security/Security-55471/libsecurity_codesigning/requirements.grammar.auto.html
# https://github.com/opensource-apple/xnu/blob/10.11/bsd/sys/codesign.h
meta:
  id: mach_o
  endian: le
seq:
  - id: magic
    type: u4be
    enum: magic_type
  - id: header
    type: mach_header
  - id: load_commands
    type: load_command
    repeat: expr
    repeat-expr: header.ncmds
enums:
  magic_type:
    0xFEEDFACE: MH_MAGIC    # mach-o, big-endian,    x86
    0xCEFAEDFE: MH_CIGAM    # mach-o, little-endian, x86
    0xFEEDFACF: MH_MAGIC_64 # mach-o, big-endian,    x64
    0xCFFAEDFE: MH_CIGAM_64 # mach-o, little-endian, x64
    0xCAFEBABE: FAT_MAGIC   # fat,    big-endian
    0xBEBAFECA: FAT_CIGAM   # fat,    little-endian
  cpu_type:
    0xffffffff: any
    1:          vax
    2:          romp
    4:          ns32032
    5:          ns32332
    7:          i386
    8:          mips
    9:          ns32532
    11:         hppa
    12:         arm
    13:         mc88000
    14:         sparc
    15:         i860
    16:         i860_little
    17:         rs6000
    18:         powerpc
    0x1000000:  abi64     # flag
    0x1000007:  x86_64    # abi64 | i386
    0x1000012:  powerpc64 # abi64 | powerpc
  file_type:
    # http://opensource.apple.com//source/xnu/xnu-1456.1.26/EXTERNAL_HEADERS/mach-o/loader.h
    0x1: object      # relocatable object file
    0x2: execute     # demand paged executable file
    0x3: fvmlib      # fixed VM shared library file
    0x4: core        # core file
    0x5: preload     # preloaded executable file
    0x6: dylib       # dynamically bound shared library
    0x7: dylinker    # dynamic link editor
    0x8: bundle      # dynamically bound bundle file
    0x9: dylib_stub  # shared library stub for static linking only, no section contents
    0xa: dsym        # companion file with only debug sections
    0xb: kext_bundle # x86_64 kexts    
  load_command_type:
    # http://opensource.apple.com//source/xnu/xnu-1456.1.26/EXTERNAL_HEADERS/mach-o/loader.h
    0x80000000: REQ_DYLD
    0x1       : SEGMENT        # segment of this file to be mapped
    0x2       : SYMTAB         # link-edit stab symbol table info
    0x3       : SYMSEG         # link-edit gdb symbol table info (obsolete)
    0x4       : THREAD         # thread
    0x5       : UNIXTHREAD     # unix thread (includes a stack)
    0x6       : LOADFVMLIB     # load a specified fixed VM shared library
    0x7       : IDFVMLIB       # fixed VM shared library identification
    0x8       : IDENT          # object identification info (obsolete)
    0x9       : FVMFILE        # fixed VM file inclusion (internal use)
    0xa       : PREPAGE        # prepage command (internal use)
    0xb       : DYSYMTAB       # dynamic link-edit symbol table info
    0xc       : LOAD_DYLIB     # load a dynamically linked shared library
    0xd       : ID_DYLIB       # dynamically linked shared lib ident
    0xe       : LOAD_DYLINKER  # load a dynamic linker
    0xf       : ID_DYLINKER    # dynamic linker identification
    0x10      : PREBOUND_DYLIB # modules prebound for a dynamically
    # linked shared library
    0x11      : ROUTINES           # image routines
    0x12      : SUB_FRAMEWORK      # sub framework
    0x13      : SUB_UMBRELLA       # sub umbrella
    0x14      : SUB_CLIENT         # sub client
    0x15      : SUB_LIBRARY        # sub library
    0x16      : TWOLEVEL_HINTS     # two-level namespace lookup hints
    0x17      : PREBIND_CKSUM      # prebind checksum
    0x80000018: LOAD_WEAK_DYLIB    # load a dynamically linked shared library that is allowed to be missing (all symbols are weak imported)
    0x19      : SEGMENT_64         # 64-bit segment of this file to be mapped
    0x1a      : ROUTINES_64        # 64-bit image routines
    0x1b      : UUID               # the uuid
    0x8000001c: RPATH              # runpath additions
    0x1d      : CODE_SIGNATURE     # local of code signature
    0x1e      : SEGMENT_SPLIT_INFO # local of info to split segments
    0x8000001f: REEXPORT_DYLIB     # load and re-export dylib
    0x20      : LAZY_LOAD_DYLIB    # delay load of dylib until first use
    0x21      : ENCRYPTION_INFO    # encrypted segment information
    0x22      : DYLD_INFO          # compressed dyld information
    0x80000022: DYLD_INFO_ONLY     # compressed dyld information only
    0x23      : LOAD_UPWARD_DYLIB
    0x24      : VERSION_MIN_MACOSX
    0x25      : VERSION_MIN_IPHONEOS
    0x26      : FUNCTION_STARTS
    0x27      : DYLD_ENVIRONMENT
    0x28      : MAIN
    0x80000028: MAIN
    0x29      : DATA_IN_CODE
    0x2A      : SOURCE_VERSION
    0x2B      : DYLIB_CODE_SIGN_DRS
    0x2C      : ENCRYPTION_INFO_64
    0x2D      : LINKER_OPTION
    0x2E      : LINKER_OPTIMIZATION_HINT
    0x2F      : VERSION_MIN_TVOS
    0x30      : VERSION_MIN_WATCHOS   
  macho_flags:
    0x1      : NOUNDEFS                  # the object file has no undefined references
    0x2      : INCRLINK                  # the object file is the output of an incremental link against a base file and can't be link edited again
    0x4      : DYLDLINK                  # the object file is input for the dynamic linker and can't be staticly link edited again
    0x8      : BINDATLOAD                # the object file's undefined references are bound by the dynamic linker when loaded.
    0x10     : PREBOUND                  # the file has its dynamic undefined references prebound.
    0x20     : SPLIT_SEGS                # the file has its read-only and read-write segments split
    0x40     : LAZY_INIT                 # the shared library init routine is to be run lazily via catching memory faults to its writeable segments (obsolete)
    0x80     : TWOLEVEL                  # the image is using two-level name space bindings
    0x100    : FORCE_FLAT                # the executable is forcing all images to use flat name space bindings
    0x200    : NOMULTIDEFS               # this umbrella guarantees no multiple defintions of symbols in its sub-images so the two-level namespace hints can always be used.
    0x400    : NOFIXPREBINDING           # do not have dyld notify the prebinding agent about this executable
    0x800    : PREBINDABLE               # the binary is not prebound but can have its prebinding redone. only used when MH_PREBOUND is not set.
    0x1000   : ALLMODSBOUND              # indicates that this binary binds to all two-level namespace modules of its dependent libraries. only used when MH_PREBINDABLE and MH_TWOLEVEL are both set.
    0x2000   : SUBSECTIONS_VIA_SYMBOLS   # safe to divide up the sections into sub-sections via symbols for dead code stripping
    0x4000   : CANONICAL                 # the binary has been canonicalized via the unprebind operation
    0x8000   : WEAK_DEFINES              # the final linked image contains external weak symbols
    0x10000  : BINDS_TO_WEAK             # the final linked image uses weak symbols
    0x20000  : ALLOW_STACK_EXECUTION     # When this bit is set, all stacks in the task will be given stack execution privilege.  Only used in MH_EXECUTE filetypes.
    0x40000  : MH_ROOT_SAFE              # When this bit is set, the binary declares it is safe for use in processes with uid zero
    0x80000  : MH_SETUID_SAFE            # When this bit is set, the binary declares it is safe for use in processes when issetugid() is true
    0x100000 : MH_NO_REEXPORTED_DYLIBS  # When this bit is set on a dylib, the static linker does not need to examine dependent dylibs to see if any are re-exported
    0x200000 : MH_PIE                   # When this bit is set, the OS will load the main executable at a random address. Only used in MH_EXECUTE filetypes.
    0x400000 : MH_DEAD_STRIPPABLE_DYLIB
    0x800000 : MH_HAS_TLV_DESCRIPTORS
    0x1000000: MH_NO_HEAP_EXECUTION
    0x2000000: MH_APP_EXTENSION_SAFE
  vm_prot:
    0x00: none
    0x01: read
    0x02: write
    0x04: execute
    0x08: no_change
    0x10: copy
types:
  mach_header:
    seq:
      - id: cputype
        type: u4
        enum: cpu_type
      - id: cpusubtype
        type: u4
      - id: filetype
        type: u4
        enum: file_type
      - id: ncmds
        type: u4
      - id: sizeofcmds
        type: u4
      - id: flags
        type: u4
      - id: reserved
        type: u4
        if: _root.magic == magic_type::MH_MAGIC_64 or _root.magic == magic_type::MH_CIGAM_64
  load_command:
    seq:
      - id: type
        type: u4
        enum: load_command_type
      - id: size
        type: u4
      - id: body
        size: size - 8
        type:
          switch-on: type
          cases:
            'load_command_type::SEGMENT_64'        : segment_command_64
            'load_command_type::DYLD_INFO_ONLY'    : dyld_info_command
            'load_command_type::SYMTAB'            : symtab_command
            'load_command_type::DYSYMTAB'          : dysymtab_command
            'load_command_type::LOAD_DYLINKER'     : dylinker_command
            'load_command_type::UUID'              : uuid_command
            'load_command_type::VERSION_MIN_MACOSX': version_min_command
            'load_command_type::SOURCE_VERSION'    : source_version_command
            'load_command_type::MAIN'              : entry_point_command
            'load_command_type::LOAD_DYLIB'        : dylib_command
            'load_command_type::RPATH'             : rpath_command
            'load_command_type::FUNCTION_STARTS'   : linkedit_data_command
            'load_command_type::DATA_IN_CODE'      : linkedit_data_command
            'load_command_type::CODE_SIGNATURE'    : code_signature_command
    -webide-representation: '{type}: {body}'
  segment_command_64:
    seq:
      - id: segname
        type: str
        size: 16
        encoding: ascii
      - id: vmaddr
        type: u8
      - id: vmsize
        type: u8
      - id: fileoff
        type: u8
      - id: filesize
        type: u8
      - id: maxprot
        type: u4
        enum: vm_prot
      - id: initprot
        type: u4
        enum: vm_prot
      - id: nsects
        type: u4
      - id: flags
        type: u4
      - id: sections
        type: section_64
        repeat: expr
        repeat-expr: nsects
    types:
      section_64:
        seq:
          - id: sect_name
            size: 16
            type: str
            encoding: ascii
          - id: seg_name
            size: 16
            type: str
            encoding: ascii
          - id: addr
            type: u8
          - id: size
            type: u8
          - id: offset
            type: u4
          - id: align
            type: u4
          - id: reloff
            type: u4
          - id: nreloc
            type: u4
          - id: flags
            type: u4
          - id: reserved1
            type: u4
          - id: reserved2
            type: u4
          - id: reserved3
            type: u4
        -webide-representation: '{sect_name}: offs={offset}, size={size}'
    -webide-representation: '{segname} ({initprot}): offs={fileoff}, size={filesize}'
  dyld_info_command:
    seq:
      - id: rebase_off
        type: u4
      - id: rebase_size
        type: u4
      - id: bind_off
        type: u4
      - id: bind_size
        type: u4
      - id: weak_bind_off
        type: u4
      - id: weak_bind_size
        type: u4
      - id: lazy_bind_off
        type: u4
      - id: lazy_bind_size
        type: u4
      - id: export_off
        type: u4
      - id: export_size
        type: u4
  symtab_command:
    seq:
      - id: sym_off
        type: u4
      - id: n_syms
        type: u4
      - id: str_off
        type: u4
      - id: str_size
        type: u4
  dysymtab_command:
    seq:
      - id: i_local_sym
        type: u4
      - id: n_local_sym
        type: u4
      - id: i_ext_def_sym
        type: u4
      - id: n_ext_def_sym
        type: u4
      - id: i_undef_sym
        type: u4
      - id: n_undef_sym
        type: u4
      - id: toc_off
        type: u4
      - id: n_toc
        type: u4
      - id: mod_tab_off
        type: u4
      - id: n_mod_tab
        type: u4
      - id: ext_ref_sym_off
        type: u4
      - id: n_ext_ref_syms
        type: u4
      - id: indirect_sym_off
        type: u4
      - id: n_indirect_syms
        type: u4
      - id: ext_rel_off
        type: u4
      - id: n_ext_rel
        type: u4
      - id: loc_rel_off
        type: u4
      - id: n_loc_rel
        type: u4
  lc_str:
    seq:
      - id: length
        type: u4
      - id: value
        type: strz
        encoding: UTF-8
    -webide-representation: '{value}'
  dylinker_command:
    seq:
      - id: name
        type: lc_str
    -webide-representation: '{name}'
  uuid_command:
    seq:
      - id: uuid
        size: 16
    -webide-representation: 'uuid={uuid}'
  version:
    seq:
      - id: p1
        type: u1
      - id: minor
        type: u1
      - id: major
        type: u1
      - id: release
        type: u1
    -webide-representation: '{major:dec}.{minor:dec}'
  version_min_command:
    seq:
      - id: version
        type: version
      - id: reserved
        type: version
    -webide-representation: 'v:{version}, r:{reserved}'
  source_version_command:
    seq:
      - id: version
        type: u8
    -webide-representation: 'v:{version:dec}'
  entry_point_command:
    seq:
      - id: entry_off
        type: u8
      - id: stack_size
        type: u8
    -webide-representation: 'entry_off={entry_off}, stack_size={stack_size}'
  dylib_command:
    seq:
      - id: name_offset
        type: u4
      - id: timestamp
        type: u4
      - id: current_version
        type: u4
      - id: compatibility_version
        type: u4
      - id: name
        type: strz
        encoding: utf-8
    -webide-representation: '{name}'
  rpath_command:
    seq:
      - id: path_offset
        type: u4
      - id: path
        type: strz
        encoding: utf-8
    -webide-representation: '{path}'
  linkedit_data_command:
    seq:
      - id: data_off
        type: u4
      - id: data_size
        type: u4
    -webide-representation: 'offs={data_off}, size={data_size}'
  code_signature_command:
    seq:
      - id: data_off
        type: u4
      - id: data_size
        type: u4
    instances:
      code_signature:
        io: _root._io
        pos: data_off
        type: cs_blob
        size: data_size
  cs_blob:
    seq:
      - id: magic
        type: u4be
        enum: cs_magic
      - id: length
        type: u4be
      - id: body
        size: length - 8
        type:
          switch-on: magic
          cases:
            'cs_magic::CSMAGIC_REQUIREMENT'       : requirement
            'cs_magic::CSMAGIC_REQUIREMENTS'      : entitlements
            'cs_magic::CSMAGIC_CODEDIRECTORY'     : code_directory
            'cs_magic::CSMAGIC_ENTITLEMENT'       : entitlement
            'cs_magic::CSMAGIC_BLOBWRAPPER'       : blob_wrapper
            'cs_magic::CSMAGIC_EMBEDDED_SIGNATURE': super_blob
            'cs_magic::CSMAGIC_DETACHED_SIGNATURE': super_blob
    enums:
      cs_magic:
        0xfade0c00: CSMAGIC_REQUIREMENT
        0xfade0c01: CSMAGIC_REQUIREMENTS
        0xfade0c02: CSMAGIC_CODEDIRECTORY
        0xfade7171: CSMAGIC_ENTITLEMENT
        0xfade0b01: CSMAGIC_BLOBWRAPPER
        0xfade0cc0: CSMAGIC_EMBEDDED_SIGNATURE
        0xfade0cc1: CSMAGIC_DETACHED_SIGNATURE
    types:
      code_directory:
        seq:
          - id: version
            type: u4be
          - id: flags
            type: u4be
          - id: hash_offset
            type: u4be
          - id: ident_offset
            type: u4be
          - id: n_special_slots
            type: u4be
          - id: n_code_slots
            type: u4be
          - id: code_limit
            type: u4be
          - id: hash_size
            type: u1
          - id: hash_type
            type: u1
          - id: spare1
            type: u1
          - id: page_size
            type: u1
          - id: spare2
            type: u4be
          - id: scatter_offset
            type: u4be
            if: version >= 0x20100
          - id: team_id_offset
            type: u4be
            if: version >= 0x20200
        instances:
          ident:
            pos: ident_offset - 8
            type: strz
            encoding: utf-8
            -webide-parse-mode: eager
          team_id:
            pos: team_id_offset - 8
            type: strz
            encoding: utf-8
            -webide-parse-mode: eager
          hashes:
            pos: hash_offset - 8 - hash_size * n_special_slots
            repeat: expr
            repeat-expr: n_special_slots + n_code_slots
            size: hash_size
      blob_index:
        seq:
          - id: type
            type: u4be
            enum: type
          - id: offset
            type: u4be
        instances:
          blob:
            pos: offset - 8
            io: _parent._io
            size-eos: true
            type: cs_blob
        enums:
          type:
            0:       CSSLOT_CODEDIRECTORY
            1:       CSSLOT_INFOSLOT
            2:       CSSLOT_REQUIREMENTS
            3:       CSSLOT_RESOURCEDIR
            4:       CSSLOT_APPLICATION
            5:       CSSLOT_ENTITLEMENTS
            0x1000:  CSSLOT_ALTERNATE_CODEDIRECTORIES
            0x10000: CSSLOT_SIGNATURESLOT
      data:
        seq:
          - id: length
            type: u4be
          - id: data
            size: length
          - id: padding
            size: 4 - (length & 3)
        -webide-representation: "{data}"
      match:
        seq:
          - id: match_op
            type: u4be
            enum: op
          - id: data
            type: data
            if: 'match_op != op::exists'
        enums:
          op:
            0: exists
            1: equal
            2: contains
            3: begins_with
            4: ends_with
            5: less_than
            6: greater_than
            7: less_equal
            8: greater_equal
        -webide-representation: "{match_op} {data.data:str}"
      expr:
        seq:
          - id: op
            type: u4be
            enum: op
          - id: data
            type:
              switch-on: op
              cases:
                #'op::false'               : 'false'
                #'op::true'                : 'true'
                'op::ident'               : ident_expr
                #'op::apple_anchor'        : 'anchor apple'
                'op::anchor_hash'         : anchor_hash_expr
                'op::info_key_value'      : data
                'op::and'                 : and_expr
                'op::or'                  : or_expr
                'op::cd_hash'             : data
                'op::not'                 : expr
                'op::info_key_field'      : info_key_field_expr
                'op::cert_field'          : cert_field_expr
                'op::trusted_cert'        : cert_slot_expr
                #'op::trusted_certs'       : 'anchor trusted'
                'op::cert_generic'        : cert_generic_expr
                'op::apple_generic_anchor': apple_generic_anchor_expr
                'op::entitlement_field'   : entitlement_field_expr
        enums:
          op:
            0: 'false'               # unconditionally false
            1: 'true'                # unconditionally true
            2: ident                 # match canonical code [string]
            3: apple_anchor          # signed by Apple as Apple's product ("anchor apple")
            4: anchor_hash           # match anchor [cert hash]
            5: info_key_value        # *legacy* - use opInfoKeyField [key; value]
            6: and                   # binary prefix expr AND expr [expr; expr]
            7: or                    # binary prefix expr OR expr
            8: cd_hash               # match hash of CodeDirectory directly
            9: not                   # logical inverse
            10: info_key_field       # Info.plist key field [string; match suffix]
            11: cert_field           # Certificate field [cert index; field name; match suffix]
            12: trusted_cert         # require trust settings to approve one particular cert [cert index]
            13: trusted_certs        # require trust settings to approve the cert chain
            14: cert_generic         # Certificate component by OID [cert index; oid; match suffix]
            15: apple_generic_anchor # signed by Apple in any capacity ("anchor apple generic")
            16: entitlement_field    # entitlement dictionary field [string; match suffix]
          cert_slot:
            0xffffffff: anchor_cert
            0: left_cert
        types:
          ident_expr:
            seq:
              - id: identifier
                type: data
            -webide-representation: "identifier {identifier.data:str}"
          apple_generic_anchor_expr:
            instances:
              value:
                value: '"anchor apple generic"'
            -webide-representation: "anchor apple generic"
          cert_slot_expr:
            seq:
              - id: value
                type: u4be
                enum: cert_slot
          and_expr:
            seq:
              - id: left
                type: expr
              - id: right
                type: expr
            -webide-representation: "({left}) AND ({right})"
          or_expr:
            seq:
              - id: left
                type: expr
              - id: right
                type: expr
            -webide-representation: "({left}) OR ({right})"
          anchor_hash_expr:
            seq:
              - id: cert_slot
                type: u4be
                enum: cert_slot
              - id: data
                type: data
          info_key_field_expr:
            seq:
              - id: data
                type: data
              - id: match
                type: match
          entitlement_field_expr:
            seq:
              - id: data
                type: data
              - id: match
                type: match
          cert_field_expr:
            seq:
              - id: cert_slot
                type: u4be
                enum: cert_slot
              - id: data
                type: data
              - id: match
                type: match
            -webide-representation: "{cert_slot}[{data.data:str}] {match}"
          cert_generic_expr:
            seq:
              - id: cert_slot
                type: u4be
                enum: cert_slot
              - id: data
                type: data
              - id: match
                type: match
            -webide-representation: "{cert_slot}[{data.data:hex}] {match}"
        -webide-representation: '{data}'
      requirement:
        seq:
          - id: kind
            type: u4be
          - id: expr
            type: expr
      entitlement:
        seq:
          - id: data
            size-eos: true
        -webide-representation: "{data:str}"
      entitlements_blob_index:
        seq:
          - id: type
            type: u4be
            enum: type
          - id: offset
            type: u4be
        instances:
          value:
            type: cs_blob
            pos: offset - 8
        enums:
          type:
            1: kSec_Host_Requirement_Type
            2: kSec_Guest_Requirement_Type
            3: kSec_Designated_Requirement_type
            4: kSec_Library_Requirement_Type
      entitlements:
        seq:
          - id: count
            type: u4be
          - id: items
            type: entitlements_blob_index
            repeat: expr
            repeat-expr: count
      blob_wrapper:
        seq:
          - id: data
            size-eos: true
      super_blob:
        seq:
          - id: count
            type: u4be
          - id: blobs
            type: blob_index
            repeat: expr
            repeat-expr: count
