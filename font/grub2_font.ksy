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
            '"NAME"': font_name
            '"FAMI"': font_family_name
            '"WEIG"': font_weight
            '"SLAN"': font_slant
            '"PTSZ"': font_point_size
            '"MAXW"': maximum_character_width
            '"MAXH"': maximum_character_height
            '"ASCE"': ascent_in_pixels
            '"DESC"': descent_in_pixels
            '"CHIX"': character_index
        if: section_type != "DATA"
  font_name:
    seq:
      - id: name
        type: strz
  font_family_name:
    seq:
      - id: name
        type: strz
  font_weight:
    seq:
      - id: name
        type: strz
  font_slant:
    seq:
      - id: name
        type: strz
  font_point_size:
    seq:
      - id: point_size
        type: u2
  maximum_character_width:
    seq:
      - id: width
        type: u2
  maximum_character_height:
    seq:
      - id: height
        type: u2
  ascent_in_pixels:
    seq:
      - id: ascent
        type: u2
  descent_in_pixels:
    seq:
      - id: descent
        type: u2
  character_index:
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
