meta:
  id: rpm
  file-extension:
    - rpm
    - srpm
    - src.rpm
    - drpm
  xref:
    pronom: fmt/795 # v3
    wikidata: Q492650
  license: CC0-1.0
  ks-version: 0.9
  endian: be
doc: |
  RPM version 3
doc-ref:
  - https://github.com/rpm-software-management/rpm/blob/master/doc/manual/format.md
  - https://github.com/rpm-software-management/rpm/blob/master/doc/manual/tags.md
  - https://refspecs.linuxbase.org/LSB_4.1.0/LSB-Core-generic/LSB-Core-generic/pkgformat.html
  - http://ftp.rpm.org/max-rpm/
seq:
  - id: lead
    type: lead
  - id: signature
    type: signature
  - id: boundary_padding
    size: (- _io.pos) % 8
  - id: header
    type: header
  #- id: payload
    #type: payload
types:
  lead:
    seq:
      - id: magic
        contents: [0xed, 0xab, 0xee, 0xdb]
      - id: version
        type: rpm_version
      - id: type
        type: u2
        enum: rpm_types
      - id: architecture
        -orig-id: archnum
        type: u2
        enum: architectures
      - id: package_name
        type: strz
        encoding: UTF-8
        size: 66
      - id: os
        -orig-id: osnum
        type: u2
        enum: operating_systems
      - id: signature_type
        -orig-id: signature_type
        type: u2
        valid: 5
      - id: reserved
        size: 16
  rpm_version:
    seq:
      - id: major
        type: u1
        valid: 0x3
      - id: minor
        type: u1
  # signature, which is almost identical to header
  # except that some of the tags have a different
  # meaning in signature and header.
  signature:
    seq:
      - id: header_record
        type: header_record
      - id: index_records
        type: signature_index_record
        repeat: expr
        repeat-expr: header_record.index_record_count
      - id: storage_section
        #type: storage_section
        size: header_record.index_storage_size
  header_record:
    seq:
      - id: magic
        contents: [0x8e, 0xad, 0xe8, 0x01]
      - id: reserved
        contents: [0, 0, 0, 0]
      - id: index_record_count
        -orig-id: nindex
        type: u4
        valid:
          min: 1
      - id: index_storage_size
        -orig-id: hsize
        type: u4
        doc: | 
          Size of the storage area for the data
          pointed to by the Index Records.
  signature_index_record:
    seq:
      - id: tag
        type: u4
        enum: signature_tags
      - id: record_type
        type: u4
        enum: header_types
      - id: record_offset
        type: u4
      - id: count
        type: u4
  # header, which is almost identical to signature
  # except that some of the tags have a different
  # meaning in signature and header.
  header:
    seq:
      - id: header_record
        type: header_record
      - id: index_records
        type: header_index_record
        repeat: expr
        repeat-expr: header_record.index_record_count
      - id: storage_section
        #type: storage_section
        size: header_record.index_storage_size
  header_index_record:
    seq:
      - id: tag
        type: u4
        enum: header_tags
      - id: record_type
        type: u4
        enum: header_types
      - id: record_offset
        type: u4
      - id: count
        type: u4
enums:
  rpm_types:
    0: binary
    1: source
  architectures:
    # these come (mostly) from rpmrc.in
    1: x86
    3: sparc
    4: mips
    5: ppc
    9: ia64
    11: mips64
    12: arm
    14: s390
    15: s390x
    16: ppc64
    17: sh
    18: xtensa
    19: aarch64
    22: riscv
    255: noarch
  operating_systems:
    # these come from rpmrc.in
    # in practice it will almost always be 1
    1: linux
    2: irix
  signature_tags:
    # Tags from LSB.
    # the first three are shared with header_tags
    62: signatures
    63: headerimmutable
    100: i18ntable
    # RPMSIGTAG_*
    267: dsa
    268: rsa
    269: sha1
    270: longsigsize
    273: sha256
    1000: size
    1002: pgp
    1004: md5
    1005: gpg
    1007: payloadsize
    1008: reservedspace
  header_tags:
    # Tags from LSB, some from lib/rpmtag.h
    # RPMTAG_*
    62: signatures
    63: headerimmutable
    100: i18ntable
    1000: name
    1001: version
    1002: release
    1004: summary
    1005: description
    1006: buildtime
    1007: buildhost
    1008: installtime # from lib/rpmtag.h
    1009: size
    1010: distribution
    1011: vendor
    1012: gif # from lib/rpmtag.h
    1013: xpm # from lib/rpmtag.h
    1014: license
    1015: packager
    1016: group
    1018: source # from lib/rpmtag.h
    1019: patch # from lib/rpmtag.h
    1020: url
    1021: os
    1022: arch
    1023: preinstall
    1024: postinstall
    1025: preuninstall
    1026: postuninstall
    1027: oldfilenames
    1028: filesizes
    1029: filestates # from lib/rpmtag.h
    1030: filemodes
    1033: rdevs
    1034: mtimes
    1035: md5s
    1036: linktos
    1037: fileflags
    1039: fileusername
    1040: filegroupname
    1044: sourcerpm
    1045: fileverifyflags
    1046: archivesize
    1047: providename
    1048: requireflags
    1049: requirename
    1050: requirename
    1053: conflictflags
    1054: conflictname
    1055: conflictversion
    1064: rpmversion
    1065: triggerscripts # from lib/rpmtag.h
    1066: triggername # from lib/rpmtag.h
    1067: triggerversion # from lib/rpmtag.h
    1068: triggerflags # from lib/rpmtag.h
    1069: triggerindex # from lib/rpmtag.h
    1080: changelogtime
    1081: changelogname
    1082: changelogtext
    1085: preinstall_interpreter # /bin/sh
    1086: postinstall_interpreter # /bin/sh
    1087: preuninstall_interpreter # /bin/sh
    1088: postuninstall_interpreter # /bin/sh
    1090: obsoletename
    1092: triggerscriptprog # from lib/rpmtag.h
    1094: cookie
    1095: filedevices
    1096: fileinodes
    1097: filelangs
    1112: provideflags
    1113: provideversion
    1114: obsoleteflags
    1115: obsoleteversion
    1116: dirindexes
    1117: basenames
    1118: dirnames
    1122: optflags
    1123: disturl
    1124: payload_format
    1125: payload_compressor
    1126: payload_flags
    1131: rhnplatform
    1132: platform
    # below are all from lib/rpmtag.h
    1140: filecolors
    1141: fileclass
    1142: classdict
    1143: filedependsx
    1144: filedependsn
    1145: dependsdict
    1146: sourcepkgid
    5011: filedigestalgo
    5012: bugurl
    5034: vcs
    5046: recommendname
    5047: recommendversion
    5048: recommendflags
    5049: suggestname
    5050: suggestversion
    5051: suggestname
    5062: encoding
    5092: payloaddigest
    5093: payloadddigestalgo
    5097: payloaddigestalt
  header_types:
    # from LSB
    0: not_implemented
    1: char
    2: int8
    3: int16
    4: int32
    5: int64 # reserved
    6: string # NUL terminated
    7: bin
    8: string_array # NUL terminated strings
    9: i18nstring # NUL terminated strings
