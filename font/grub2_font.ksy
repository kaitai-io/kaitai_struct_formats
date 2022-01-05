meta:
  id: grub2_font
  title: GRUB 2 font
  application: GRUB 2
  file-extension: pf2
  xref:
    justsolve: PFF2
    wikidata: Q29650337
  tags:
    - font
  license: CC0-1.0
  encoding: ASCII
  endian: be
doc: |
  Bitmap font format for the GRUB 2 bootloader.
doc-ref: https://grub.gibibit.com/New_font_format
seq:
  - id: magic
    contents: ["FILE", 0, 0, 0, 4, "PFF2"]
    size: 12
  - id: sections
    type: section
    repeat: until
    repeat-until: _.section_type == "DATA"
    doc: |
      The "DATA" section acts as a terminator. The documentation says:
      "A marker that indicates the remainder of the file is data accessed
      via the character index (CHIX) section. When reading this font file,
      the rest of the file can be ignored when scanning the sections."
types:
  section:
    seq:
      - id: section_type
        size: 4
        type: str
      - id: len_body
        type: u4
        doc: Should be set to `0xFFFF_FFFF` for `section_type != "DATA"`
      - id: body
        size: len_body
        type:
          switch-on: section_type
          cases:
            '"NAME"': name_section
            '"FAMI"': fami_section
            '"WEIG"': weig_section
            '"SLAN"': slan_section
            '"PTSZ"': ptsz_section
            '"MAXW"': maxw_section
            '"MAXH"': maxh_section
            '"ASCE"': asce_section
            '"DESC"': desc_section
            '"CHIX"': chix_section
        if: section_type != "DATA"
  name_section:
    seq:
      - id: font_name
        type: strz
  fami_section:
    seq:
      - id: font_family_name
        type: strz
  weig_section:
    seq:
      - id: font_weight
        type: strz
  slan_section:
    seq:
      - id: font_slant
        type: strz
  ptsz_section:
    seq:
      - id: font_point_size
        type: u2
  maxw_section:
    seq:
      - id: maximum_character_width
        type: u2
  maxh_section:
    seq:
      - id: maximum_character_height
        type: u2
  asce_section:
    seq:
      - id: ascent_in_pixels
        type: u2
  desc_section:
    seq:
      - id: descent_in_pixels
        type: u2
  chix_section:
    seq:
      - id: characters
        type: character
        repeat: eos
    types:
      character:
        seq:
          - id: code_point
            type: u4
            doc: Unicode code point
          - id: flags
            type: u1
          - id: ofs_definition
            type: u4
        instances:
          definition:
            io: _root._io
            pos: ofs_definition
            type: character_definition
      character_definition:
        seq:
          - id: width
            type: u2
          - id: height
            type: u2
          - id: x_offset
            type: s2
          - id: y_offset
            type: s2
          - id: device_width
            type: s2
          - id: bitmap_data
            size: (width * height + 7) / 8 # ceiled integer division
            doc: |
              A two-dimensional bitmap, one bit per pixel. It is organized as
              row-major, top-down, left-to-right. The most significant bit of
              each byte corresponds to the leftmost or uppermost pixel from all
              bits of the byte. If a bit is set (1, `true`), the pixel is set to
              the font color, if a bit is clear (0, `false`), the pixel is
              transparent.

              Rows are **not** padded to byte boundaries (i.e., a
              single byte may contain bits belonging to multiple rows). The last
              byte of the bitmap _is_ padded with zero bits at all unused least
              significant bit positions so that the bitmap ends on a byte
              boundary.
