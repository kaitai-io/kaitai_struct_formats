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
  - id: font_header
    contents: ['FILE', 0, 0, 0, 4, 'PFF2']
    size: 12
  - id: font_sections
    type: font_section
    repeat: until
    repeat-until: _.section_name == "DATA"
    doc: |
      The "DATA" section acts as a terminator. The documentation says:
      "A marker that indicates the remainder of the file is data accessed
      via the character index (CHIX) section. When reading this font file,
      the rest of the file can be ignored when scanning the sections."
types:
  font_section:
     seq:
       - id: section_name
         size: 4
         type: str
       - id: len_section
         type: u4
       - id: body
         size: len_section
         type:
           switch-on: section_name
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
         if: section_name != "DATA"
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
      - id: entries
        type: character
        repeat: expr
        repeat-expr: _parent.len_section/sizeof<character>
    types:
      character:
        seq:
          - id: code_point
            type: u4
            doc: Unicode code point
          - id: flags
            type: u1
          - id: ofs_character
            type: u4
        instances:
          bitmap:
            io: _root._io
            pos: ofs_character
            type: character_definition
      character_definition:
        seq:
          - id: width
            type: u2
          - id: height
            type: u2
          - id: x_offset
            type: u2
          - id: y_offset
            type: u2
          - id: device_width
            type: u2
          - id: bitmap_data
            size: (width * height + 7) / 8 # ceiled integer division
            doc: |
              Rows of pixels (one bit per pixel), top-down, left-to-right.
              Padded to be on a byte boundary.
