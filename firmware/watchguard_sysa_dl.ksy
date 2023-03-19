meta:
  id: watchguard_sysa_dl
  title: Watchguard Fireware web update (Sysa-dl) file format
  file-extension: sysa-dl
  license: MIT
  endian: be

seq:
  - id: fw_header
    size: 24
    type: fw_header

  - id: sections
    size: fw_header.file_size
    type: sections

types:
  fw_header:
    seq:
      - id: md5sum
        size: 0x10
        doc: MD5 sum of whole "sections" block

      - id: file_size
        type: u4

      - id: magic
        type: u4
        enum: magic

  sections:
    seq:
      - id: sections
        type: section
        repeat: eos

  section:
    seq:
      - id: head
        type: head

      - id: data
        size: head.data_size
        type:
          switch-on: head.name.content
          cases:
            '"REBOOT"': reboot_data
            '"info"': info_data
            '"HMAC"': hmac_data
            '"WGPKG"': wgpkg_data

  name:
    seq:
      - id: type2_magic
        type: u1
        if: is_type2

      - id: content
        type: strz
        size: 'is_type2 ? 0xf : 0x10'
        encoding: ASCII

    instances:
      type2:
        pos: 0
        type: u1

      is_type2:
        value: type2 == 0x7f

  head:
    seq:
      - id: name
        size: 0x10
        type: name

      - id: unknown_data
        size: 24
        if: name.is_type2

      - id: data_size
        type: u4

      - id: md5sum
        size: 0x10
        if: name.is_type2

  reboot_data:
    seq:
      - id: perm
        size: 0x8
        type: encoded_perm

  encoded_perm:
    seq:
      - id: unknown_dword1
        type: u4
      - id: unknown_dword2
        type: u4

  info_data:
    seq:
      - id: info
        size-eos: true
        type: strz
        encoding: ASCII

  hmac_data:
    seq:
      - id: hmac_sha1_value
        size: 20

  wgpkg_data:
    seq:
      - id: meta_info
        type: strz
        encoding: ASCII

      - id: magic
        contents: "WGPKG\0"

      - id: unknown_word
        size: 2

      - id: unknown_dword
        type: u4
      - id: data_size
        type: u4

      - id: compressed_wpkg
        size: data_size
        doc: compressed_wpkg is bzip2 compresed

enums:
  magic:
    0x1261_1920: type1
    0x1561_1928: type2
