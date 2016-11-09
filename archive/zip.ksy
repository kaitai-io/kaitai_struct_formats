meta:
  id: zip
  file-extension: zip
  endian: le
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
      - id: compression
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
  # https://pkware.cachefly.net/webdocs/casestudies/APPNOTE.TXT - 4.3.12
  central_dir_entry:
    seq:
      - id: version_made_by
        type: u2
      - id: version_needed_to_extract
        type: u2
      - id: flags
        type: u2
      - id: compression_method
        type: u2
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
      - id: comment
        type: str
        size: comment_len
        encoding: UTF-8
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
