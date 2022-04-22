meta:
  id: zip
  title: ZIP archive file
  file-extension: zip
  xref:
    forensicswiki: ZIP
    iso: 21320-1
    justsolve: ZIP
    loc:
      - fdd000354
      - fdd000355
      - fdd000362
      - fdd000361
    pronom: x-fmt/263
    wikidata: Q136218
  license: CC0-1.0
  ks-version: 0.9
  imports:
    - /common/dos_datetime
  endian: le
  bit-endian: le
doc: |
  ZIP is a popular archive file format, introduced in 1989 by Phil Katz
  and originally implemented in PKZIP utility by PKWARE.

  Thanks to solid support of it in most desktop environments and
  operating systems, and algorithms / specs availability in public
  domain, it quickly became tool of choice for implementing file
  containers.

  For example, Java .jar files, OpenDocument, Office Open XML, EPUB files
  are actually ZIP archives.
doc-ref:
  - https://pkware.cachefly.net/webdocs/casestudies/APPNOTE.TXT
  - https://users.cs.jmu.edu/buchhofp/forensics/formats/pkzip.html
seq:
  - id: sections
    type: pk_section
    repeat: until
    repeat-until: _.section_type == section_types::end_of_central_dir
types:
  empty: {}
  pk_section:
    seq:
      - id: magic
        contents: 'PK'
      - id: section_type
        type: u2
        enum: section_types
      - id: body
        type:
          switch-on: section_type
          cases:
            section_types::central_dir_entry: central_dir_entry
            section_types::local_file: local_file
            section_types::end_of_central_dir: end_of_central_dir
            section_types::data_descriptor: data_descriptor
            section_types::archive_extra_data: archive_extra_data
            section_types::digital_signature: digital_signature
            section_types::zip64_end_of_central_dir: zip64_end_of_central_dir
            section_types::zip64_end_of_central_dir_locator: zip64_end_of_central_dir_locator
  archive_extra_data:
    seq:
      - id: len_extra_field
        type: u4
      - id: data
        size: len_extra_field
  data_descriptor:
    seq:
      - id: crc32
        type: u4
      - id: len_body_compressed
        type: u4
      - id: len_body_uncompressed
        type: u4
  digital_signature:
    seq:
      - id: len_signature
        type: u2
      - id: signature
        size: len_signature
  local_file:
    seq:
      - id: header
        type: local_file_header
      - id: body
        size: header.len_body_compressed
  local_file_header:
    seq:
      - id: version
        type: u2
      - id: flags
        type: gp_flags
        size: 2
      - id: compression_method
        type: u2
        enum: compression
      - id: file_mod_time
        size: 4
        type: dos_datetime
      - id: crc32
        type: u4
      - id: len_body_compressed
        type: u4
      - id: len_body_uncompressed
        type: u4
      - id: len_file_name
        type: u2
      - id: len_extra
        type: u2
      - id: file_name
        type: str
        size: len_file_name
        encoding: UTF-8
      - id: extra
        size: len_extra
        type:
          switch-on: has_padding
          cases:
            false: extras(section_types::local_file)
            true: empty
    instances:
      has_padding:
        value: len_extra < 4 and len_extra != 0
    types:
      gp_flags:
        -orig-id: general purpose bit flag
        doc-ref:
          - https://pkware.cachefly.net/webdocs/casestudies/APPNOTE.TXT - 4.4.4
          - https://users.cs.jmu.edu/buchhofp/forensics/formats/pkzip.html Local file headers
        seq:
          - id: file_encrypted
            type: b1
          - id: comp_options_raw
            type: b2
            doc: internal; access derived value instances instead
          - id: has_data_descriptor
            type: b1
          - id: reserved_1
            type: b1
          - id: comp_patched_data
            type: b1
          - id: strong_encrypt
            type: b1
          - id: reserved_2
            type: b4
          - id: lang_encoding
            type: b1
          - id: reserved_3
            type: b1
          - id: mask_header_values
            type: b1
          - id: reserved_4
            type: b2
        instances:
          deflated_mode:
            value: comp_options_raw
            enum: deflate_mode
            if: |
              _parent.compression_method == compression::deflated
              or _parent.compression_method == compression::enhanced_deflated
          imploded_dict_byte_size:
            value: '((comp_options_raw & 0b01) != 0 ? 8 : 4) * 1024'
            if: '_parent.compression_method == compression::imploded'
            doc: 8KiB or 4KiB in bytes
          imploded_num_sf_trees:
            value: '(comp_options_raw & 0b10) != 0 ? 3 : 2'
            if: '_parent.compression_method == compression::imploded'
          lzma_has_eos_marker:
            value: '(comp_options_raw & 0b01) != 0'
            if: '_parent.compression_method == compression::lzma'
        enums:
          deflate_mode:
            0: normal
            1: maximum
            2: fast
            3: super_fast
  central_dir_entry:
    doc-ref: https://pkware.cachefly.net/webdocs/casestudies/APPNOTE.TXT - 4.3.12
    seq:
      - id: version_made_by
        type: u2
      - id: version_needed_to_extract
        type: u2
      - id: flags
        type: u2
      - id: compression_method
        type: u2
        enum: compression
      - id: file_mod_time
        size: 4
        type: dos_datetime
      - id: crc32
        type: u4
      - id: len_body_compressed
        type: u4
      - id: len_body_uncompressed
        type: u4
      - id: len_file_name
        type: u2
      - id: len_extra
        type: u2
      - id: len_comment
        type: u2
      - id: disk_number_start
        type: u2
      - id: int_file_attr
        type: u2
      - id: ext_file_attr
        type: u4
      - id: ofs_local_header
        type: s4
      - id: file_name
        type: str
        size: len_file_name
        encoding: UTF-8
      - id: extra
        size: len_extra
        type: extras(section_types::central_dir_entry)
      - id: comment
        size: len_comment
    instances:
      local_header:
        pos: ofs_local_header
        type: pk_section
  # https://pkware.cachefly.net/webdocs/casestudies/APPNOTE.TXT - 4.3.16
  end_of_central_dir:
    seq:
      - id: disk_of_end_of_central_dir
        type: u2
      - id: disk_of_central_dir
        type: u2
      - id: num_central_dir_entries_on_disk
        type: u2
      - id: num_central_dir_entries_total
        type: u2
      - id: len_central_dir
        type: u4
      - id: ofs_central_dir
        type: u4
      - id: len_comment
        type: u2
      - id: comment
        size: len_comment
  zip64_end_of_central_dir:
    seq:
      - id: len_record
        type: u8
        doc: size of zip64 end of central directory record
      - id: zip64_end_of_central_dir_body
        type: zip64_end_of_central_dir_body
        size: len_record
    types:
      zip64_end_of_central_dir_body:
        seq:
          - id: version_made_by
            type: u2
          - id: version_needed_to_extract
            type: u2
          - id: this_disk
            type: u4
            doc: number of this disk
          - id: disk_of_start_of_central_dir
            type: u4
            doc: number of the disk with the start of the central directory
          - id: num_central_dir_entries_on_disk
            type: u8
            doc: total number of entries in the central directory on this disk
          - id: num_central_dir_entries_total
            type: u8
            doc: total number of entries in the central directory
          - id: len_central_dir
            type: u8
            doc: size of the central directory
          - id: ofs_central_dir
            type: u8
            doc: |
              offset of start of central directory with respect
              to the starting disk number
          - id: extensible_data
            size-eos: true
            doc: zip64 extensible data sector
  zip64_end_of_central_dir_locator:
    seq:
      - id: disk_of_start_of_central_dir
        type: u4
        doc: |
          number of the disk with the start of
          the zip64 end of central directory
      - id: ofs_zip64_end_of_central_dir
        type: u8
        doc: relative offset of the zip64 end of central directory record
      - id: total_number_of_disks
        type: u4
  extras:
    params:
      - id: type
        type: u4
        enum: section_types
    seq:
      - id: entries
        type: extra_field
        repeat: eos
  extra_field:
    seq:
      - id: code
        type: u2
        enum: extra_codes
      - id: len_body
        type: u2
      - id: body
        size: len_body
        type:
          switch-on: code
          cases:
            'extra_codes::ntfs': ntfs
            'extra_codes::extended_timestamp': extended_timestamp
            'extra_codes::infozip_unicode_path': infozip_unicode_path
            'extra_codes::infozip_unix_var_size': infozip_unix_var_size
            'extra_codes::aex_encryption': aex_encryption
            'extra_codes::xceed_unicode': xceed_unicode
            'extra_codes::alzip_code_page': alzip_code_page
            #'extra_codes::zip64': zip64
    types:
      aex_encryption:
        doc-ref: http://www.winzip.com/aes_info.htm
        seq:
          - id: version_number
            type: u2
          - id: vendor_id
            size: 2
          - id: encryption_strength
            type: u1
            enum: encryption
          - id: compression_method
            type: u2
            enum: compression
        enums:
          encryption:
            1: bit_128
            2: bit_192
            3: bit_256
      zip64:
        seq:
          - id: len_original
            type: u8
            doc: Original uncompressed file size
          - id: len_compressed
            type: u8
            doc: Size of compressed data
          - id: ofs_relative_header
            type: u8
            doc: Offset of local header record
          - id: disk_start_number
            type: u4
            doc: Number of the disk on which this file starts
      ntfs:
        doc-ref: 'https://github.com/LuaDist/zip/blob/b710806/proginfo/extrafld.txt#L191'
        seq:
          - id: reserved
            type: u4
          - id: attributes
            type: attribute
            repeat: eos
        types:
          attribute:
            seq:
              - id: tag
                type: u2
              - id: len_body
                type: u2
              - id: body
                size: len_body
                type:
                  switch-on: tag
                  cases:
                    1: attribute_1
          attribute_1:
            seq:
              - id: last_mod_time
                type: u8
              - id: last_access_time
                type: u8
              - id: creation_time
                type: u8
      extended_timestamp:
        doc-ref: 'https://github.com/LuaDist/zip/blob/b710806/proginfo/extrafld.txt#L817'
        seq:
          - id: flags
            size: 1
            type: info_flags
          - id: mod_time
            type: u4
            if: flags.has_mod_time
            doc: Unix timestamp
          - id: access_time
            type: u4
            if: flags.has_access_time and _parent._parent.type == section_types::local_file
            doc: Unix timestamp
          - id: create_time
            type: u4
            if: flags.has_create_time and _parent._parent.type == section_types::local_file
            doc: Unix timestamp
        types:
          info_flags:
            seq:
              - id: has_mod_time
                type: b1
              - id: has_access_time
                type: b1
              - id: has_create_time
                type: b1
              - id: reserved
                type: b5
      infozip_unicode_path:
        seq:
          - id: version
            type: u1
            doc: Version of this extra field, currently 1
          - id: crc32
            type: u4
            doc: File name field CRC32 checksum
          - id: name
            size-eos: true
            type: str
            encoding: utf-8
            doc: UTF-8 version of the entry file name
      infozip_unix_var_size:
        doc-ref: 'https://github.com/LuaDist/zip/blob/b710806/proginfo/extrafld.txt#L1339'
        seq:
          - id: version
            type: u1
            doc: Version of this extra field, currently 1
          - id: len_uid
            type: u1
            doc: Size of UID field
          - id: uid
            size: len_uid
            doc: UID (User ID) for a file
          - id: len_gid
            type: u1
            doc: Size of GID field
          - id: gid
            size: len_gid
            doc: GID (Group ID) for a file
      xceed_unicode:
        seq:
          - id: magic
            contents: 'NUCX'
          - id: num_characters
            type: u2
          - id: data
            size-eos: true
            type: str
            encoding: utf-16le
      alzip_code_page:
        doc-ref: 'https://github.com/icsharpcode/SharpZipLib/issues/657'
        seq:
          - id: code_page
            type: u4
