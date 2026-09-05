meta:
  id: install_shield_3_z
  title: InstallShield 3 Z archive
  application: InstallShield 3
  # Not to be confused with the Unix compress or pack compression formats,
  # which use the uppercase Z and lowercase z extensions respectively.
  file-extension: z
  xref:
    justsolve: InstallShield_Z
  tags:
    - archive
    - windows
  license: MIT
  ks-version: 0.9
  imports:
    - /common/dos_datetime_backwards
  endian: le
  bit-endian: le
doc: |
  Archive format used by InstallShield 3 installers.
  File data can optionally be compressed using the PKWARE DCL Implode algorithm.
  This is not to be confused with the old ZIP Implode compression algorithm of the same name.
doc-ref:
  - https://github.com/OpenRA/OpenRA/blob/fe146cb77a25091ed342e38104292ac3cb19019b/OpenRA.Mods.Common/FileSystem/InstallShieldPackage.cs
  - https://github.com/OmniBlade/isextract/blob/5adb0af87fb0aaad0b436db0b7e7356947af3ee2/src/isextract.cpp
  - https://github.com/wfr/unshieldv3/blob/0037ff581a4d862757ccc2c584aefdc0fe58a38d/installshieldarchivev3.cpp
  - https://github.com/adrium/unshieldv3/blob/9f47d1c501abb778eb40beb7fdbb24ae556b7c46/installshieldarchivev3.cpp
  - https://github.com/lephilousophe/idecomp/blob/354961c0cfe86632a39e4fea01e0ca521ffac3e0/idecomp.py
  - https://github.com/putara/isdecomp
  - https://github.com/agrif/unshield
  - http://kannegieser.net/veit/quelle/stix_src.arj # STIX.PAS
seq:
  - id: magic
    contents: [0x13, 0x5d, 0x65, 0x8c]
  - id: len_header
    type: u1
    valid: sizeof<header>
    doc: |
      Byte length of the header data
      (not including the magic number and length byte).
  - id: header
    type: header
instances:
  toc_directories:
    pos: header.ofs_toc_directories
    type: toc_directory
    repeat: expr
    repeat-expr: header.num_directories
    doc: |
      Directory table of contents,
      listing all directories in the archive that contain files.

      Intermediate directories,
      i. e. directories that contain only other directories and no files,
      are not stored explicitly as directory entries -
      they are implied by the directory entries for their subdirectories.

      The format technically allows directory entries that don't contain any files or directories,
      but in practice this isn't used.
  toc_files:
    pos: header.ofs_toc_files
    type: toc_file
    repeat: expr
    repeat-expr: header.num_files
    doc: |
      File table of contents,
      listing all files in the archive.

      The files are usually sorted ascending by the index of their parent directory.
      That is,
      the file TOC should first list all files in directory 0,
      then all files in directory 1,
      then those in directory 2,
      etc.
      However, this is not required -
      some archives have files ordered differently
      or not all files from each directory grouped together.
