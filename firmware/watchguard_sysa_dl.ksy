meta:
  id: watchguard_sysa_dl
  title: Watchguard Fireware web update (Sysa-dl) file format
  file-extension: sysa-dl
  license: MIT
  endian: be
  encoding: ASCII

seq:
  - id: fw_header
    size: 24
    type: fw_header

  - id: sections
    size: fw_header.len_sections
    type: sections

types:
  fw_header:
    seq:
      - id: sections_md5
        size: 0x10
        doc: MD5 sum of whole "sections" block

      - id: len_sections
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
        size: head.len_data
        type:
          switch-on: head.name.value
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

      - id: value
        type: strz
        size: 'is_type2 ? 0xf : 0x10'

    instances:
      type2_indicator:
        pos: 0
        type: u1

      is_type2:
        value: type2_indicator == 0x7f

  head:
    seq:
      - id: name
        size: 0x10
        type: name

      - size: 24
        if: name.is_type2

      - id: len_data
        type: u4

      - id: md5sum
        size: 0x10
        if: name.is_type2

  reboot_data:
    seq:
      - id: perm
        size: 0x8
        type: encoded_perm
        if: not _io.eof

  encoded_perm:
    seq:
      - type: u4
      - type: u4

  info_data:
    seq:
      - id: info
        size-eos: true
        type: str

  hmac_data:
    seq:
      - id: prev_sections_hmac_sha1
        size: 20
        doc: |
          HMAC-SHA1 hash (key is the string `etaonrishdlcupfm`) of all sections
          before the "HMAC" section. In practice, "HMAC" is the last section in
          `sections` (if "HMAC" is present at all) and the hash is derived from
          all but the last section.

  wgpkg_data:
    seq:
      - id: meta_info
        type: strz

      - id: magic
        contents: "WGPKG\0"

      - size: 2
      - type: u4
      - id: len_wgpkg_tar_bz2
        type: u4

      - id: wgpkg_tar_bz2
        size: len_wgpkg_tar_bz2
        doc: wgpkg_tar_bz2 is tar.bz2 compresed

enums:
  magic:
    0x1261_1920: type1
    0x1561_1928: type2