enums:
  compression:
    0: none
    1: shrunk
    2: reduced_1
    3: reduced_2
    4: reduced_3
    5: reduced_4
    6: imploded
    8: deflated
    9: enhanced_deflated
    10: pkware_dcl_imploded
    12: bzip2
    14: lzma
    18: ibm_terse
    19: ibm_lz77_z
    93: zstandard
    94: mp3
    95: xz
    96: jpeg
    97: wavpack
    98: ppmd
    99: aex_encryption_marker
  extra_codes:
    # https://github.com/LuaDist/zip/blob/b710806/proginfo/extrafld.txt
    0x0001: zip64
    0x0007: av_info
#    0x0008: reserved for extended language encoding data (PFS) (see APPENDIX D)
    0x0009: os2
    0x000a: ntfs
    0x000c: openvms
    0x000d: pkware_unix
    0x000e: file_stream_and_fork_descriptors
    0x000f: patch_descriptor
    0x0014: pkcs7
    0x0015: x509_cert_id_and_signature_for_file
    0x0016: x509_cert_id_for_central_dir
    0x0017: strong_encryption_header
    0x0018: record_management_controls
    0x0019: pkcs7_enc_recip_cert_list
    0x0065: ibm_s390_uncomp
    0x0066: ibm_s390_comp
    0x4690: poszip_4690
    0x5455: extended_timestamp
    0x554e: xceed_unicode
    0x5855: infozip_unix_old
    0x6542: beos
    0x7075: infozip_unicode_path
    0x756e: asi_unix
    0x7855: infozip_unix
    0x7875: infozip_unix_var_size
    0x9901: aex_encryption
    0xa11e: apache_commons_compress
    0xa220: microsoft_open_packaging_growth_hint
    # http://hg.openjdk.java.net/jdk7/jdk7/jdk/file/00cd9dc3c2b5/src/share/classes/java/util/jar/JarOutputStream.java#l46
    0xcafe: java_jar
    # https://android.googlesource.com/platform/tools/apksig/+/87d6acee83378201b/src/main/java/com/android/apksig/ApkSigner.java#74
    # https://developer.android.com/studio/command-line/zipalign
    0xd935: zip_align
    0xe57a: alzip_code_page
    0xfd4a: sms_qdos
  section_types:
    0x0201: central_dir_entry
    0x0403: local_file
    0x0505: digital_signature
    0x0605: end_of_central_dir
    0x0606: zip64_end_of_central_dir
    0x0706: zip64_end_of_central_dir_locator
    0x0806: archive_extra_data
    0x0807: data_descriptor
