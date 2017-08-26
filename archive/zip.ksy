meta:
  id: zip
  file-extension: zip
  endian: le
  license: CC0-1.0
doc-ref: https://pkware.cachefly.net/webdocs/casestudies/APPNOTE.TXT
seq:
  - id: sections
    type: pk_section
    repeat: eos
types:
  pk_section:
    seq:
      - id: magic
        contents: 'PK'
      - id: section_type
        type: u2
      - id: body
        type:
          switch-on: section_type
          cases:
            0x0201: central_dir_entry
            0x0403: local_file
            0x0605: end_of_central_dir
  local_file:
    seq:
      - id: header
        type: local_file_header
      - id: body
        size: header.compressed_size
  local_file_header:
    seq:
      - id: version
        type: u2
      - id: flags
        type: u2
      - id: compression_method
        type: u2
        enum: compression
      - id: file_mod_time
        type: u2
      - id: file_mod_date
        type: u2
      - id: crc32
        type: u4
      - id: compressed_size
        type: u4
      - id: uncompressed_size
        type: u4
      - id: file_name_len
        type: u2
      - id: extra_len
        type: u2
      - id: file_name
        type: str
        size: file_name_len
        encoding: UTF-8
      - id: extra
        size: extra_len
        type: extras
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
      - id: last_mod_file_time
        type: u2
      - id: last_mod_file_date
        type: u2
      - id: crc32
        type: u4
      - id: compressed_size
        type: u4
      - id: uncompressed_size
        type: u4
      - id: file_name_len
        type: u2
      - id: extra_len
        type: u2
      - id: comment_len
        type: u2
      - id: disk_number_start
        type: u2
      - id: int_file_attr
        type: u2
      - id: ext_file_attr
        type: u4
      - id: local_header_offset
        type: s4
      - id: file_name
        type: str
        size: file_name_len
        encoding: UTF-8
      - id: extra
        size: extra_len
        type: extras
      - id: comment
        type: str
        size: comment_len
        encoding: UTF-8
    instances:
      local_header:
        pos: local_header_offset
        type: pk_section
  # https://pkware.cachefly.net/webdocs/casestudies/APPNOTE.TXT - 4.3.16
  end_of_central_dir:
    seq:
      - id: disk_of_end_of_central_dir
        type: u2
      - id: disk_of_central_dir
        type: u2
      - id: qty_central_dir_entries_on_disk
        type: u2
      - id: qty_central_dir_entries_total
        type: u2
      - id: central_dir_size
        type: u4
      - id: central_dir_offset
        type: u4
      - id: comment_len
        type: u2
      - id: comment
        type: str
        size: comment_len
        encoding: UTF-8
  extras:
    seq:
      - id: entries
        type: extra_field
        repeat: eos
  extra_field:
    seq:
      - id: code
        type: u2
        enum: extra_codes
      - id: size
        type: u2
      - id: body
        size: size
        type:
          switch-on: code
          cases:
            'extra_codes::ntfs': ntfs
            'extra_codes::extended_timestamp': extended_timestamp
            'extra_codes::infozip_unix_var_size': infozip_unix_var_size
    types:
      ntfs:
        doc-ref: 'https://github.com/LuaDist/zip/blob/master/proginfo/extrafld.txt#L191'
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
              - id: size
                type: u2
              - id: body
                size: size
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
        doc-ref: 'https://github.com/LuaDist/zip/blob/master/proginfo/extrafld.txt#L817'
        seq:
          - id: flags
            type: u1
          - id: mod_time
            type: u4
          - id: access_time
            type: u4
            if: not _io.eof
          - id: create_time
            type: u4
            if: not _io.eof
      infozip_unix_var_size:
        doc-ref: 'https://github.com/LuaDist/zip/blob/master/proginfo/extrafld.txt#L1339'
        seq:
          - id: version
            type: u1
            doc: Version of this extra field, currently 1
          - id: uid_size
            type: u1
            doc: Size of UID field
          - id: uid
            size: uid_size
            doc: UID (User ID) for a file
          - id: gid_size
            type: u1
            doc: Size of GID field
          - id: gid
            size: gid_size
            doc: GID (Group ID) for a file
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
    98: ppmd
  extra_codes:
    # https://github.com/LuaDist/zip/blob/master/proginfo/extrafld.txt
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
    0x7855: infozip_unix
    0x7875: infozip_unix_var_size