types:
  header:
    seq:
      - id: unknown_1
        contents: [0x01, 0x02, 0x00, 0x00]
      - id: has_password
        type: u1
        valid: 0 # TODO
        doc: |
          Name taken from idecomp.py,
          which parses this field,
          but doesn't handle it any further.

          For files without a password (the usual case),
          this field's value is 0.
          It's not clear which other values are actually used (if any)
          and what their meanings are.
      - id: flags
        type: flags
      - id: num_files
        type: u2
        doc: Number of files in this archive file.
      - id: modified
        type: dos_datetime_backwards
        doc: Modification date/time of the archive file.
      - id: len_archive
        type: u4
        doc: Byte length of the entire archive file.
      - id: total_uncompressed_size
        type: u4
        doc: |
          Sum of the uncompressed sizes of all files in this archive file.
          Sometimes contains a nonsense value even for otherwise valid files.
      - id: ofs_data
        type: u4
        valid: 0xff
        doc: |
          Absolute byte offset of the file data area.

          idecomp.py calls this field `taken` and documents it as:

          > Taken is size of metadatas and incomplete file part

          Most likely "incomplete file part" means "continued split file data"
          (see end_integral_data).

          This field is not properly tested yet.
          For single-part archives,
          its value is always 0xff.
      - id: num_parts
        type: u1
        valid:
          expr: |
            is_extended ? _ > 0 : _ == 0
        doc: |
          Total number of parts that this archive is split into.
          Only used in extended format -
          otherwise this field is 0
          and the archive only has a single part.
      - id: part
        type: u1
        valid:
          expr: |
            is_extended ? _ > 0 : _ == 0
        doc: |
          The sequence number of this archive part (1-based).
          Only used in extended format -
          otherwise this field is 0
          and this archive file is the first and only part of the archive.
      - id: checksum
        type: u1
        valid:
          expr: is_extended or _ == 0
        doc: |
          A simple checksum based on the sum of the compressed sizes of all files in this archive part.
          Only used in extended format -
          otherwise this field is 0
          and no checksum is stored or verified.

          idecomp.py calls this field `check_byte` and documents it as:

          > Check byte is total_compacted_size % 253

          But at least for some files it needs to be modulo 251, not 253.
          TODO: Are modulo 253 checksums actually used,
          or is that just an error in idecomp.py's comments?
      - id: end_integral_data
        type: u4
        valid: 0xff
        doc: |
          Name taken from idecomp.py,
          which parses this field,
          but doesn't use it.

          It's not clear what the meaning and purpose of this field is.
          Based on the name,
          it should be the absolute byte offset where "continued split file data"
          (see start_integral_data) in this archive part starts.
          In that case its value should always be 0xff.

          Seems to be always 0xff for single-part archives.
      - id: start_integral_data
        type: u4
        valid: 0
        doc: |
          Name taken from idecomp.py.

          If this archive file is a split archive part
          and the archive contains a file split over multiple archive parts
          and that file's data ends in this archive part,
          then this is the absolute byte offset at which the split file data ends.

          Seems to be always 0 for single-part archives.
      - id: ofs_toc_directories
        type: u4
        doc: Absolute byte offset of the directory table of contents.
      - id: len_toc_directories
        type: u4
        doc: Byte length of the directory table of contents.
      - id: num_directories
        type: u2
        doc: Number of directories in the archive.
      - id: ofs_toc_files
        type: u4
        valid: ofs_toc_directories + len_toc_directories
        doc: Absolute byte offset of the file table of contents.
      - id: len_toc_files
        type: u4
        valid: len_archive - ofs_toc_files
        doc: Byte length of the file table of contents.
      - id: password # TODO
        type: u4
        valid:
          expr: not is_extended or _ == len_archive
        doc: |
          Name taken from idecomp.py.
          It's unclear what the exact format/meaning of this field is.
          Most likely it's a hash of the archive password,
          or a byte offset to where in the file the password information is stored.

          For passwordless archives,
          this is 0 if in non-extended format
          or equal to `len_archive` if in extended format.
    instances:
      is_extended:
        value: flags.is_split or flags.is_split_contiguous
        doc: |
          Whether any of the flags for split archive format are set,
          indicating that additional fields in the archive header and file TOC are filled out.
          As explained in the documentation for is_split,
          this does *not* mean that the archive actually has multiple parts!
    types:
      flags:
        seq:
          - id: is_split
            type: b1
            doc: |
              Whether this archive file is in split (multi-part) format.
              If this flag is set,
              multiple additional fields in the archive header and TOC entries are enabled.
              Most (but not all) of these extended fields are related to multi-part archives.
              However,
              this flag does *not* mean that the archive actually has multiple parts!
              There are archives that only consist of a single part,
              but still have the extended fields enabled.
          - id: is_split_contiguous
            type: b1
            doc: |
              Whether this archive file is in "contiguous" split (multi-part) format.

              Untested.
              idecomp.py documents this flag as:

              > split file contiguously (a file is not split across archive parts)

              This probably means that every file inside this split archive part
              has all of its data stored completely inside this part,
              i. e. no files have any section of their data stored in other archive parts.
              Presumably other archive parts can contain other additional files.

              It's not really clear if this flag can be set on its own
              or if it should only be set together with is_split.
              Most likely it's used on its own,
              because when idecomp.py checks if an archive file is a split archive part,
              it checks if either of the two flags is set.
          - id: reserved
            type: b14
            valid: 0
            doc: Archive flags with no known use.
  toc_directory:
    seq:
      - id: num_files
        type: u2
        doc: Number of files in this directory.
      - id: len_entry
        type: u2
        doc: Total byte size of this directory entry.
      - id: len_path
        type: u2
        valid:
          # len_entry - (size of all fields except path)
          eq: |
            len_entry - (
              num_files._sizeof
              + len_entry._sizeof
              + len_path._sizeof
              + path_terminator._sizeof
              + reserved._sizeof
            )
        doc: Byte length of the directory path.
      - id: path
        size: len_path
        doc: |
          Path name of the directory,
          using backslashes as the name separator
          (DOS/Windows-style).
          Should be a relative path
          (i. e. no leading backslash or drive letter)
          and have no trailing backslashes.
          An empty path stands for the root directory of the archive.
      - id: path_terminator
        contents: [0x00]
        doc: Zero terminator for the path field.
      - id: reserved
        contents: [0x00, 0x00, 0x00, 0x00]
        doc: |
          Unused according to idecomp.py.
          Seems to be always 0.
  version:
    doc: |
      File version number,
      in the same format as used in Windows executable VERSIONINFO resources.

      The version number parts are ordered major.minor.build.private -
      the strange order of the fields is because Windows normally treats this version format
      as two little-endian 32-bit integers:
      the first one with major in the high 16 bits and minor in the low 16 bits,
      and the second one with build in the high 16 bits and private in the low 16 bits.
    doc-ref: https://docs.microsoft.com/en-us/windows/win32/menurc/versioninfo-resource
    -webide-representation: '{major}.{minor}.{build}.{private}'
    seq:
      - id: minor
        type: u2
      - id: major
        type: u2
      - id: private
        type: u2
      - id: build
        type: u2
  toc_file:
    seq:
      - id: end_part
        type: u1
        valid:
          expr: |
            _root.header.is_extended
            ? (_ > 0 and _ <= _root.header.num_parts)
            : _ == 0
        doc: |
          Number of the archive part in which the last part of this file's data is stored.
          Can be the same as `start_part` if this file's data is not split over multiple parts.
          Only used in extended format -
          otherwise this field is 0
          and the file's data is not split.
      - id: directory_index
        type: u2
        doc: |
          Index into the directory table of contents,
          indicating in which directory this file is located.
      - id: len_data_uncompressed
        type: u4
        doc: |
          Byte length of the data after decompression.
          If the data is not compressed,
          this is equal to len_data_compressed.
      - id: len_data_compressed
        type: u4
        doc: |
          Byte length of the data as stored in the archive,
          i. e. possibly compressed.
      - id: ofs_data
        type: u4
        doc: Absolute byte offset of the file data.
      - id: modified
        type: dos_datetime_backwards
        doc: Modification date/time of the file.
      - id: attributes
        type: u4
        doc: |
          DOS file attributes of the file.

          Only bits 0 through 5 are actually used by DOS/Windows -
          all other bits should be zero.
          Of these,
          bits 3 and 4 mark volume labels and directories (respectively),
          so they should never be set on files in an archive.

          For some reason,
          this field apparently always has bit 7 set if no other attributes are set.
          This seems to have no meaning and can probably be ignored.
      - id: len_entry
        type: u2
        doc: Total byte size of this file entry.
      - id: flags
        type: flags
      - id: reserved_1
        contents: [0x00]
        doc: |
          Unused according to idecomp.py.
          Seems to be always 0.
      - id: start_part
        type: u1
        valid:
          expr: |
            flags.is_split
            ? (_ > 0 and _ < end_part)
            : _ == end_part
        doc: |
          Number of the split archive part in which the first part of this file's data is stored.
          Only used in extended format -
          otherwise this field is 0
          and the file's data is not split.
      - id: len_name
        type: u1
        valid:
          # len_entry - (size of all fields except name)
          eq: |
            len_entry - (
              end_part._sizeof
              + directory_index._sizeof
              + len_data_uncompressed._sizeof
              + len_data_compressed._sizeof
              + ofs_data._sizeof
              + modified._sizeof
              + attributes._sizeof
              + len_entry._sizeof
              + flags._sizeof
              + reserved_1._sizeof
              + start_part._sizeof
              + len_name._sizeof
              + name_terminator._sizeof
              + version._sizeof
              + reserved_2._sizeof
            )
        doc: Byte size of the file name.
      - id: name
        size: len_name
        doc: |
          Name of the file.
          Does not include a directory path -
          use directory_index to find out which directory the file is located in.
      - id: name_terminator
        contents: [0x00]
        doc: Zero terminator for the name field.
      - id: version
        type: version
        doc: |
          Version number of the file.
          Usually only used for executable files,
          in which case it should match the version information stored in the executable.

          For files with no version number,
          this field is set to version 0.0.0.0 (all zero bytes).
          The `has_version` flag does *not* reliably indicate if this field is valid or not -
          even with the flag set to false this field often contains a non-zero version,
          so it's better to check this field directly instead of the flag.
      - id: reserved_2
        contents: [0x00, 0x00, 0x00, 0x00]
        doc: |
          Unused according to idecomp.py.
          Seems to be always 0.
    instances:
      directory:
        value: _root.toc_directories[directory_index]
        doc: The directory in which this file is located.
      data_compressed:
        io: _root._io
        pos: ofs_data
        size: len_data_compressed
        doc: The possibly compressed data for this file.
    types:
      flags:
        seq:
          - id: reserved_1
            type: b4
            valid: 0
          - id: is_uncompressed
            type: b1
            doc: |
              Whether this file's data is stored uncompressed.
              If false,
              the data is compressed using the PKWARE DCL Implode compression algorithm.
          - id: internal_flag
            type: b1
            valid: false
            doc: |
              According to idecomp.py,
              this flag is used internally by InstallShield's icomp
              and should never be true in archive files.
          - id: has_version
            type: b1
            doc: |
              May be true if this file has a version number stored in the version field.
              This flag isn't always set reliably
              (see also the comments in idecomp.py) -
              it's often false even for files which have a non-zero version number stored.
          - id: reserved_2
            type: b1
            valid: false
          - id: is_split
            type: b1
            valid:
              expr: _root.header.is_extended or not _
            doc: |
              Whether this file is split across multiple archive parts.
              Only used in extended format -
              otherwise this field is 0
              and the file's data is not split.
          - id: reserved_3
            type: b7
            valid: 0
