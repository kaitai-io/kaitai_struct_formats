meta:
  id: rpm
  title: RPM Package Manager files
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
  This parser is for the RPM version 3 file format which is the current version
  of the file format used by RPM 2.1 and later (including RPM version 4.x, which
  is the current version of the RPM tool). There are historical versions of the
  RPM file format, as well as a currently abandoned fork (rpm5). These formats
  are not covered by this specification.
doc-ref:
  - https://github.com/rpm-software-management/rpm/blob/911448f2/doc/manual/format.md
  - https://github.com/rpm-software-management/rpm/blob/911448f2/doc/manual/tags.md
  - https://refspecs.linuxbase.org/LSB_5.0.0/LSB-Core-generic/LSB-Core-generic/pkgformat.html
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
  # - id: payload
  #   size: ??
  #   doc: |
  #     if signature has a SIZE value, then it is:
  #     signature[SIZE][0] - sizeof<header>
types:
  dummy: {}
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
        size: 66
        type: strz
        encoding: UTF-8
      - id: os
        -orig-id: osnum
        type: u2
        enum: operating_systems
      - id: signature_type
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
        size: header_record.index_storage_size
        type: dummy
  signature_index_record:
    -webide-representation: '{tag}'
    seq:
      - id: tag
        type: u4
        enum: signature_tags
      - id: record_type
        type: u4
        enum: header_types
      - id: ofs_record
        type: u4
      - id: count
        type: u4
    instances:
      body:
        io: _parent.storage_section._io
        pos: ofs_record
        type:
          switch-on: record_type
          cases:
            header_types::int8: record_type_int8(count)
            header_types::int16: record_type_int16(count)
            header_types::int32: record_type_int32(count)
            header_types::string: record_type_string
            header_types::bin: record_type_bin(count)
            header_types::string_array: record_type_string_array(count)
            header_types::i18n_string: record_type_string_array(count)
  record_type_int8:
    params:
      - id: count
        type: u4
    seq:
      - id: values
        type: u2
        repeat: expr
        repeat-expr: count
  record_type_int16:
    params:
      - id: count
        type: u4
    seq:
      - id: values
        type: u2
        repeat: expr
        repeat-expr: count
  record_type_int32:
    params:
      - id: count
        type: u4
    seq:
      - id: values
        type: u4
        repeat: expr
        repeat-expr: count
  record_type_string:
    seq:
      - id: values
        type: strz
        encoding: UTF-8
        repeat: expr
        repeat-expr: 1
  record_type_bin:
    params:
      - id: count
        type: u4
    seq:
      - id: values
        size: count
        repeat: expr
        repeat-expr: 1
  record_type_string_array:
    params:
      - id: count
        type: u4
    seq:
      - id: values
        type: strz
        encoding: UTF-8
        repeat: expr
        repeat-expr: count
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
        size: header_record.index_storage_size
        type: dummy
  header_index_record:
    -webide-representation: '{tag}'
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
    instances:
      body:
        io: _parent.storage_section._io
        pos: record_offset
        type:
          switch-on: record_type
          cases:
            header_types::int8: record_type_int8(count)
            header_types::int16: record_type_int16(count)
            header_types::int32: record_type_int32(count)
            header_types::string: record_type_string
            header_types::bin: record_type_bin(count)
            header_types::string_array: record_type_string_array(count)
            header_types::i18n_string: record_type_string_array(count)
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
enums:
  rpm_types:
    0: binary
    1: source
  architectures:
    # these come (mostly) from <https://github.com/rpm-software-management/rpm/blob/911448f2/rpmrc.in#L159>
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
    # these come from <https://github.com/rpm-software-management/rpm/blob/911448f2/rpmrc.in#L261>
    # in practice it will almost always be 1
    1: linux
    2: irix
  signature_tags:
    # Tags from LSB.
    # the first three are shared with header_tags
    62:
      id: signatures
      -orig-id: HEADER_SIGNATURES
    63:
      id: header_immutable
      -orig-id: HEADER_IMMUTABLE
    100:
      id: i18n_table
      -orig-id: HEADER_I18NTABLE
    # RPMSIGTAG_*
    267:
      id: dsa
      -orig-id: RPMSIGTAG_DSA
    268:
      id: rsa
      -orig-id: RPMSIGTAG_RSA
    269:
      id: sha1
      -orig-id: RPMSIGTAG_SHA1
    270:
      id: long_sig_size
      -orig-id: RPMTAG_LONGSIGSIZE
    273:
      id: sha256
      -orig-id: RPMTAG_SHA256HEADER
    1000:
      id: size
      -orig-id: RPMSIGTAG_SIZE
      doc: Header + payload size (32bit) in bytes.
    1002:
      id: pgp
      -orig-id: RPMSIGTAG_PGP
      doc: PGP 2.6.3 signature.
    1004:
      id: md5
      -orig-id: RPMSIGTAG_MD5
      doc: MD5 signature
    1005:
      id: gpg
      -orig-id: RPMSIGTAG_GPG
      doc: GnuPG signature
    1007:
      id: payload_size
      -orig-id: RPMSIGTAG_PAYLOADSIZE
      doc: Uncompressed payload size (32bit) in bytes.
    1008:
      id: reserved_space
      -orig-id: RPMSIGTAG_RESERVEDSPACE
      doc: Space reserved for signatures
  header_tags:
    # Tags from LSB, some from [lib/rpmtag.h](https://github.com/rpm-software-management/rpm/blob/911448f2/lib/rpmtag.h)
    # This includes all tags, except obsolete, internal and
    # unimplemented tags, except when present in LSB
    62:
      id: signatures
      -orig-id: HEADER_SIGNATURES
    63:
      id: header_immutable
      -orig-id: HEADER_IMMUTABLE
    100:
      id: i18n_table
      -orig-id: HEADER_I18NTABLE
    # RPMTAG_*
    1000:
      id: name
      -orig-id: RPMTAG_NAME
      doc: Specifies the name of the package.
    1001:
      id: version
      -orig-id: RPMTAG_VERSION
      doc: Specifies the version of the package.
    1002:
      id: release
      -orig-id: RPMTAG_RELEASE
      doc: Specifies the release of the package.
    1003:
      id: epoch # from lib/rpmtag.h
      -orig-id: RPMTAG_EPOCH
    1004:
      id: summary
      -orig-id: RPMTAG_SUMMARY
      doc: |
        Specifies the summary description of the package. The summary
        value pointed to by this index record contains a one line
        description of the package.
    1005:
      id: description
      -orig-id: RPMTAG_DESCRIPTION
      doc: |
        Specifies the description of the package. The description value
        pointed to by this index record contains a full desription of
        the package.
    1006:
      id: build_time
      -orig-id: RPMTAG_BUILDTIME
      doc: |
        Specifies the time as seconds since the epoch
        at which the package was built.
    1007:
      id: build_host
      -orig-id: RPMTAG_BUILDHOST
      doc: Specifies the hostname of the system on which the package was built.
    1008:
      id: install_time # from lib/rpmtag.h
      -orig-id: RPMTAG_INSTALLTIME
    1009:
      id: size
      -orig-id: RPMTAG_SIZE
      doc: Specifies the sum of the sizes of the regular files in the archive.
    1010:
      id: distribution
      -orig-id: RPMTAG_DISTRIBUTION
      doc: Contains the name of the distribution on which the package was built.
    1011:
      id: vendor
      -orig-id: RPMTAG_VENDOR
      doc: Contains the name of the organization that produced the package.
    1012:
      id: gif # from lib/rpmtag.h
      -orig-id: RPMTAG_GIF
    1013:
      id: xpm # from lib/rpmtag.h
      -orig-id: RPMTAG_XPM
    1014:
      id: license
      -orig-id: RPMTAG_LICENSE
      doc: Specifies the license which applies to this package.
    1015:
      id: packager
      -orig-id: RPMTAG_PACKAGER
      doc: Identifies the tool used to build the package.
    1016:
      id: group
      -orig-id: RPMTAG_GROUP
      doc: Specifies the administrative group to which this package belongs.
    1018:
      id: source # from lib/rpmtag.h
      -orig-id: RPMTAG_SOURCE
    1019:
      id: patch # from lib/rpmtag.h
      -orig-id: RPMTAG_PATCH
    1020:
      id: url
      -orig-id: RPMTAG_URL
      doc: Generic package information URL.
    1021:
      id: os
      -orig-id: RPMTAG_OS
      doc: Specifies the OS of the package.
    1022:
      id: arch
      -orig-id: RPMTAG_ARCH
      doc: Specifies the architecture of the package.
    1023:
      id: pre_install_scriptlet
      -orig-id: RPMTAG_PREIN
      doc: |
        Specifies the preinstall scriptlet. If present, then
        preinstall_interpreter shall also be present.
    1024:
      id: post_install_scriptlet
      -orig-id: RPMTAG_POSTIN
      doc: |
        Specifies the postinstall scriptlet. If present, then
        postinstall_interpreter shall also be present.
    1025:
      id: pre_uninstall_scriptlet
      -orig-id: RPMTAG_PREUN
      doc: |
        Specifies the preuninstall scriptlet. If present, then
        preuninstall_interpreter shall also be present.
    1026:
      id: post_uninstall_scriptlet
      -orig-id: RPMTAG_POSTUN
      doc: |
        Specifies the postuninstall scriptlet. If present, then
        postuninstall_interpreter shall also be present.
    1027:
      id: old_file_names
      -orig-id: RPMTAG_OLDFILENAMES
    1028:
      id: file_sizes
      -orig-id: RPMTAG_FILESIZES
      doc: Specifies the size of each file in the archive.
    1029:
      id: file_states # from lib/rpmtag.h
      -orig-id: RPMTAG_FILESTATES
    1030:
      id: file_modes
      -orig-id: RPMTAG_FILEMODES
      doc: The mode of each file in the archive.
    1033:
      id: device_number
      -orig-id: RPMTAG_FILERDEVS
      doc: The device number from which the file was copied.
    1034:
      id: mtimes
      -orig-id: RPMTAG_FILEMTIMES
      doc: |
        The modification time in seconds since the epoch
        of each file in the archive.
    1035:
      id: file_digests
      -orig-id: RPMTAG_FILEDIGESTS
      doc: |
        The ASCII representation of the MD5 sum of the corresponding
        file contents. This value is empty if the corresponding archive
        entry is not a regular file.
    1036:
      id: link_tos
      -orig-id: RPMTAG_FILELINKTOS
      doc: The target for a symlink, otherwise NULL.
    1037:
      id: file_flags
      -orig-id: RPMTAG_FILEFLAGS
      doc: |
        Specifies the bit(s) to classify and control how files
        are to be installed.
    1039:
      id: file_owner
      -orig-id: RPMTAG_FILEUSERNAME
      doc: Specifies the owner of the corresponding file.
    1040:
      id: file_group
      -orig-id: RPMTAG_FILEGROUPNAME
      doc: Specifies the group of the corresponding file.
    1043:
      id: icon # from lib/rpmtag.h
      -orig-id: RPMTAG_ICON
    1044:
      id: source_rpm
      -orig-id: RPMTAG_SOURCERPM
      doc: Specifies the name of the source RPM.
    1045:
      id: file_verify_flags
      -orig-id: RPMTAG_FILEVERIFYFLAGS
      doc: |
        Specifies the bit(s) to control how files are to be verified
        after install, specifying which checks should be performed.
    1046:
      id: archive_size
      -orig-id: RPMTAG_ARCHIVESIZE
      doc: |
        Specifies the uncompressed size of the Payload archive,
        including the cpio headers.
    1047:
      id: provide_name
      -orig-id: RPMTAG_PROVIDENAME
      doc: The name of the dependency provided by this package.
    1048:
      id: require_flags
      -orig-id: RPMTAG_REQUIREFLAGS
      doc: Bits(s) to specify the dependency range and context.
    1049:
      id: require_name
      -orig-id: RPMTAG_REQUIRENAME
      doc: Indicates the dependencies for this package.
    1050:
      id: require_version
      -orig-id: RPMTAG_REQUIREVERSION
      doc: |
        Indicates the versions associated with the values found
        in the require_name index.
    1051:
      id: no_source # from lib/rpmtag.h
      -orig-id: RPMTAG_NOSOURCE
    1052:
      id: no_patch # from lib/rpmtag.h
      -orig-id: RPMTAG_NOPATCH
    1053:
      id: conflict_flags
      -orig-id: RPMTAG_CONFLICTFLAGS
      doc: Bits(s) to specify the conflict range and context.
    1054:
      id: conflict_name
      -orig-id: RPMTAG_CONFLICTNAME
      doc: Indicates the conflicting dependencies for this package.
    1055:
      id: conflict_version
      -orig-id: RPMTAG_CONFLICTVERSION
      doc: |
        Indicates the versions associated with the
        values found in the conflict_name index.
    1059:
      id: exclude_arch # from lib/rpmtag.h
      -orig-id: RPMTAG_EXCLUDEARCH
    1060:
      id: exclude_os # from lib/rpmtag.h
      -orig-id: RPMTAG_EXCLUDEOS
    1061:
      id: exclusive_arch # from lib/rpmtag.h
      -orig-id: RPMTAG_EXCLUSIVEARCH
    1062:
      id: exclusive_os # from lib/rpmtag.h
      -orig-id: RPMTAG_EXCLUSIVEOS
    1064:
      id: rpm_version
      -orig-id: RPMTAG_RPMVERSION
      doc: Indicates the version of RPM tool used to build this package.
    1065:
      id: trigger_scripts # from lib/rpmtag.h
      -orig-id: RPMTAG_TRIGGERSCRIPTS
    1066:
      id: trigger_name # from lib/rpmtag.h
      -orig-id: RPMTAG_TRIGGERNAME
    1067:
      id: trigger_version # from lib/rpmtag.h
      -orig-id: RPMTAG_TRIGGERVERSION
    1068:
      id: trigger_flags # from lib/rpmtag.h
      -orig-id: RPMTAG_TRIGGERFLAGS
    1069:
      id: trigger_index # from lib/rpmtag.h
      -orig-id: RPMTAG_TRIGGERINDEX
    1079:
      id: verify_script # from lib/rpmtag.h
      -orig-id: RPMTAG_VERIFYSCRIPT
    1080:
      id: changelog_time
      -orig-id: RPMTAG_CHANGELOGTIME
      doc: |
        Specifies the Unix time in seconds since the epoch
        associated with each entry in the Changelog file.
    1081:
      id: changelog_name
      -orig-id: RPMTAG_CHANGELOGNAME
      doc: Specifies the name of who made a change to this package.
    1082:
      id: changelog_text
      -orig-id: RPMTAG_CHANGELOGTEXT
      doc: Specifies the changes asssociated with a changelog entry.
    1085:
      id: preinstall_interpreter
      -orig-id: RPMTAG_PREINPROG
      doc: |
        Specifies the name of the interpreter to which the preinstall
        scriptlet will be passed. The interpreter pointed to by this
        index record shall be /bin/sh.
    1086:
      id: postinstall_interpreter
      -orig-id: RPMTAG_POSTINPROG
      doc: |
        Specifies the name of the interpreter to which the postinstall
        scriptlet will be passed. The intepreter pointed to by this
        index record shall be /bin/sh.
    1087:
      id: preuninstall_interpreter
      -orig-id: RPMTAG_PREUNPROG
      doc: |
        Specifies the name of the interpreter to which the preuninstall
        scriptlet will be passed. The interpreter pointed to by this index
        record shall be /bin/sh.
    1088:
      id: postuninstall_interpreter
      -orig-id: RPMTAG_POSTUNPROG
      doc: |
        Specifies the name of the interpreter to which the postuninstall
        scriptlet will be passed. The interpreter pointed to by this index
        record shall be /bin/sh.
    1089:
      id: build_archs # from lib/rpmtag.h
      -orig-id: RPMTAG_BUILDARCHS
    1090:
      id: obsolete_name # from lib/rpmtag.h
      -orig-id: RPMTAG_OBSOLETENAME
      doc: Indicates the obsoleted dependencies for this package.
    1091:
      id: verify_script_prog # from lib/rpmtag.h
      -orig-id: RPMTAG_VERIFYSCRIPTPROG
    1092:
      id: trigger_script_prog # lib/rpmtag.h
      -orig-id: RPMTAG_TRIGGERSCRIPTPROG
    1094:
      id: cookie
      -orig-id: RPMTAG_COOKIE
      doc: Contains an opaque string whose contents are undefined.
    1095:
      id: file_devices
      -orig-id: RPMTAG_FILEDEVICES
      doc: Specifies the 16 bit device number from which the file was copied.
    1096:
      id: file_inodes
      -orig-id: RPMTAG_FILEINODES
      doc: |
        Specifies the inode value from the original file system
        on the the system on which it was built.
    1097:
      id: file_langs
      -orig-id: RPMTAG_FILELANGS
      doc: |
        Specifies a per-file locale marker used to install only locale
        specific subsets of files when the package is installed.
    1098:
      id: prefixes # from lib/rpmtag.h
      -orig-id: RPMTAG_PREFIXES
    1099:
      id: installation_prefixes # from lib/rpmtag.h
      -orig-id: RPMTAG_INSTPREFIXES
    1106:
      id: source_package # from lib/rpmtag.h
      -orig-id: RPMTAG_SOURCEPACKAGE
    1112:
      id: provide_flags
      -orig-id: RPMTAG_PROVIDEFLAGS
      doc: Bits(s) to specify the conflict range and context.
    1113:
      id: provide_version
      -orig-id: RPMTAG_PROVIDEVERSION
      doc: |
        Indicates the versions associated with the values found
        in the provide_name index.
    1114:
      id: obsolete_flags
      -orig-id: RPMTAG_OBSOLETEFLAGS
    1115:
      id: obsolete_version
      -orig-id: RPMTAG_OBSOLETEVERSION
    1116:
      id: dir_indexes
      -orig-id: RPMTAG_DIRINDEXES
    1117:
      id: base_names
      -orig-id: RPMTAG_BASENAMES
    1118:
      id: dir_names
      -orig-id: RPMTAG_DIRNAMES
    1119:
      id: orig_dir_indexes # from lib/rpmtag.h
      -orig-id: RPMTAG_ORIGDIRINDEXES
    1120:
      id: orig_base_names # from lib/rpmtag.h
      -orig-id: RPMTAG_ORIGBASENAMES
    1121:
      id: orig_dir_names # from lib/rpmtag.h
      -orig-id: RPMTAG_ORIGDIRNAMES
    1122:
      id: opt_flags
      -orig-id: RPMTAG_OPTFLAGS
    1123:
      id: dist_url
      -orig-id: RPMTAG_DISTURL
    1124:
      id: payload_format
      -orig-id: RPMTAG_PAYLOADFORMAT
    1125:
      id: payload_compressor
      -orig-id: RPMTAG_PAYLOADCOMPRESSOR
    1126:
      id: payload_flags
      -orig-id: RPMTAG_PAYLOADFLAGS
    1127:
      id: install_color # from lib/rpmtag.h
      -orig-id: RPMTAG_INSTALLCOLOR
    1128:
      id: install_tid # from lib/rpmtag.h
      -orig-id: RPMTAG_INSTALLTID
    1129:
      id: remove_tid # from lib/rpmtag.h
      -orig-id: RPMTAG_REMOVETID
    1131:
      id: rhn_platform
      -orig-id: RPMTAG_RHNPLATFORM
    1132:
      id: platform
      -orig-id: RPMTAG_PLATFORM
    # below are all from lib/rpmtag.h
    1140:
      id: file_colors
      -orig-id: RPMTAG_FILECOLORS
    1141:
      id: file_class
      -orig-id: RPMTAG_FILECLASS
    1142:
      id: class_dict
      -orig-id: RPMTAG_CLASSDICT
    1143:
      id: file_depends_idx
      -orig-id: RPMTAG_FILEDEPENDSX
      doc: Index into `::depends_dict` denoting start of this file's dependencies.
    1144:
      id: file_depends_num
      -orig-id: RPMTAG_FILEDEPENDSN
      doc: Number of file dependencies in `::depends_dict`, starting from `::file_depends_idx`
    1145:
      id: depends_dict
      -orig-id: RPMTAG_DEPENDSDICT
    1146:
      id: source_pkgid
      -orig-id: RPMTAG_SOURCEPKGID
    1148:
      id: fs_contexts
      -orig-id: RPMTAG_FSCONTEXTS
    1149:
      id: re_contexts
      -orig-id: RPMTAG_RECONTEXTS
    1150:
      id: policies
      -orig-id: RPMTAG_POLICIES
    1151:
      id: pre_trans
      -orig-id: RPMTAG_PRETRANS
    1152:
      id: post_trans
      -orig-id: RPMTAG_POSTTRANS
    1153:
      id: pre_trans_prog
      -orig-id: RPMTAG_PRETRANSPROG
    1154:
      id: post_trans_prog
      -orig-id: RPMTAG_POSTTRANSPROG
    1155:
      id: dist_tag
      -orig-id: RPMTAG_DISTTAG
    1195:
      id: db_instance
      -orig-id: RPMTAG_DBINSTANCE
    1196:
      id: nvra
      -orig-id: RPMTAG_NVRA
    5000:
      id: file_names
      -orig-id: RPMTAG_FILENAMES
    5001:
      id: file_provide
      -orig-id: RPMTAG_FILEPROVIDE
    5002:
      id: file_require
      -orig-id: RPMTAG_FILEREQUIRE
    5005:
      id: trigger_conds
      -orig-id: RPMTAG_TRIGGERCONDS
    5006:
      id: trigger_type
      -orig-id: RPMTAG_TRIGGERTYPE
    5007:
      id: orig_file_names
      -orig-id: RPMTAG_ORIGFILENAMES
    5008:
      id: long_file_sizes
      -orig-id: RPMTAG_LONGFILESIZES
    5009:
      id: long_size
      -orig-id: RPMTAG_LONGSIZE
    5010:
      id: file_caps
      -orig-id: RPMTAG_FILECAPS
    5011:
      id: file_digest_algo
      -orig-id: RPMTAG_FILEDIGESTALGO
      doc: File digest algorithm
    5012:
      id: bug_url
      -orig-id: RPMTAG_BUGURL
    5013:
      id: evr
      -orig-id: RPMTAG_EVR
    5014:
      id: nvr
      -orig-id: RPMTAG_NVR
    5015:
      id: nevr
      -orig-id: RPMTAG_NEVR
    5016:
      id: nevra
      -orig-id: RPMTAG_NEVRA
    5017:
      id: header_color
      -orig-id: RPMTAG_HEADERCOLOR
    5018:
      id: verbose
      -orig-id: RPMTAG_VERBOSE
    5019:
      id: epoch_num
      -orig-id: RPMTAG_EPOCHNUM
    5020:
      id: pre_in_flags
      -orig-id: RPMTAG_PREINFLAGS
    5021:
      id: post_in_flags
      -orig-id: RPMTAG_POSTINFLAGS
    5022:
      id: pre_un_flags
      -orig-id: RPMTAG_PREUNFLAGS
    5023:
      id: post_un_flags
      -orig-id: RPMTAG_POSTUNFLAGS
    5024:
      id: pre_trans_flags
      -orig-id: RPMTAG_PRETRANSFLAGS
    5025:
      id: post_trans_flags
      -orig-id: RPMTAG_POSTTRANSFLAGS
    5026:
      id: verify_script_flags
      -orig-id: RPMTAG_VERIFYSCRIPTFLAGS
    5027:
      id: trigger_script_flags
      -orig-id: RPMTAG_TRIGGERSCRIPTFLAGS
    5030:
      id: policy_names
      -orig-id: RPMTAG_POLICYNAMES
    5031:
      id: policy_types
      -orig-id: RPMTAG_POLICYTYPES
    5032:
      id: policy_types_indexes
      -orig-id: RPMTAG_POLICYTYPESINDEXES
    5033:
      id: policy_flags
      -orig-id: RPMTAG_POLICYFLAGS
    5034:
      id: vcs
      -orig-id: RPMTAG_VCS
    5035:
      id: order_name
      -orig-id: RPMTAG_ORDERNAME
    5036:
      id: order_version
      -orig-id: RPMTAG_ORDERVERSION
    5037:
      id: order_flags
      -orig-id: RPMTAG_ORDERFLAGS
    5040:
      id: inst_file_names
      -orig-id: RPMTAG_INSTFILENAMES
    5041:
      id: require_nevrs
      -orig-id: RPMTAG_REQUIRENEVRS
    5042:
      id: provide_nevrs
      -orig-id: RPMTAG_PROVIDENEVRS
    5043:
      id: obsolete_nevrs
      -orig-id: RPMTAG_OBSOLETENEVRS
    5044:
      id: conflict_nevrs
      -orig-id: RPMTAG_CONFLICTNEVRS
    5045:
      id: file_nlinks
      -orig-id: RPMTAG_FILENLINKS
    5046:
      id: recommend_name
      -orig-id: RPMTAG_RECOMMENDNAME
    5047:
      id: recommend_version
      -orig-id: RPMTAG_RECOMMENDVERSION
    5048:
      id: recommend_flags
      -orig-id: RPMTAG_RECOMMENDFLAGS
    5049:
      id: suggest_name
      -orig-id: RPMTAG_SUGGESTNAME
    5050:
      id: suggest_version
      -orig-id: RPMTAG_SUGGESTVERSION
    5051:
      id: suggest_flags
      -orig-id: RPMTAG_SUGGESTFLAGS
    5052:
      id: supplement_name
      -orig-id: RPMTAG_SUPPLEMENTNAME
    5053:
      id: supplement_version
      -orig-id: RPMTAG_SUPPLEMENTVERSION
    5054:
      id: supplement_flags
      -orig-id: RPMTAG_SUPPLEMENTFLAGS
    5055:
      id: enhance_name
      -orig-id: RPMTAG_ENHANCENAME
    5056:
      id: enhance_version
      -orig-id: RPMTAG_ENHANCEVERSION
    5057:
      id: enhance_flags
      -orig-id: RPMTAG_ENHANCEFLAGS
    5058:
      id: recommend_nevrs
      -orig-id: RPMTAG_RECOMMENDNEVRS
    5059:
      id: suggest_nevrs
      -orig-id: RPMTAG_SUGGESTNEVRS
    5060:
      id: supplement_nevrs
      -orig-id: RPMTAG_SUPPLEMENTNEVRS
    5061:
      id: enhance_nevrs
      -orig-id: RPMTAG_ENHANCENEVRS
    5062:
      id: encoding
      -orig-id: RPMTAG_ENCODING
    5066:
      id: file_trigger_scripts
      -orig-id: RPMTAG_FILETRIGGERSCRIPTS
    5067:
      id: file_trigger_script_prog
      -orig-id: RPMTAG_FILETRIGGERSCRIPTPROG
    5068:
      id: file_trigger_script_flags
      -orig-id: RPMTAG_FILETRIGGERSCRIPTFLAGS
    5069:
      id: file_trigger_name
      -orig-id: RPMTAG_FILETRIGGERNAME
    5070:
      id: file_trigger_index
      -orig-id: RPMTAG_FILETRIGGERINDEX
    5071:
      id: file_trigger_version
      -orig-id: RPMTAG_FILETRIGGERVERSION
    5072:
      id: file_trigger_flags
      -orig-id: RPMTAG_FILETRIGGERFLAGS
    5076:
      id: trans_file_trigger_scripts
      -orig-id: RPMTAG_TRANSFILETRIGGERSCRIPTS
    5077:
      id: trans_file_trigger_script_prog
      -orig-id: RPMTAG_TRANSFILETRIGGERSCRIPTPROG
    5078:
      id: trans_file_trigger_script_flags
      -orig-id: RPMTAG_TRANSFILETRIGGERSCRIPTFLAGS
    5079:
      id: trans_file_trigger_name
      -orig-id: RPMTAG_TRANSFILETRIGGERNAME
    5080:
      id: trans_file_trigger_index
      -orig-id: RPMTAG_TRANSFILETRIGGERINDEX
    5081:
      id: trans_file_trigger_version
      -orig-id: RPMTAG_TRANSFILETRIGGERVERSION
    5082:
      id: trans_file_trigger_flags
      -orig-id: RPMTAG_TRANSFILETRIGGERFLAGS
    5084:
      id: file_trigger_priorities
      -orig-id: RPMTAG_FILETRIGGERPRIORITIES
    5085:
      id: trans_file_trigger_priorities
      -orig-id: RPMTAG_TRANSFILETRIGGERPRIORITIES
    5086:
      id: file_trigger_conds
      -orig-id: RPMTAG_FILETRIGGERCONDS
    5087:
      id: file_trigger_type
      -orig-id: RPMTAG_FILETRIGGERTYPE
    5088:
      id: trans_file_trigger_conds
      -orig-id: RPMTAG_TRANSFILETRIGGERCONDS
    5089:
      id: trans_file_trigger_type
      -orig-id: RPMTAG_TRANSFILETRIGGERTYPE
    5090:
      id: file_signatures
      -orig-id: RPMTAG_FILESIGNATURES
    5091:
      id: file_signature_length
      -orig-id: RPMTAG_FILESIGNATURELENGTH
    5092:
      id: payload_digest
      -orig-id: RPMTAG_PAYLOADDIGEST
    5093:
      id: payload_digest_algo
      -orig-id: RPMTAG_PAYLOADDIGESTALGO
    5096:
      id: modularity_label
      -orig-id: RPMTAG_MODULARITYLABEL
    5097:
      id: payload_digest_alt
      -orig-id: RPMTAG_PAYLOADDIGESTALT
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
    9: i18n_string # NUL terminated strings
