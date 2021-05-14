meta:
  id: phar_without_stub
  title: PHP phar archive (without stub)
  application: PHP
  file-extension: phar
  xref:
    wikidata: Q1269709
  license: CC0-1.0
  ks-version: 0.9
  imports:
    - /serialization/php_serialized_value
  endian: le
doc: |
  A phar (PHP archive) file. The phar format is a custom archive format
  from the PHP ecosystem that is used to package a complete PHP library
  or application into a single self-contained archive.
  All phar archives start with an executable PHP stub, which can be used to
  allow executing or including phar files as if they were regular PHP scripts.
  PHP 5.3 and later include the phar extension, which adds native support for
  reading and manipulating phar files.

  The phar format was originally developed as part of the PEAR library
  PHP_Archive, first released in 2005. Later, a native PHP extension
  named "phar" was developed, which was first released on PECL in 2007,
  and is included with PHP 5.3 and later. The phar extension has effectively
  superseded the PHP_Archive library, which has not been updated since 2010.
  The phar extension is also no longer released independently on PECL;
  it is now developed and released as part of PHP itself.

  Because of current limitations in Kaitai Struct
  (seekaitai-io/kaitai_struct#158 and kaitai-io/kaitai_struct#538),
  the executable PHP stub that precedes the rest of the archive is not handled
  by this spec. Before parsing a phar using this spec, the stub must be
  removed manually.

  A phar's stub is terminated by the special token `__HALT_COMPILER();`
  (which may be followed by at most one space, the PHP tag end `?>`,
  and an optional line terminator). The stub termination sequence is
  immediately followed by the remaining parts of the phar format,
  as described in this spec.

  The phar stub usually contains code that loads the phar and runs
  a contained PHP file, but this is not required. A minimal valid phar stub
  is `<?php __HALT_COMPILER();` - such a stub makes it impossible to execute
  the phar directly, but still allows loading or manipulating it using the
  phar extension.

  Note: The phar format does not specify any encoding for text fields
  (stub, alias name, and all file names), so these fields may contain arbitrary
  binary data. The actual text encoding used in a specific phar file usually
  depends on the application that created the phar, and on the
  standard encoding of the system on which the phar was created.
doc-ref:
  - 'https://www.php.net/manual/en/phar.fileformat.php'
  - 'https://github.com/php/php-src/tree/master/ext/phar'
  - 'https://svn.php.net/viewvc/pecl/phar/'
  - 'https://svn.php.net/viewvc/pear/packages/PHP_Archive/'
seq:
  - id: manifest
    type: manifest
    doc: |
      The archive's manifest, containing general metadata about the archive
      and its files.
  - id: files
    size: manifest.file_entries[_index].len_data_compressed
    repeat: expr
    repeat-expr: manifest.num_files
    doc: |
      The contents of each file in the archive (possibly compressed,
      as indicated by the file's flags in the manifest). The files are stored
      in the same order as they appear in the manifest.
  - id: signature
    type: signature
    size-eos: true
    if: manifest.flags.has_signature
    doc: |
      The archive's signature - a digest of all archive data before
      the signature itself.

      Note: Almost all of the available "signature" types are actually hashes,
      not signatures, and cannot be used to verify that the archive has not
      been tampered with. Only the OpenSSL signature type is a true
      cryptographic signature.
enums:
  signature_type:
    0x1:
      id: md5
      -orig-id: PHAR_SIG_MD5
      doc: Indicates an MD5 hash.
    0x2:
      id: sha1
      -orig-id: PHAR_SIG_SHA1
      doc: Indicates a SHA-1 hash.
    0x4:
      id: sha256
      -orig-id: PHAR_SIG_SHA256
      doc: |
        Indicates a SHA-256 hash. Available since API version 1.1.0,
        PHP_Archive 0.12.0 and phar extension 1.1.0.
    0x8:
      id: sha512
      -orig-id: PHAR_SIG_SHA512
      doc: |
        Indicates a SHA-512 hash. Available since API version 1.1.0,
        PHP_Archive 0.12.0 and phar extension 1.1.0.
    0x10:
      id: openssl
      -orig-id: PHAR_SIG_OPENSSL
      doc: |
        Indicates an OpenSSL signature. Available since API version 1.1.1,
        PHP_Archive 0.12.0 (even though it claims to only support
        API version 1.1.0) and phar extension 1.3.0. This type is not
        documented in the phar extension's documentation of the phar format.

        Note: In older versions of the phar extension, this value was used
        for an undocumented and unimplemented "PGP" signature type
        (`PHAR_SIG_PGP`).
types:
  serialized_value:
    seq:
      - id: raw
        size-eos: true
        doc: The serialized value, as a raw byte array.
    instances:
      parsed:
        pos: 0
        type: php_serialized_value
        doc: The serialized value, parsed as a structure.
  file_flags:
    seq:
      - id: value
        type: u4
        doc: The unparsed flag bits.
    instances:
      permissions:
        value: value & 0x1ff
        -orig-id: PHAR_ENT_PERM_MASK
        doc: The file's permission bits.
      zlib_compressed:
        value: (value & 0x1000) != 0
        -orig-id: PHAR_ENT_COMPRESSED_GZ
        doc: Whether this file's data is stored using zlib compression.
      bzip2_compressed:
        value: (value & 0x2000) != 0
        -orig-id: PHAR_ENT_COMPRESSED_BZ2
        doc: Whether this file's data is stored using bzip2 compression.
  file_entry:
    seq:
      - id: len_filename
        type: u4
        doc: The length of the file name, in bytes.
      - id: filename
        size: len_filename
        doc: |
          The name of this file. If the name ends with a slash, this entry
          represents a directory, otherwise a regular file. Directory entries
          are supported since phar API version 1.1.1.
          (Explicit directory entries are only needed for empty directories.
          Non-empty directories are implied by the files located inside them.)
      - id: len_data_uncompressed
        type: u4
        doc: The length of the file's data when uncompressed, in bytes.
      - id: timestamp
        type: u4
        doc: |
          The time at which the file was added or last updated, as a
          Unix timestamp.
      - id: len_data_compressed
        type: u4
        doc: The length of the file's data when compressed, in bytes.
      - id: crc32
        type: u4
        doc: The CRC32 checksum of the file's uncompressed data.
      - id: flags
        type: file_flags
        doc: Flags for this file.
      - id: len_metadata
        type: u4
        doc: The length of the metadata, in bytes, or 0 if there is none.
      - id: metadata
        size: len_metadata
        type: serialized_value
        if: len_metadata != 0
        doc: |
          Metadata for this file, in the format used by PHP's
          `serialize` function. The meaning of the serialized data is not
          specified further, it may be used to store arbitrary custom data
          about the file.
  api_version:
    meta:
      endian: be
    doc: |
      A phar API version number. This version number is meant to indicate
      which features are used in a specific phar, so that tools reading
      the phar can easily check that they support all necessary features.

      The following API versions exist so far:

      * 0.5, 0.6, 0.7, 0.7.1: The first official API versions. At this point,
        the phar format was only used by the PHP_Archive library, and the
        API version numbers were identical to the PHP_Archive versions that
        supported them. Development of the native phar extension started around
        API version 0.7. These API versions could only be queried using the
        `PHP_Archive::APIversion()` method, but were not stored physically
        in archives. These API versions are not supported by this spec.
      * 0.8.0: Used by PHP_Archive 0.8.0 (released 2006-07-18) and
        later development versions of the phar extension. This is the first
        version number to be physically stored in archives. This API version
        is not supported by this spec.
      * 0.9.0: Used by later development/early beta versions of the
        phar extension. Also temporarily used by PHP_Archive 0.9.0
        (released 2006-12-15), but reverted back to API version 0.8.0 in
        PHP_Archive 0.9.1 (released 2007-01-05).
      * 1.0.0: Supported since PHP_Archive 0.10.0 (released 2007-05-29)
        and phar extension 1.0.0 (released 2007-03-28). This is the first
        stable, forwards-compatible and documented version of the format.
      * 1.1.0: Supported since PHP_Archive 0.12.0 (released 2015-07-06)
        and phar extension 1.1.0 (released 2007-04-12). Adds SHA-256 and
        SHA-512 signature types.
      * 1.1.1: Supported since phar extension 2.0.0 (released 2009-07-29 and
        included with PHP 5.3 and later). (PHP_Archive 0.12.0 also supports
        all features from API verison 1.1.1, but it reports API version 1.1.0.)
        Adds the OpenSSL signature type and support for storing
        empty directories.
    seq:
      - id: release
        type: b4
      - id: major
        type: b4
      - id: minor
        type: b4
      - id: unused
        type: b4
  global_flags:
    seq:
      - id: value
        type: u4
        doc: The unparsed flag bits.
    instances:
      any_zlib_compressed:
        value: (value & 0x1000) != 0
        -orig-id: PHAR_HDR_COMPRESSED_GZ
        doc: |
          Whether any of the files in this phar are stored using
          zlib compression.
      any_bzip2_compressed:
        value: (value & 0x2000) != 0
        -orig-id: PHAR_HDR_COMPRESSED_BZ2
        doc: |
          Whether any of the files in this phar are stored using
          bzip2 compression.
      has_signature:
        value: (value & 0x10000) != 0
        -orig-id: PHAR_HDR_SIGNATURE
        doc: Whether this phar contains a signature.
  manifest:
    seq:
      - id: len_manifest
        type: u4
        doc: |
          The length of the manifest, in bytes.

          Note: The phar extension does not allow reading manifests
          larger than 100 MiB.
      - id: num_files
        type: u4
        doc: The number of files in this phar.
      - id: api_version
        type: api_version
        doc: The API version used by this phar manifest.
      - id: flags
        type: global_flags
        doc: Global flags for this phar.
      - id: len_alias
        type: u4
        doc: The length of the alias, in bytes.
      - id: alias
        size: len_alias
        doc: |
          The phar's alias, i. e. the name under which it is loaded into PHP.
      - id: len_metadata
        type: u4
        doc: The size of the metadata, in bytes, or 0 if there is none.
      - id: metadata
        size: len_metadata
        type: serialized_value
        if: len_metadata != 0
        doc: |
          Metadata for this phar, in the format used by PHP's
          `serialize` function. The meaning of the serialized data is not
          specified further, it may be used to store arbitrary custom data
          about the archive.
      - id: file_entries
        type: file_entry
        repeat: expr
        repeat-expr: num_files
        doc: Manifest entries for the files contained in this phar.
  signature:
    seq:
      - id: data
        size: _io.size - _io.pos - 8
        doc: |
          The signature data. The size and contents depend on the
          signature type.
      - id: type
        type: u4
        enum: signature_type
        doc: The signature type.
      - id: magic
        contents: "GBMB"
